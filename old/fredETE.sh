#!/bin/bash
if [ "$EUID" -ne 0 ]; then
  echo "❌ Este script debe ejecutarse como root."
  exit 1
fi


#set -euo pipefail
#trap 'echo "❌ Error en la línea $LINENO. Saliendo..."; exit 1' ERR

ping -c 1 archive.nic.cz >/dev/null 2>&1 || {
  echo "❌ No hay conexión a archive.nic.cz"
  exit 1
}


green='\033[0;32m'
red='\033[0;31m'
yellow='\033[1;33m'
nc='\033[0m'


SECONDS=0 # Reinicia el contador de tiempo a cero
total_pasos=16
log_file="install.log"
# Contadores
ok=0
fail=0
ya_instalado=0

# Timestamp para logs
timestamp() {
 date +"[%Y-%m-%d %H:%M:%S]"
}

#print_step() {
#  local titulo="$1"
#  local longitud=${#titulo}
#  echo "$titulo"
#  printf '%*s\n' "$longitud" '' | tr ' ' '='
#}

print_step() {
  local titulo="$1"
  local longitud=${#titulo}
  echo -e "\033[1;36m$titulo\033[0m"
  printf '\033[1;36m%*s\033[0m\n' "$longitud" '' | tr ' ' '='
}

apt_install() {
  # Inicializamos los contadores como variables locales para que se reinicien en cada llamada
  local ok=0
  local fail=0
  local ya_instalado=0

  # Arrays para gestionar los paquetes
  local paquetes_solicitados=("$@")
  local paquetes_a_instalar=()
  local default_paquetes=("htop" "curl" "wget")


  # Si no se pasan argumentos, usar la lista por defecto
  if [ ${#paquetes_solicitados[@]} -eq 0 ]; then
    paquetes_solicitados=("${default_paquetes[@]}")
    echo "ℹ️ No se especificaron paquetes. Usando la lista por defecto: ${paquetes_solicitados[*]}"
  fi

  echo "Verificando paquetes: ${paquetes_solicitados[*]}"
  echo "$(timestamp) 🔍 Verificando estado de los paquetes solicitados..." | tee -a "$log_file"

  # 1. PRIMER BUCLE: VERIFICAR QUÉ NECESITA SER INSTALADO
  for paquete in "${paquetes_solicitados[@]}"; do
    if dpkg -s "$paquete" >/dev/null 2>&1; then
      echo "$(timestamp) ✅ El paquete '$paquete' ya está instalado." | tee -a "$log_file"
      ((ya_instalado++))
    else
      echo "$(timestamp) 📝 El paquete '$paquete' se instalará." | tee -a "$log_file"
      paquetes_a_instalar+=("$paquete")
    fi
  done
 
  # 2. INSTALACIÓN EN LOTE (SI ES NECESARIO)
  if [ ${#paquetes_a_instalar[@]} -gt 0 ]; then
    echo "$(timestamp) 📦 Iniciando instalación de: ${paquetes_a_instalar[*]}" | tee -a "$log_file"
    # La redirección correcta para capturar salida y error es "2>&1"
    if salida=$(sudo apt install -y "${paquetes_a_instalar[@]}" 2>&1); then
      echo "$(timestamp) ✅ Todos los paquetes nuevos fueron instalados correctamente." | tee -a "$log_file"
      ok=${#paquetes_a_instalar[@]} # Todos los que intentamos, se instalaron
    else
      echo "$(timestamp) ❌ Ocurrió un error durante la instalación." | tee -a "$log_file"
      # Guardamos el log del error
      echo "$salida" | sed "s/^/$(timestamp) ERROR: /" | tee -a "$log_file"
     echo "Fin con error .....$salida" 
     exit 1
 
      # Esta parte es una estimación. APT falla como un todo, por lo que marcamos todos como fallidos.
      fail=${#paquetes_a_instalar[@]} 
    fi
  else
    echo "$(timestamp) 👍 No hay paquetes nuevos para instalar." | tee -a "$log_file"
  fi

  # 3. RESUMEN FINAL
  echo "----------------------------------------------------"
  echo "$(timestamp) 📊 Resumen final:" | tee -a "$log_file"
  echo "$(timestamp) ✅ Instalados en esta ejecución: $ok" | tee -a "$log_file"
  echo "$(timestamp) ❌ Fallidos: $fail" | tee -a "$log_file"
  echo "$(timestamp) ℹ️ Ya estaban instalados: $ya_instalado" | tee -a "$log_file"
  echo "$(timestamp) 📝 Revisa '$log_file' para más detalles." | tee -a "$log_file"
  sleep 2
  clear
}

print_title(){
  local text="$*"
   width=$(tput cols)
   padding=$(( (width - ${#text}) / 2 ))
   printf "%${padding}s%s%${padding}s\n" "" "$text" ""
}

run_or_fail() {
    local cmd="$*"
    echo "$(timestamp) Ejecutando: $cmd"

    # Ejecuta el comando y captura salida y código de error
    output=$(eval "$cmd" 2>&1)
    local status=$?

    if [ $status -ne 0 ]; then
        echo "❌ ERROR: Falló el comando: $cmd"
        echo "🔍 Detalles del error: $output"
        #echo "$output"
        exit $status
    else
        echo "✅ OK: El comando se ejecutó correctamente. $cmd"
    fi
    sleep 2
    clear
}

instalar_apache() {
  apt_install apache2 libapache2-mod-corba libapache2-mod-eppd
  run_or_fail a2enmod corba
  run_or_fail a2enmod eppd
  run_or_fail a2enmod ssl
  run_or_fail systemctl restart apache2
}
> "$log_file"

clear
print_step "FRED-App, instalacion.  NIC CR"
run_or_fail apt update

sleep 3
clear

echo "$(timestamp) 1/16 Instalando pre-requitos del sistema operativo"
echo "=============================================================="

apt_install ca-certificates curl gnupg lsb-release

echo "$(timestamp) 2/16 Instalano dependencias de Python"
echo "=================================================="

apt_install python3-dnspython python3-pip uwsgi-plugin-python3 postgresql-client

echo "3/16. Creating CZ NIC keyring for FRED Packages"
echo "==============================================="

run_or_fail  mkdir -p /usr/share/keyrings/
run_or_fail  wget https://archive.nic.cz/dists/cznic-archive-keyring.gpg --output-document=/usr/share/keyrings/cznic-archive-keyring.gpg

echo "4/16 Creating sources list fred.list"

cat << EOT >> /etc/apt/sources.list.d/fred.list
deb [signed-by=/usr/share/keyrings/cznic-archive-keyring.gpg] http://archive.nic.cz/public $(lsb_release -sc) main
EOT
run_or_fail apt update

echo "5/16 Installing FRED Postfix installation"
echo "========================================="

debconf-set-selections <<< "postfix postfix/mailname string $(hostname)"
debconf-set-selections <<< "postfix postfix/main_mailer_type string Internet Site"
apt_install postfix

echo "6/16 Creating FRED APT PIN Files to install correct fred packages"
echo "================================================================="

run_or_fail wget https://fred.nic.cz/media/filer_public/71/ce/71ce3145-a4bb-4583-9ff2-218627d71d5f/20241fredpreferencesd.txt -O /etc/apt/preferences.d/fred
run_or_fail apt update
PIN_FILE="/etc/apt/preferences.d/fred"
sudo tee -a "$PIN_FILE" > /dev/null << 'EOF'
Package: python-pyfred
Pin: version 2.15.1*
Pin-Priority: 1001
EOF

echo "7/16. Installing Ubuntu servers for FRED"
echo "========================================="

apt_install pgbouncer omniorb-nameserver omniorb cdnskey-scanner apache2


echo "8/16. Installing FRED Python daemonds"
echo "====================================="
run_or_fail apt update
#apt_install pyfred-filemanager pyfred-genzone pyfred-test-mailer
apt_install pyfred-genzone pyfred-test-mailer

echo "9/16 Installing FRED Python libs"
echo "================================"

apt_install python3-pydantic python3-fred-epplib python3-django-secretary

echo "10/16. Installing FRED daemonds"
echo "==============================="
run_or_fail apt update
apt_install fred-backend-logger fred-backend-logger-corba fred-rifd

echo "11/16. Installing and enabling Apache modules"
echo "============================================="

apt_install libapache2-mod-corba libapache2-mod-eppd 

run_or_fail a2enmod corba
run_or_fail a2enmod eppd
run_or_fail a2enmod ssl

echo "12/16. Enabling Apache epp site"
echo "==============================="

cd /etc/apache2/sites-available/
a2ensite 02-fred-mod-eppd-apache.conf

run_or_fail systemctl restart apache2
run_or_fail systemctl is-active apache2

echo "No hay paso 13/16."
echo "================="

echo "14/16. Installing FRED-Clients"
echo "=============================="
apt_install fred-client -y
mv /usr/lib/python3/dist-packages/fred/eppdoc.py mv /usr/lib/python3/dist-packages/fred/eppdoc.py.ori
run_or_fail wget https://gitlab.nic.cz/fred/client/-/raw/master/fred/eppdoc.py?ref_type=heads -O /usr/lib/python3/dist-packages/fred/eppdoc.py

echo "Favor dirigirse a /etc/fred"
echo "Y modificar/crear archivos de configuracion"
echo "Ademas sustituir ip del servidor de base de datos y clave de la base de datos de fred"
cd /etc/fred
ls
duration=$SECONDS
minutes=$((duration / 60))
seconds=$((duration % 60))

# Muestra la duración y la guarda en el log
echo "----------------------------------------------------"
echo "$(timestamp) ⏱️  Duración total de la ejecución: $minutes minutos y $seconds segundos." | tee -a "$log_file"

echo "$(timestamp) 🧹 Limpiando paquetes innecesarios..."
apt autoremove -y
apt clean

echo "Fin !!!!!"
echo -e "${green}✅ Instalación completa.${nc}"
exit 0
