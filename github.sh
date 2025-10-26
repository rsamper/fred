#!/bin/bash
# Desarrollado por Ricado Samper
# Uso bash github.sh <cuenta> <repo> <action (pull/push)> 


#Verifica la existencia de las varialbes de entorno necesarios en archivo ~./bashrc
#export EMAIL
#export NAME
#export GIT_TOKEN_RSAMPER
#export GIT_TOKEN_NIC

if [[ ! -v EMAIL ]]; then
    echo "Fallo: EMAIL no existe."
    exit 1
fi

if [[ ! -v NAME ]]; then
    echo "Fallo: NAME no existe."
    exit 1
fi

if [[ ! -v GIT_TOKEN_PERSONAL ]]; then
    echo "Fallo: TOKEN RSAMPER no existe."
    exit 1
fi

if [[ ! -v GIT_TOKEN_JOB ]]; then
    echo "Fallo: TOKEN NIC no existe."
    exit 1
fi


# Verificar que se hayan pasado exactamente 2 argumentos
if [ "$#" -ne 3 ]; then
    echo "❌ ERROR: Debes proporcionar exactamente tres argumentos."
    echo "Uso: bash github.sh <cuenta> <repo> <action (pull/push)> "
    exit 1
fi

# Si llegamos aquí, tenemos 2 argumentos y podemos usarlos
account="$1"
repo="$2"
git_action="$3"
git_connection=""

if [ "$1" == "rsamper" ]; then    
   git_connection="https://$GIT_TOKEN_PERSONAL@github.com/$account/$repo.git"  
else
   git_connection="https://$GIT_TOKEN_JOB@github.com/$account/$repo.git"  
fi



if [ "$3" == "clone" ]; then
    echo "git $git_action $git_connection"
    git $git_action $git_connection > /dev/null
    echo "✅ OK: Operacion exitosa -> clone"
    exit 0
fi

if [ "$3" == "pull" ]; then
    echo "git $git_action $git_connection"
    git pull $git_connection > /dev/null
    echo "✅ OK: Operacion exitosa -> pull"
fi

if [ "$3" == "push" ]; then
    echo "git push $git_connection"
    #3git add . > /dev/null
    #git commit -m $4 > /dev/null
    git push  $git_connection > /dev/null
    echo "✅ OK: Operacion exitosa -> push"
fi

exit 0
