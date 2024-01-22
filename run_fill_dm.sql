-- Этот скрипт можно перенести в процедуру и запукать по отрезку дат,
-- в задании такого требования не было, поэтому оставил пока просто в виде скрипта
-- с безымянным блоком
DO $$
DECLARE
  start_date date = '2018-01-01';
  end_date date = '2018-01-31';
  fix_date date;
  period_length integer;
BEGIN
  period_length = end_date - start_date + 1;
  FOR i IN 0..period_length LOOP
    fix_date = start_date + i;
    CALL dm.fill_dm_account_turnover_f(fix_date);
  END LOOP;
  
  CALL dm.fill_dm_f101_round_f(start_date, end_date);
END;
$$;

--TRUNCATE TABLE dm.dm_account_turnover_f;
--TRUNCATE TABLE dm.dm_f101_round_f;

SELECT *
FROM dm.dm_account_turnover_f
ORDER BY on_date
;

SELECT *
FROM dm.dm_f101_round_f F
ORDER BY F.from_date, F.ledger_account
;