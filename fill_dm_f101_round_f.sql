CREATE OR REPLACE PROCEDURE dm.fill_dm_f101_round_f(i_from_date date, i_to_date date) AS $$
DECLARE
  prev_period_end date;
BEGIN

prev_period_end = CAST(DATE_TRUNC('month', i_from_date) AS date) - 1;

-- объявляем временные таблицы
DROP TABLE IF EXISTS ledg_acc_101;
CREATE TEMPORARY TABLE ledg_acc_101( 
  ledger_account varchar(5) NOT NULL,
  chapter varchar(1) NULL,	
  account_rk int NOT NULL,
  currency_rk int NOT NULL,
  currency_code varchar(3) NOT NULL,
  char_type varchar(1) NOT NULL
);

DROP TABLE IF EXISTS acc_turnover_101;
CREATE TEMPORARY TABLE acc_turnover_101(
  account_rk int NOT NULL,
  acc_deb_amt_ths NUMERIC(23, 8) NULL,
  acc_cre_amt_ths NUMERIC(23, 8) NULL
);

DROP TABLE IF EXISTS acc_balance_in_101;
CREATE TEMPORARY TABLE acc_balance_in_101(
  account_rk int NOT NULL,
  acc_bal_in_convert NUMERIC(23, 8) NULL
);

INSERT INTO ledg_acc_101(ledger_account, chapter, account_rk, currency_rk, currency_code, char_type)
SELECT
  SUBSTRING(A.account_number FROM 1 FOR 5),
  LA.chapter,
  A.account_rk,
  A.currency_rk,
  A.currency_code,
  A.char_type
FROM ds.md_ledger_account_s LA
INNER JOIN ds.md_account_d A ON (SUBSTRING(A.account_number FROM 1 FOR 5)) = CAST(LA.ledger_account AS varchar(20))
WHERE LA.start_date <= i_to_date
  AND COALESCE(LA.end_date, '2050-12-31') >= i_from_date
  AND A.data_actual_date <= i_to_date
  AND A.data_actual_end_date >= i_from_date
;

--SELECT *
--FROM ledg_acc_101;

-- аггрегированные за период обороты в разрезе счетов
INSERT INTO acc_turnover_101(account_rk, acc_deb_amt_ths, acc_cre_amt_ths)
SELECT 
  T.account_id,
  SUM(debet_amount_ths),
  SUM(credit_amount_ths)
FROM ledg_acc_101 A
INNER JOIN dm.dm_account_turnover_f T ON T.account_id = A.account_rk
  AND T.on_date BETWEEN i_from_date AND i_to_date
GROUP BY T.account_id
;

--SELECT *
--FROM acc_turnover_101;

-- входящие балансы на начало периода в разрезе счетов
INSERT INTO acc_balance_in_101(account_rk, acc_bal_in_convert)
SELECT
  B.account_rk,
  B.balance_out * COALESCE(BER.reduced_cource, 1) / 1000.00
FROM ledg_acc_101 A
INNER JOIN ds.ft_balance_f B ON B.account_rk = A.account_rk             -- подразумеваю, что входящие балансы указаны в валютах счета
  AND B.on_date = prev_period_end
LEFT JOIN ds.md_exchange_rate_d BER ON BER.currency_rk = B.currency_rk  -- подразумеваю, что курсы есть по всем валютам
  AND B.on_date BETWEEN BER.data_actual_date AND BER.data_actual_end_date
;

--SELECT *
--FROM acc_balance_in_101;

DELETE
FROM dm.dm_f101_round_f T
WHERE T.from_date = i_from_date
  AND T.to_date = i_to_date
;

