CREATE OR REPLACE PROCEDURE dm.fill_dm_account_turnover_f(i_on_date date) AS $$
BEGIN
  DELETE
  FROM dm.dm_account_turnover_f T
  WHERE T.on_date = i_on_date
  ;

  INSERT INTO dm.dm_account_turnover_f(on_date, account_id, account_number, debet_amount, credit_amount)
  SELECT
    T.on_date,
    T.account_id,
    T.account_number,
    SUM(T.debet_amount) AS debet_amount,
    SUM(T.credit_amount) AS credit_amount
  FROM 
  (
    SELECT
      P.oper_date AS on_date,
      P.debet_account_rk AS account_id,  
      DA.account_number,
      P.debet_amount * COALESCE(DER.reduced_cource, 1) AS debet_amount,
      NULL as credit_amount
    FROM ds.ft_posting_f P
    INNER JOIN ds.md_account_d DA ON DA.account_rk = P.debet_account_rk
      AND P.oper_date BETWEEN DA.data_actual_date AND DA.data_actual_end_date
    LEFT JOIN ds.md_exchange_rate_d DER ON DER.currency_rk = DA.currency_rk
      AND P.oper_date BETWEEN DER.data_actual_date AND DER.data_actual_end_date
    WHERE P.oper_date = i_on_date
    UNION ALL
    SELECT
      P.oper_date AS on_date,
      P.credit_account_rk AS account_id,  
      CA.account_number,
      NULL AS debet_amount,
      P.credit_amount * COALESCE(CER.reduced_cource, 1) AS credit_amount
    FROM ds.ft_posting_f P
    INNER JOIN ds.md_account_d CA ON CA.account_rk = P.credit_account_rk
      AND P.oper_date BETWEEN CA.data_actual_date AND CA.data_actual_end_date
    LEFT JOIN ds.md_exchange_rate_d CER ON CER.currency_rk = CA.currency_rk
      AND P.oper_date BETWEEN CER.data_actual_date AND CER.data_actual_end_date
    WHERE P.oper_date = i_on_date
  ) AS T
  GROUP BY T.on_date, T.account_id, T.account_number
  HAVING SUM(T.debet_amount) IS NOT NULL
    OR SUM(T.credit_amount) IS NOT NULL
  ;
END;
$$ LANGUAGE plpgsql
;