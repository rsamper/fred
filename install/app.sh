#!/bin/bash

# Script: script.sh
# Description: A new bash script
# Author: Your Name
# Date: 2025-10-10

#set -e  # Exit on any error
#set -u  # Exit on undefined variables
echo "Running APP script"

get_packages(){
    local cmd="$*"
    echo $cmd

    mapfile -t packages < <(grep -v '^#' "$*" | grep -v '^$')
    echo ${packages[@]}
    print_message "dbbbbbb"
}



install_fred_client(){
 echo "9. Installing FRED-Clients"
 echo "=============================="
 apt_install fred-client -y
 mv /usr/lib/python3/dist-packages/fred/eppdoc.py mv /usr/lib/python3/dist-packages/fred/eppdoc.py.ori
 exec_command wget https://gitlab.nic.cz/fred/client/-/raw/master/fred/eppdoc.py?ref_type=heads -O /usr/lib/python3/dist-packages/fred/eppdoc.py

}

enable_apache_modules(){
  print_message "8. Habilitando apache for EPP"
  cd /etc/apache2/sites-available/
  a2ensite 02-fred-mod-eppd-apache.conf
  exec_command a2enmod ssl
  exec_command a2enmod corba
  exec_command a2enmod eppd
  exec_command systemctl restart apache2
  exec_command systemctl is-active apache2
  print_message "✅ OK: Apache habilitado."
}



install_app_packages(){
  print_message "1.Instalando FRED APP Node"
  mapfile -t packages < <(grep -v '^#' "$*" | grep -v '^$')
  if [[ ${#packages[@]} -gt 0 ]]; then
    #print_message "Instalando: ${packages[@]}" 
    install ${packages[@]}  # Descomenta cuando estés listo para instalar
    print_message "✅ OK: Paquetes FRED APP ${packages[@]} instalados exitosamente"
  else
    print_message "ℹ️ INFO: No se encontraron paquetes DB válidos para instalar en el archivo '$*'."
  fi
  print_message "✅ OK: FRED APP Node"
  
}
print_info_app(){
  clear
  print_notime "================================================="  
  print_notime "La instalacion de FRED CORE se ejecuta en 3 pasos"  
  print_notime "1/10.  Instalar paquetes: Depedencias Python,Corba Servers"  
  print_notime "-Depedencias Python"
  print_notime "-Corba Servers"  
  print_notime "-Apache for EPP"
  print_notime "-Python Daemons"
  print_notime "-FRED Python libs"
  print_notime "-FRED Daemonds"
  print_notime "-Enable Apache Corba"  
  print_notime "-Enable Apache EPP"  
  #print_notime "9/10.  Instalar FRED Client"  
  print_notime "2/10.  Habilitando Apache Modules"  
  print_notime "3/10.  Copiar archivos de configuracion"  

  print_notime "=================================================="  
  pause 
}
install_app(){
  clear 
  print_info_app  
  #install_fred_client
  install_app_packages $APP_PACKAGES_FILE
  enable_apache_modules
  copy_fred_configs
  print_message "✅ OK: Nodo FRED APP instalado"   
  echo "Favor dirigirse a /etc/fred, y modificar/crear archivos de configuracion"
  print_message "Recuerda inciar los demonios de FRED" 
}
