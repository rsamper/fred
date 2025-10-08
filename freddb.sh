#!/bin/bash



hello


#1. Configurar repositorios Keyring
#2. Add repositories
#3. Setting up CZ PIN
#4. Setting up Postfix
#5. Installing up PostgreSQL
#6. Installing FRED DB package
#7. FRED DB CREATION AND MIGRATIONS


#instalar_apache() {
#  apt_install apache2 libapache2-mod-corba libapache2-mod-eppd
#  run_or_fail a2enmod corba
#  run_or_fail a2enmod eppd
#  run_or_fail a2enmod ssl
#  run_or_fail systemctl restart apache2
#}



#run_or_fail  mkdir -p /usr/share/keyrings/
#run_or_fail  wget https://archive.nic.cz/dists/cznic-archive-keyring.gpg --output-document=/usr/share/keyrings/cznic-archive-keyring.gpg

#apt_install python3-dnspython python3-pip uwsgi-plugin-python3 postgresql-client


#cat << EOT >> /etc/apt/sources.list.d/fred.list
#deb [signed-by=/usr/share/keyrings/cznic-archive-keyring.gpg] http://archive.nic.cz/public $(lsb_release -sc) main
#EOT
#run_or_fail apt update




#echo "Configurando CZ repositorios "

#mkdir -p /usr/share/keyrings/
#wget https://archive.nic.cz/dists/cznic-archive-keyring.gpg --output-document=/usr/share/keyrings/cznic-archive-keyring.gpg

## FRED Source list
### Add source list for FRED
#cat << EOT >> /etc/apt/sources.list.d/fred.list
#deb [signed-by=/usr/share/keyrings/cznic-archive-keyring.gpg] http://archive.nic.cz/public $(lsb_release -sc) main
#EOT

## FRED CZ PIN
##!/bin/bash
#echo "5. Creating FRED APT PIN Fiiles to install correct fred packages"
#wget https://fred.nic.cz/media/filer_public/71/ce/71ce3145-a4bb-4583-9ff2-218627d71d5f/20241fredpreferencesd.txt -O /etc/apt/preferences.d/fred
#apt update
#echo "Fin !!!!!"

##!/bin/bash
## Postfix
#debconf-set-selections <<< "postfix postfix/mailname string $(hostname)"
#debconf-set-selections <<< "postfix postfix/main_mailer_type string Internet Site"
#apt --assume-yes install postfix

##!/bin/bash
## Postgres 12
#sudo apt install postgresql postgresql-contrib

##!/bin/bash
#apt update
#apt install fred-db

##!/bin/bash
## FRED DB CREATION AND MIGRATIONS
#su - postgres -c "/usr/sbin/fred-dbmanager install"

#echo "Fin !!!!!"
#echo "Favor modificar archivos de configuracion PostgresSQL"
