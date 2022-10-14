# cx_Oracle realiza a conexao e permite manipular dados do banco
from services.fetchData import getQuery
from config.configs import conn,cur

try:

    print("Conectado ao banco")

    getQuery()

    # """
    # # Teste para ver se as queries estão funcionando
    # cur.execute("SELECT * FROM datacenter.AUTSC2_SOLICITACOES WHERE ROWNUM <= 100")

    # while True:
    #     row = cur.fetchone()
    #     if row is None:
    #         break
    #     print(row)    
    # """

# Tratando as exceções
except Exception as err:
    
    print("Algo deu errado com o BD")
    
    print(err)

# Fechar a conexao quando chegar ao final de processamento, seja positivo ou negativo
finally:
    if(conn):
        # Fechar o cursor a fim de evitar vazamentos de memória
        cur.close()
    # Fechar conexão    
    conn.close()   
    print("\t /*********************** Connection closed ***********************/") 