#!/bin/bash
set -e


echo "Running some checks..."

##########################################################################
set -euo pipefail
trap 'echo "❌ Error en la línea $LINENO. Saliendo..."; exit 1' ERR

#Checking root permissions
if [ "$EUID" -ne 0 ]; then
  echo "❌ Este script debe ejecutarse como root."
  exit 1
fi

#Checking fred repositories
ping -c 1 archive.nic.cz >/dev/null 2>&1 || {
  echo "❌ No hay conexión a archive.nic.cz"
  exit 1
}

# Recupera la ruta actual del scrupit en ejecucion
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

source "$SCRIPT_DIR/utils.sh"
echo "$(timestamp) ✅ ete" | tee -a "$LOG_FILE_NAME"



mapfile -t packages < <(grep -v '^#' "$SCRIPT_DIR/fred.packages" | grep -v '^$')
echo ${packages[@]}
exit 0




#######




###########################################################################
clear
##########################################################################






#



gum style \
	--foreground 212 --border-foreground 212 --border double \
	--align center --width 50 --margin "1 2" --padding "2 4" \
	'Welcome to FRED CZ Instalation'

gum spin --spinner dot --title "Please wait..." -- sleep 3




# Format some markdown
gum format -- "# Instalation steps" "- 1.Pre requisites" "- Code" "- Template" "- Emoji"
#echo "# Gum Formats\n- Markdown\n- Code\n- Template\n- Emoji" | gum format


# Display your favorite emojis!
echo 'I :happy: Bubble Gum :candy:' | gum format -t emoji


gum spin --spinner dot --title "Buying Bubble Gum..." -- sleep 5


echo "Choose you instalation package..."
CARD=$(gum choose --height 15 FRED-DB  FRED-Client)
echo "Selection $CARD"


# Ejemplo: Verificar si un número es mayor a 10


if [[ "$CARD" == "FRED-DB" ]]; then
    echo "Las cadenas son iguales."
    source "$SCRIPT_DIR/ete.sh"
fi






# El script continúa aquí




gum confirm && echo "Ete" || echo "No"





gum style \
	--foreground 212 --border-foreground 212 --border double \
	--align center --width 50 --margin "1 2" --padding "2 4" \
	'jaja'

# Log some debug information.
gum log --structured --level debug "Creating file..." name file.txt
# DEBUG Unable to create file. name=temp.txt

# Log some error.
gum log --structured --level info "Unable to create file." name file.txt
# ERROR Unable to create file. name=temp.txt

# Include a timestamp.
gum log --time rfc822 --level error "Unable to create file."

gum log --time rfc822 --level warn "Unable to create file."


#gum input > answer.txt
#gum input --password > password.txt


exit 0






echo "Configurando CZ repositorios "

mkdir -p /usr/share/keyrings/
wget https://archive.nic.cz/dists/cznic-archive-keyring.gpg --output-document=/usr/share/keyrings/cznic-archive-keyring.gpg

# FRED Source list
## Add source list for FRED
cat << EOT >> /etc/apt/sources.list.d/fred.list
deb [signed-by=/usr/share/keyrings/cznic-archive-keyring.gpg] http://archive.nic.cz/public $(lsb_release -sc) main
EOT

# FRED CZ PIN
#!/bin/bash
echo "5. Creating FRED APT PIN Fiiles to install correct fred packages"
wget https://fred.nic.cz/media/filer_public/71/ce/71ce3145-a4bb-4583-9ff2-218627d71d5f/20241fredpreferencesd.txt -O /etc/apt/preferences.d/fred
apt update
echo "Fin !!!!!"

#!/bin/bash
# Postfix
debconf-set-selections <<< "postfix postfix/mailname string $(hostname)"
debconf-set-selections <<< "postfix postfix/main_mailer_type string Internet Site"
apt --assume-yes install postfix

#!/bin/bash
# Postgres 12
sudo apt install postgresql postgresql-contrib

#!/bin/bash
apt update
apt install fred-db

#!/bin/bash
# FRED DB CREATION AND MIGRATIONS
su - postgres -c "/usr/sbin/fred-dbmanager install"

echo "Fin !!!!!"
echo "Favor modificar archivos de configuracion PostgresSQL"
