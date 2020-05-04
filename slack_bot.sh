##############################################################################
#                      Configurações do bot em 2 passos
#
# 1 - Passo
# Gere um slack token apartir do link abaixo
# https://api.slack.com/custom-integrations/legacy-tokens
# ele sera parecido com isso => "xoxp-xxxxxxxxxx-xxxxxxxxxx-xxxxxxxxxx-xxxxxx"
#
# 2 - Passo
# Altere o nome dos canais nas variaveis CANAL*** e customize suas mensagens
#
#
# *******************************Extras*************************************
# Como obter os identificadores de usuarios para enviar mensagens, acesse o perfil do usuario "View full profile", 
# clique nos tres pontos e copie o ID de menbro "Copy menber ID" e coloque entre <@>, elle ficara parecido com isso <@U0NHXPTO>  
##############################################################################

#!/bin/bash
SLACK_USER_TOKEN=""
CANAL_DEV="dev-channel"
CANAL_TIME="channel"

enviarMensagem(){
  canal=$1
  mensagem=$2
  curl -X POST "https://slack.com/api/chat.postMessage" -H "accept: application/json" -d token=${SLACK_USER_TOKEN} -d channel=${canal} -d text=${mensagem} -d as_user=true
}

mudarStatus(){
  mensagem=$1  
  emoji=$2
  curl -s -S -X POST -d token=${SLACK_USER_TOKEN} --data-urlencode "profile={\"status_text\": \"$mensagem\", \"status_emoji\": \"$emoji\"}" https://slack.com/api/users.profile.set
}

while [ true ]
do
    tput reset
    echo ""
	echo "------------------------------------------------"
	echo "|             Acoes para o slack               |"
	echo "| 1 - Mensagem - Iniciando o dia               |"	
    echo "| 2 - Mensagem - aviso de pr                   |"
    echo "| 3 - Status - Trabalhando remoto              |"
	echo "| 4 - Status - Corrigindo bug/fura-fila        |"
	echo "| 5 - Status - Almocando                       |"
	echo "| 6 - Status - Pausa rapida                    |"
	echo "| 7 - Status/Mensagem - Encerrando o dia       |"
    echo "| 0 - Status - Limpeza de status               |"
	echo "------------------------------------------------"
	read -p "Informe o numero da acao: " acaoSelecionada

   case $acaoSelecionada in

        1)
            mensagem="Bom%20dia%20galeris%20:grin:"
			enviarMensagem $CANAL_TIME $mensagem
		;;
		
		2)
            read -p "Informe o numero da pr: " numeroDaPr
			mensagem="<@UBQG8UGTA>%20<@UJ2ATDE3H>%20<@U5T296MJ7>%20<@U0NM52RLG>%20tem%20pr%20:gato-digitando:%20->%20urlDePrs"$numeroDaPr
			enviarMensagem $CANAL_DEV $mensagem
		;;

		3)
           mensagem="Working" 
           emoji=":house_with_garden:" 
		   mudarStatus $mensagem $emoji
		;;

		4)
            read -p "Informe o numero do bug/fura-fila: " numeroDoFuraFila
			mensagem="Resolvendo_bug/fura-fila_"$numeroDoFuraFila 
            emoji=":helmet_with_white_cross:" 
		    mudarStatus $mensagem $emoji
		;;
		
		5)
			mensagem="Almocando" 
            emoji=":meat_on_bone:" 
		    mudarStatus $mensagem $emoji
		;;
		
		6)
			mensagem="Volto_logo" 
            emoji=":coffee:" 
		    mudarStatus $mensagem $emoji
		;;

		7)
			mensagemDeStatus="Buteco_fechado_por_hoje" 
            emoji=":kissing_heart:" 
		    mudarStatus $mensagemDeStatus $emoji
			mensagemDeEncerramento="Encerrando%20por%20hoje%20galeris,%20flw%20vlw%20:facepunch:"
			enviarMensagem $CANAL_TIME $mensagemDeEncerramento
		;;

        0)
			mensagem="" 
            emoji="" 
		    mudarStatus $mensagem $emoji
		;;

		*)
			echo -n "A acao informada nao existe"
		;;
	esac

done
