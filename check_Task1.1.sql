TRUNCATE TABLE ds.ft_balance_f;
TRUNCATE TABLE ds.ft_posting_f;
TRUNCATE TABLE ds.md_account_d;
TRUNCATE TABLE ds.md_currency_d;
TRUNCATE TABLE ds.md_exchange_rate_d;
TRUNCATE TABLE ds.md_ledger_account_s;
--
TRUNCATE TABLE logs.load_logs;

SELECT * FROM ds.ft_balance_f;
SELECT * FROM ds.ft_posting_f;
SELECT * FROM ds.md_account_d;
SELECT * FROM ds.md_currency_d;
SELECT * FROM ds.md_exchange_rate_d;
SELECT * FROM ds.md_ledger_account_s;
--
SELECT * 
FROM logs.load_logs 
WHERE log_type = 'INFO' 
ORDER BY action_datetime, source, action; 
-- check input changes
SELECT * FROM ds.ft_balance_f WHERE account_rk = 36237725