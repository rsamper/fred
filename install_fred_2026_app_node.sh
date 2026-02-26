# OS: Debian 12

clear
echo "================================"
echo "1/6.Instalando prerequisitos"
echo "================================"
sleep 3

apt update
apt install -y ca-certificates curl gnupg lsb-release git sudo

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" |sudo tee  /etc/apt/sources.list.d/pgdg.list


apt update
apt install -y postgresql-client-17
apt install -y omniorb-nameserver 
apt install -y omniorb


clear
echo "================================"
echo "2/6.Clonando repositorio GIT FRED..."
echo "================================"
sleep 3

# Clone repo with configurations(.sql structures of databases)
cd /tmp/
git clone https://gitlab.nic.cz/fred/demo-install.git

# Move conf files to /tmp
mv demo-install/files /tmp/


clear
echo "======================================="
echo "3/6.Copiando llaves apt repositorios FRED.."
echo "======================================="
sleep 3

# Add cznic keyring for fred packages
mkdir -p /usr/share/keyrings/
curl https://archive.nic.cz/dists/cznic-archive-keyring.gpg >/usr/share/keyrings/cznic-archive-keyring.gpg




clear
echo "============================"
echo "4/6.Agregnado repositorios FRED..."
echo "============================"
sleep 3

# Add source list for FRED
if [ ! -f /etc/apt/sources.list.d/fred.list ]; then
cat << EOT >> /etc/apt/sources.list.d/fred.list
deb [signed-by=/usr/share/keyrings/cznic-archive-keyring.gpg] http://archive.nic.cz/public $(lsb_release -sc) main
EOT
fi

clear
echo "============================"
echo "5/6.Copiando archivo apt pin..."
echo "============================"
sleep 3


# Copy FRED pin list to /etc/apt/preferences.d/fred
cp files/fred /etc/apt/preferences.d/fred

apt update

# Installation of FRED
clear
echo "========================="
echo "6/6.Instalando FRED daemons"
echo "========================="
sleep 3

apt -y install fred-backend-logger fred-backend-logger-corba fred-backend-registry fred-backend-notify fred-backend-public-request fred-backend-zone fred-zone-generator fred-backend-dbreport fred-rifd fred-pifd fred-adifd fred-akm-ng fred-accifd libapache2-mod-eppd python3-fred-epplib fred-eppic

#############333
#apt -y install  
#apt -y install fred-backend-logger-corba 
#apt -y install fred-backend-registry 
#apt -y install fred-backend-notify 
#apt -y install fred-backend-public-request 
#apt -y install fred-backend-zone 
#apt -y install fred-zone-generator 
#apt -y install fred-backend-dbreport 
#apt -y install fred-rifd 
#apt -y install fred-pifd fred-adifd 
#apt -y install fred-akm-ng 
#apt -y install fred-accifd 
#apt -y install libapache2-mod-eppd 
#apt -y install python3-fred-epplib 
#apt -y install fred-eppic


##########################33333

# Remove installation files created by packages, and use example confs from demo repository - it is expected that you will change these configurations according to your needs
rm -rf /etc/fred/*
cp -r files/configs/* /etc/fred/
cp files/configs/eppic.conf /etc/eppic/eppic.conf
rm /etc/fred/eppic.conf

###    Configurar arcjivo server.conf e ingresar la data de conexion a la base de datos.  Igual par al demas servicios

# Ensure the log files are created
touch /var/log/fred-zone-services.log
chown fred /var/log/fred-zone-services.log

# Restart all of the Fred daemons

# Mask services not included in public release(they are not usable)
systemctl mask fred-auction-warehouse
systemctl mask fred-dbreport-services
rm /lib/systemd/system/fred-auction-warehouse.service
systemctl reset-failed

clear
echo "================================================================================================================================================"
echo "Configurar archivos de configuracion de cada servicio, incluyendo server.conf. Ingresar la data de conexion a la base de datos en cada archivo. "
echo "Para iniciar los servicios systemctl restart 'fred-*'"
echo "================================================================================================================================================"
sleep 3
echo "Fin"
exit 0
# If any of the services are failing to start, you can debug them using manual run, for example if you want to debug why `fred-backend-logger.service` is not starting use: `sudo -u fred fred-logger-services --config /etc/fred/fred-logger-services.conf` - it will show you what's wrong