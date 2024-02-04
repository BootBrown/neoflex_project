import os
import psycopg2
import io_logger as l

def import_mart() -> None:
    log_process = "import dm"
    log_source = "dm.dm_f101_round_f_v2"
    
    logger = l.db_logger()
    try:
        logger.check_connection()
    except psycopg2.Error as e:
        print(f"[ERROR] While connecting to logger: {e}")
        return

    #логируем старт импорта
    logger.write_message(log_process, "Start", "INFO", log_source, None)      
    
    connection_string = "dbname=neoflex_project user=io_manipulator password=147258 host=localhost port=5432"

    path = "/media/sf_edu/neoflex/project/files"
    filename = "dm_f101_round_f.csv"

    sql_drop_table = "DROP TABLE IF EXISTS dm.dm_f101_round_f_v2;"
    sql_create_table = '''
    CREATE TABLE dm.dm_f101_round_f_v2(
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
    '''
    sql_grant = 'GRANT SELECT ON dm.dm_f101_round_f_v2 TO dm;'
    sql_copy = "COPY dm.dm_f101_round_f_v2 FROM STDIN WITH (FORMAT CSV, HEADER True, DELIMITER ';');"

    final_path = os.path.join(path, filename)
    
    if not os.path.exists(final_path):     
        logger.write_message(log_process, "Check file existance", "ERROR", log_source, "Path not exists")  
        return

    try:
        conn = psycopg2.connect(connection_string)
    except psycopg2.Error as e:     
        logger.write_message(log_process, "Check dm connection", "ERROR", log_source, e.__repr__())  
        return

    try:
        cur = conn.cursor()
        f = open(final_path, mode="rt")

        cur.execute(sql_drop_table)
        cur.execute(sql_create_table)
        cur.execute(sql_grant)    
        cur.copy_expert(sql_copy, file=f, size=8192)
        conn.commit()
    except psycopg2.Error as e:
        logger.write_message(log_process, "Import data from file", "ERROR", log_source, e.__repr__())
        return          
    finally:
        conn.close()
        f.close()

    #логируем завершение импорта
    logger.write_message(log_process, "End", "INFO", log_source, None)           

    return

def main():
    import_mart()

if __name__ == "__main__":
    main()    
