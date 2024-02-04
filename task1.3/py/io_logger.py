import psycopg2
import yaml

class db_logger:
    def __init__(self, connection_string: str=None) -> None:
        self._connection_string = connection_string
        if connection_string:
            self._connection_dict = None
        else:
            self._connection_dict = self.load_config()

    def load_config(self):
        with open("/media/sf_edu/neoflex/project/py/io_logger_config.yml") as conf:
            logger_config = yaml.load(conf, Loader=yaml.loader.SafeLoader)
            return logger_config["db_connection"]
        
    def connect(self):
        if self._connection_string:
            conn = psycopg2.connect(self._connection_string)
        else :
            conn = psycopg2.connect(**self._connection_dict)

        return conn
    
    def check_connection(self) -> None:
        with self.connect() as conn:
            with conn.cursor() as cur:
                pass
    
    def write_message(
        self, 
        process: str, 
        action: str,
        log_type: str,
        source: str=None,        
        message: str=None,
    ):
        with self.connect() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    "INSERT INTO logs.io_logs(process, source, action, log_type, message) VALUES(%s, %s, %s, %s, %s)",
                    (process, source, action, log_type, message)
                )