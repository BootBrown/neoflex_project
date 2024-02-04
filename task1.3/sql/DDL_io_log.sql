DROP TABLE IF EXISTS logs.io_logs;

CREATE TABLE logs.io_logs(
  action_datetime   timestamp    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  process           varchar(50)  NOT NULL,
  "source"          varchar(50)  NULL,
  "action"          varchar(50)  NOT NULL,
  log_type          varchar(50)  NOT NULL,
  "message"         text         NULL
);

ALTER TABLE IF EXISTS logs.io_logs
  OWNER TO logs;

--INSERT INTO logs.io_logs(process, "source", "action", "log_type", "message")
--VALUES ('import dm', 'dm.dm_f101_round_f_v2', 'START', 'INFO', 'Procedure has started');
