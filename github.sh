#!/bin/bash

#bash github.sh <cuenta> <repo> <action (pull/push)> 

#ricardosamper
#https://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@github.com/rsamper/fred.git
GIT_TOKEN_SAMPER="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"
GIT_ACCOUNT_SAMPER="rsamper"
GIT_CONNECTION_SAMPER="https://$GIT_TOKEN_NIC@gihub.com/$GIT_ACCOUNT_NIC/$GIT_REPO_NIC.git"
GIT_CONNECTION_SAMPER="https://$GIT_TOKEN_NIC@gihub.com/$GIT_ACCOUNT_NIC/$GIT_REPO_NIC.git"

#rsamper
#https://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@github.com/NIC-sistemas/infraestructura.git
GIT_TOKEN_NIC="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"
GIT_ACCOUNT_NIC="NIC-sistemas"
GIT_CONNECTION_NIC="https://$GIT_TOKEN_NIC@gihub.com/$GIT_ACCOUNT_NIC/$GIT_REPO_NIC.git"


###
GIT_REPO=""


# Verificar que se hayan pasado exactamente 2 argumentos
if [ "$#" -ne 4 ]; then
    echo "❌ ERROR: Debes proporcionar exactamente tres argumentos."
    echo "Uso: bash github.sh <cuenta> <repo> <action (pull/push)> "
    exit 1
fi

# Si llegamos aquí, tenemos 2 argumentos y podemos usarlos
account="$1"
repo="$2"
git_action="$3"
commit_message="$4"



if [ "$1" == "nic" ]; then
    #echo "✅ OK: El primer argumento es igual a NIC."
    git_token=$GIT_TOKEN_NIC
    git_account="rsamper"
    git_connection="https://$GIT_TOKEN_NIC@github.com/$GIT_ACCOUNT_NIC/$repo.git"  
    # Aquí iría el código para ejecutar la lógica de 'db'
fi

if [ "$1" == "rsamper" ]; then
    git_token=$GIT_TOKEN_SAMPER
    git_account="rsamper"
    git_connection="https://$GIT_TOKEN_SAMPER@github.com/$GIT_ACCOUNT_SAMPER/$repo.git"  
    # Aquí iría el código para ejecutar la lógica de 'db'
fi

if [ "$3" == "clone" ]; then
    git "$git_action $git_connection"
    git $git_action $git_connection
    echo "✅ OK: Operacion exitosa -> clone"
    exit 0
fi

if [ "$3" == "pull" ]; then
    echo "git $git_action $git_connection"
    git pull $git_connection > /dev/null
    echo "✅ OK: Operacion exitosa -> pull"
    exit 0
fi

if [ "$3" == "push" ]; then
    echo "git push $git_connection"
    git add .
    git commit -m $4
    git push  $git_connection > /dev/null
    echo "✅ OK: Operacion exitosa -> push"
    exit 0
fi

exit 0
