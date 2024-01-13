CREATE USER DS WITH PASSWORD '123456';

CREATE SCHEMA AUTHORIZATION DS;

CREATE USER LOGS WITH PASSWORD '654321';

CREATE SCHEMA AUTHORIZATION LOGS;

-- остатки средств на счетах
CREATE TABLE ds.ft_balance_f(
  on_date date        NOT NULL,
  account_rk int      NOT NULL,
  currency_rk int     NULL,
  balance_out numeric NULL,
  CONSTRAINT pk_ds_ft_balance_f PRIMARY KEY(on_date, account_rk)
);

ALTER TABLE IF EXISTS ds.ft_balance_f
  OWNER TO ds;

-- проводки (движения средств) по счетам
CREATE TABLE ds.ft_posting_f(
  oper_date         date    NOT NULL,
  credit_account_rk int     NOT NULL,
  debet_account_rk  int     NOT NULL,
  credit_amount     numeric NULL,
  debet_amount      numeric NULL,
  CONSTRAINT pk_ds_ft_posting_f PRIMARY KEY(oper_date, credit_account_rk, debet_account_rk)
);

ALTER TABLE IF EXISTS ds.ft_posting_f
  OWNER TO ds;

-- информация о счетах клиентов
CREATE TABLE ds.md_account_d(
  data_actual_date 	   date        NOT NULL,
  data_actual_end_date date        NOT NULL,
  account_rk           int         NOT NULL,
  account_number       varchar(20) NOT NULL,
  char_type            varchar(1)  NOT NULL,
  currency_rk          int         NOT NULL,
  currency_code        varchar(3)  NOT NULL,
  CONSTRAINT pk_ds_md_account_d PRIMARY KEY(data_actual_date, account_rk)
);

ALTER TABLE IF EXISTS ds.md_account_d
  OWNER TO ds;

-- справочник валют
CREATE TABLE ds.md_currency_d(
  currency_rk          int        NOT NULL,
  data_actual_date     date       NOT NULL,
  data_actual_end_date date       NULL,
  currency_code        varchar(3) NULL,
  code_iso_char	       varchar(3) NULL,
  CONSTRAINT pk_ds_md_currency_d PRIMARY KEY(currency_rk, data_actual_date)
);

ALTER TABLE IF EXISTS ds.md_currency_d
  OWNER TO ds;

-- курсы валют
CREATE TABLE ds.md_exchange_rate_d(
  data_actual_date     date       NOT NULL,
  data_actual_end_date date       NULL,
  currency_rk          int        NOT NULL,
  reduced_cource       numeric    NULL,
  code_iso_num         varchar(3) NULL,
  CONSTRAINT pk_ds_md_exchange_rate_d PRIMARY KEY(data_actual_date, currency_rk)
);

ALTER TABLE IF EXISTS ds.md_exchange_rate_d
  OWNER TO ds;
	
-- справочник балансовых счётов
CREATE TABLE ds.md_ledger_account_s(
  chapter                       char(1)           NULL,
  chapter_name                  varchar(16)       NULL,
  section_number                int               NULL,
  section_name                  varchar(22)       NULL,
  subsection_name               varchar(21)       NULL,
  ledger1_account               int               NULL,
  ledger1_account_name          varchar(47)       NULL,
  ledger_account                int               NOT NULL,
  ledger_account_name           varchar(153)      NULL,
  characteristic                char(1)           NULL,
  is_resident                   int               NULL,
  is_reserve                    int               NULL,
  is_reserved                   int               NULL,
  is_loan                       int               NULL,
  is_reserved_assets            int               NULL,
  is_overdue                    int               NULL,
  is_interest                   int               NULL,
  pair_account                  varchar(5)        NULL,        
  start_date                    date              NOT NULL,
  end_date                      date              NULL,
  is_rub_only                   int               NULL,
  min_term                      varchar(1)        NULL,
  min_term_measure              varchar(1)        NULL,
  max_term                      varchar(1)        NULL,
  max_term_measure              varchar(1)        NULL,
  ledger_acc_full_name_translit varchar(1)        NULL,
  is_revaluation                varchar(1)        NULL,
  is_correct	                varchar(1)        NULL,
  CONSTRAINT pk_ds_md_ledger_account_s PRIMARY KEY(ledger_account, start_date)
);

ALTER TABLE IF EXISTS ds.md_ledger_account_s
  OWNER TO ds;

CREATE TABLE logs.load_logs(
  action_datetime   timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  source            varchar(50)  NULL,
  action            varchar(50)  NOT NULL,
  log_type          varchar(50)  NOT NULL
);

ALTER TABLE IF EXISTS logs.load_logs
  OWNER TO logs;


