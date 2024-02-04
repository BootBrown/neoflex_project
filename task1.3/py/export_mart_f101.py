import os
import psycopg2
import io_logger as l

def export_mart() -> None:
    log_process = "export dm"
    log_source = "dm.dm_f101_round_f"

    logger = l.db_logger()
    try:
        logger.check_connection()
    except psycopg2.Error as e:
        print(f"[ERROR] While connecting to logger: {e}")
        return

    #логируем старт экспорта
    logger.write_message(log_process, "Start", "INFO", log_source, None)            

    connection_string = "dbname=neoflex_project user=io_manipulator password=147258 host=localhost port=5432"
    path = "/media/sf_edu/neoflex/project/files"
    filename = "dm_f101_round_f.csv"

    sql_copy = "COPY dm.dm_f101_round_f TO STDOUT WITH (FORMAT CSV, HEADER True, DELIMITER ';', FORCE_QUOTE (ledger_account, chapter, char_type));"

    final_path = os.path.join(path, filename)
 
    if not os.path.exists(path):
        logger.write_message(log_process, "Check path existance", "ERROR", log_source, "Path not exists") 
        return

    try:
        conn = psycopg2.connect(connection_string)
    except psycopg2.Error as e:
        logger.write_message(log_process, "Check dm connection", "ERROR", log_source, e.__repr__())  
        return

    try:
        cur = conn.cursor()
        f = open(final_path, mode="wt")
        cur.copy_expert(sql_copy, file=f, size=8192)
    except psycopg2.Error as e:        
        logger.write_message(log_process, "Export data to file", "ERROR", log_source, e.__repr__())
        return
    finally:
        conn.close()
        f.close()

    #логируем завершение экспорта
    logger.write_message(log_process, "End", "INFO", log_source, None)

    return

def main():
    export_mart()

if __name__ == "__main__":
    main()    