#!/bin/bash
NOME_DO_ARQUIVO_DE_BACKUP="BancoDeTeste.bak"
NOME_DA_BASE_DE_DADOS="BancoDeTeste"
IDENTIFICADOR_DO_ARQUIVO_NO_GOOGLE_DRIVE="11BmXvoWNPSflm7Kzd_ccPp7nQQStY-CO"

restaurarBackupDoBancoDeDados(){
	echo "-> Configurando container sql server local..."
	echo "-> Criando pasta de backup da nova base de dados..."
	mkdir bpkBancoDeDadosDoGoogleDrive
	cd bpkBancoDeDadosDoGoogleDrive
	echo "-> Baixando backup da nova base de dados do drive..."
	baixarBackupDoBancoDeDadosDoGoogleDrive
	echo "-> Copiando backup da nova base de dados para o container..."
	docker cp ${NOME_DO_ARQUIVO_DE_BACKUP} docker-sqlserver:/tmp/${NOME_DO_ARQUIVO_DE_BACKUP}
	echo "-> Alterando senha do sql server para senha padrao [sa123456]"
	winpty docker exec docker-sqlserver //opt//mssql-tools//bin//sqlcmd -U sa -P 'Sa123456' -Q "Alter login [sa] with password=N'sa123456', CHECK_POLICY=OFF"
	echo "-> Verificando se existe e removendo base de dados antiga do container..."
	winpty docker exec docker-sqlserver //opt//mssql-tools//bin//sqlcmd -U sa -P 'sa123456' -Q "IF EXISTS(SELECT * FROM sys.databases WHERE name= '${NOME_DA_BASE_DE_DADOS}') DROP DATABASE ${NOME_DA_BASE_DE_DADOS}"
	echo "-> Restaurando backup da nova base de dados no container..."
	winpty docker exec docker-sqlserver //opt//mssql-tools//bin//sqlcmd -U sa -P 'sa123456' -Q "RESTORE DATABASE [${NOME_DA_BASE_DE_DADOS}] FROM DISK='/tmp/${NOME_DO_ARQUIVO_DE_BACKUP}' WITH MOVE '${NOME_DA_BASE_DE_DADOS}' TO '/var/opt/mssql/data/${NOME_DA_BASE_DE_DADOS}.mdf', MOVE '${NOME_DA_BASE_DE_DADOS}_log' TO '/var/opt/mssql/data/${NOME_DA_BASE_DE_DADOS}_log.ldf' "
	echo "-> Removendo pasta de backup da nova base de dados local..."
	cd ..
	if [ -d bpkBancoDeDadosDoGoogleDrive ]; then
    rm -rf bpkBancoDeDadosDoGoogleDrive
	fi
	echo "-> Fim da configuracao do sql server"
}

baixarBackupDoBancoDeDadosDoGoogleDrive(){
	curl -c ./cookie -s -L "https://drive.google.com/uc?export=download&id=${IDENTIFICADOR_DO_ARQUIVO_NO_GOOGLE_DRIVE}" > /dev/null
	curl -Lb ./cookie "https://drive.google.com/uc?export=download&confirm=`awk '/download/ {print $NF}' ./cookie`&id=${IDENTIFICADOR_DO_ARQUIVO_NO_GOOGLE_DRIVE}" -o ${NOME_DO_ARQUIVO_DE_BACKUP}
}

copiarBackupDoContainerParaSuaMaquina(){
	echo "-> Criando backup da base de dados do container..."
	winpty docker exec docker-sqlserver //opt//mssql-tools//bin//sqlcmd -U sa -P 'sa123456' -Q "BACKUP DATABASE ${NOME_DA_BASE_DE_DADOS} TO DISK='/var/opt/mssql/data/${NOME_DA_BASE_DE_DADOS}_$(date +%Y-%m-%d_%H-%M-%S).bak'"
	if [ -d bkpBancoContainer ]; then
    rm -rf bkpBancoContainer
	fi
	echo "-> Copiando backups do container para a maquina local..."
	docker cp docker-sqlserver:/var/opt/mssql/data/ \bkpBancoContainer
	if [ -d bkpBancoContainer ]; then
    cd bkpBancoContainer
    find -not -name "*.bak" -delete
	fi
	echo "-> Fim da copia dos backups das bases de dados do container sqlserver para a maquina local"
}

while [ true ]
do
    tput reset
    echo ""
	echo "-----------------------------------------------------------"
	echo "|            Acoes para o sql server em docker            |"
	echo "| [1] - Restaurar backup do google drive para o container |"
    echo "| [2] - Copiar backup do container para sua maquina       |"
	echo "-----------------------------------------------------------"
	read -p "Informe o numero da acao: " acaoSelecionada

   case $acaoSelecionada in

    1)
        restaurarBackupDoBancoDeDados
	;;
		
	2)
        copiarBackupDoContainerParaSuaMaquina
	;;
		
	*)
		echo -n "A acao informada nao existe, tente novamente..."
	;;
	esac
done
