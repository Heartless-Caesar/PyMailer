from dotenv import dotenv_values
import cx_Oracle

config = dotenv_values(".env")

    
# String de conexão
connString = config["conn_string"]

# Variavel que persiste a conexao
conn = cx_Oracle.connect(connString)


# Cursor necessario para exeutar SQL
cur = conn.cursor()
