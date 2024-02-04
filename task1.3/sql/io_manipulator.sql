CREATE USER io_manipulator WITH PASSWORD '147258';

GRANT CONNECT ON DATABASE neoflex_project TO io_manipulator;
-- Подразумевается, что io_manipulator может вычитывать витрины и создавать новые, но
-- не изменять существующие
GRANT USAGE ON SCHEMA dm TO io_manipulator;
GRANT CREATE ON SCHEMA dm TO io_manipulator;
GRANT SELECT ON dm.dm_f101_round_f TO io_manipulator;

