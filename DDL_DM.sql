--DM.DM_ACCOUNT_TURNOVER_F
CREATE USER dm WITH PASSWORD '987654';

CREATE SCHEMA AUTHORIZATION dm;

--DROP TABLE dm.dm_account_turnover_f;

-- обороты по счетам
CREATE TABLE dm.dm_account_turnover_f(
  on_date date                                                   NOT NULL,
  account_id int                                                 NOT NULL,
  account_number varchar(20)                                     NOT NULL,
  debet_amount numeric(23, 8)                                    NULL,
  debet_amount_ths numeric(23, 8) 											-- будем использовать генерируемый стобец
	GENERATED ALWAYS AS (debet_amount / 1000.00) STORED          NULL,  -- не округляю преднамеренно, 
	                                                                        -- т.к. округление лучше делать на самом последнем этапе
  credit_amount numeric(23, 8)                                   NULL,
  credit_amount_ths numeric(23, 8) 
	GENERATED ALWAYS AS (credit_amount / 1000.00) STORED         NULL
);

ALTER TABLE IF EXISTS dm.dm_account_turnover_f
  OWNER TO dm;
  
--DROP TABLE dm.dm_f101_round_f;  
  
CREATE TABLE dm.dm_f101_round_f(
  from_date          date       NOT NULL,
  to_date            date       NOT NULL,
  ledger_account     varchar(5) NOT NULL,
  chapter            varchar(1) NULL,
  char_type          varchar(1) NOT NULL,
  bal_in_rub         numeric(23, 8) NOT NULL,
  bal_in_curr        numeric(23, 8) NOT NULL,
  bal_in_total       numeric(23, 8) NOT NULL,
  deb_amt_rub        numeric(23, 8) NOT NULL,
  deb_amt_curr       numeric(23, 8) NOT NULL,
  deb_amt_total      numeric(23, 8) NOT NULL,
  cre_amt_rub        numeric(23, 8) NOT NULL,
  cre_amt_curr       numeric(23, 8) NOT NULL,
  cre_amt_total      numeric(23, 8) NOT NULL,
  bal_out_rub        numeric(23, 8) NOT NULL,
  bal_out_curr       numeric(23, 8) NOT NULL,
  bal_out_total      numeric(23, 8) NOT NULL
);

ALTER TABLE IF EXISTS dm.dm_f101_round_f
  OWNER TO dm;