WITH
cte_pre_101 AS(
SELECT
  A.ledger_account,
  A.chapter,
  A.char_type,
  -- входящие остатки
  SUM(
    COALESCE(
      CASE
        WHEN A.currency_code IN ('643', '810') THEN B.acc_bal_in_convert
	    ELSE NULL
      END,
      0
    )
  ) AS bal_in_rub,
  SUM(
    COALESCE(
      CASE
        WHEN A.currency_code NOT IN ('643', '810') THEN B.acc_bal_in_convert 
	    ELSE NULL
      END,
      0
    )
  ) AS bal_in_curr,
  -- обороты по дебету
  SUM(
    COALESCE(
      CASE
        WHEN A.currency_code IN ('643', '810') THEN T.acc_deb_amt_ths 
	    ELSE NULL
      END,
      0
    )
  ) AS deb_amt_rub,
  SUM(
    COALESCE(
      CASE
        WHEN A.currency_code NOT IN ('643', '810') THEN T.acc_deb_amt_ths
	    ELSE NULL
      END,
      0
    )
  ) AS deb_amt_curr,
  -- обороты по кредиту
  SUM(
    COALESCE(
      CASE
        WHEN A.currency_code IN ('643', '810') THEN T.acc_cre_amt_ths
	    ELSE NULL
      END,
      0
    )
  ) AS cre_amt_rub,
  SUM(
    COALESCE(
      CASE
        WHEN A.currency_code NOT IN ('643', '810') THEN T.acc_cre_amt_ths
	    ELSE NULL
      END,
      0
    )
  ) AS cre_amt_curr,
  -- исходящие остатки
  SUM(
    COALESCE(
      CASE
        WHEN A.currency_code IN ('643', '810') THEN BO.acc_bal_out
	    ELSE NULL
      END,
      0
    )
  ) AS bal_out_rub,
  SUM(
    COALESCE(
      CASE
        WHEN A.currency_code NOT IN ('643', '810') THEN BO.acc_bal_out
	    ELSE NULL
      END,
      0
    )
  ) AS bal_out_curr
FROM ledg_acc_101 A
LEFT JOIN acc_turnover_101 T ON T.account_rk = A.account_rk
LEFT JOIN acc_balance_in_101 B ON B.account_rk = A.account_rk
CROSS JOIN LATERAL(
  SELECT
    CASE A.char_type
	  WHEN 'A' THEN 
        COALESCE(B.acc_bal_in_convert, 0) - COALESCE(T.acc_cre_amt_ths, 0) + COALESCE(T.acc_deb_amt_ths, 0)
      WHEN 'P' THEN
        COALESCE(B.acc_bal_in_convert, 0) + COALESCE(T.acc_cre_amt_ths, 0) - COALESCE(T.acc_deb_amt_ths, 0)
    END AS acc_bal_out
)BO
GROUP BY A.ledger_account, A.chapter, A.char_type
)
-- Не понял нужно ли здесь округление
-- по шаблону ЦБ я не понял какой формат чисел
-- в видео-уроке формат столбцов NUMERIC(23, 8) и без округления
-- возможно BI-инструменты или функционал выгрузки в файлы выполняет округление
INSERT INTO dm.dm_f101_round_f(
  from_date, to_date, ledger_account, chapter, char_type, bal_in_rub, bal_in_curr, bal_in_total,
  deb_amt_rub, deb_amt_curr, deb_amt_total, cre_amt_rub, cre_amt_curr, cre_amt_total,
  bal_out_rub, bal_out_curr, bal_out_total
)
SELECT
  i_from_date AS from_date,
  i_to_date AS to_date,
  P.ledger_account,
  P.chapter,
  P.char_type,
  P.bal_in_rub,
  P.bal_in_curr,
  P.bal_in_rub + P.bal_in_curr AS bal_in_total,
  P.deb_amt_rub,
  P.deb_amt_curr,
  P.deb_amt_rub + P.deb_amt_curr AS deb_amt_total,
  P.cre_amt_rub,
  P.cre_amt_curr,
  P.cre_amt_rub + P.cre_amt_curr AS cre_amt_total,
  P.bal_out_rub,
  P.bal_out_curr,
  P.bal_out_rub + P.bal_out_curr AS bal_out_total
FROM cte_pre_101 P
;
END;
$$ LANGUAGE plpgsql
;




