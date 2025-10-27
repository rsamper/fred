#!/bin/bash
# Recupera la ruta actual del scrupit en ejecucion
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

GUM_FILE="$SCRIPT_DIR/install_gum.sh"
UTILS_FILE="$SCRIPT_DIR/utils.sh"
FRED_FILE="$SCRIPT_DIR/freddb.sh"
PACKAGES_FILE="$SCRIPT_DIR/fred.packages"


#Check mandatory files

if [ ! -f "$GUM_FILE" ]; then
    echo "❌ El archivo $GUM_FILE no existe."
    echo "End exit code 1"
    exit 1
fi

if [ ! -f "$UTILS_FILE" ]; then
    echo "❌ El archivo $UTILS_FILE no existe"
    echo "End exit code 1"
    exit 1
fi

source "$SCRIPT_DIR/install_gum.sh"
source "$SCRIPT_DIR/utils.sh"
source "$SCRIPT_DIR/freddb.sh"

gum spin --spinner dot --title "Running some checks..." -- sleep 3

#Checking root permissions
if [ "$EUID" -ne 0 ]; then
  echo "$(timestamp)  ❌ Este script debe ejecutarse como root."
  echo "$(timestamp)  End exit code 1"
  exit 1
fi

#Check internet connection
check_internet

#Checking fred repositories
ping -c 1 archive.nic.cz >/dev/null 2>&1 || {
  echo "$(timestamp)  ❌ No hay conexión a archive.nic.cz"
  echo "$(timestamp)  End exit code 1"
  exit 1
}


if [ ! -f "$PACKAGES_FILE" ]; then
    echo "$(timestamp) ❌ El archivo $PACKAGES_FILE no existe"
    echo "End exit code 1"
    exit 1
fi

gum spin --spinner dot --title "Checks Ok..." -- sleep 2
clear
gum spin --spinner dot --title "Internet conection...Ok" -- sleep 2
gum spin --spinner dot --title "FRED internet repositories...Ok" -- sleep 2
gum spin --spinner dot --title "Root permissions...Ok" -- sleep 2
gum spin --spinner dot --title "Packages...Ok" -- sleep 2


mapfile -t packages < <(grep -v '^#' "$SCRIPT_DIR/fred.packages" | grep -v '^$')
echo ${packages[@]}


#######




###########################################################################
clear
##########################################################################


gum style \
	--foreground 212 --border-foreground 212 --border double \
	--align center --width 50 --margin "1 2" --padding "2 4" \
	'Welcome to FRED CZ Instalation'



gum spin --spinner dot --title "Please wait..." -- sleep 3


# Format some markdown

#1. Configure repositorios Keyring
#2. Add repositories
#3. Setting up CZ PIN
#4. Setting up Postfix
#5. Installing up PostgreSQL
#6. Installing FRED DB package
#7. FRED DB CREATION AND MIGRATIONS

continue(){
   gum spin --spinner dot --title "Installing FRED..." -- sleep 5
   gum log --structured --level debug "Creating file..." name file.txt  
   gum spin --spinner dot --title "1...." -- sleep 5


}

gum format -- "# Instalation steps" "1. Configure repositorios Keyring" "2. Add repositories" "3. Setting up CZ PIN" "4. Setting up Postfix"  "5. Installing up PostgreSQL" "6. Installing FRED DB package" "7. FRED DB CREATION AND MIGRATIONS"

gum format -- "# ================="
gum confirm && continue || echo "No"
#echo 'Continue ?:hand:' | gum format -t emoji
exit 0 



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


echo "$(timestamp) 1/16 Instalando pre-requitos del sistema operativo"
echo "=============================================================="

instalar_apache() {
  apt_install apache2 libapache2-mod-corba libapache2-mod-eppd
  run_or_fail a2enmod corba
  run_or_fail a2enmod eppd
  run_or_fail a2enmod ssl
  run_or_fail systemctl restart apache2
}

run_or_fail  mkdir -p /usr/share/keyrings/
run_or_fail  wget https://archive.nic.cz/dists/cznic-archive-keyring.gpg --output-document=/usr/share/keyrings/cznic-archive-keyring.gpg

apt_install python3-dnspython python3-pip uwsgi-plugin-python3 postgresql-client


cat << EOT >> /etc/apt/sources.list.d/fred.list
deb [signed-by=/usr/share/keyrings/cznic-archive-keyring.gpg] http://archive.nic.cz/public $(lsb_release -sc) main
EOT
run_or_fail apt update




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
