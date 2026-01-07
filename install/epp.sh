#!/bin/bash

# Script: script.sh
# Description: A new bash script
# Author: Your Name
# Date: 2025-10-10

#set -e  # Exit on any error
#set -u  # Exit on undefined variables
echo "Running APP script"



step2_enable_apache_modules(){
  print_message "2. Habilitando apache for EPP"
  cd /etc/apache2/sites-available/
  a2ensite 02-fred-mod-eppd-apache.conf
  exec_command a2enmod ssl
  exec_command a2enmod corba
  exec_command a2enmod eppd
  exec_command systemctl restart apache2
  exec_command systemctl is-active apache2
  print_message "✅ OK: Apache habilitado."
}


step1_install_epp_packages(){
  print_message "1.Instalando paquetes FRED EPP Node"
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

print_info_epp(){
  clear
  print_notime "================================================="  
  print_notime "La instalacion de FRED EPP se ejecuta en 2 pasos"  
  print_notime "1/2.  Instalar paquetes: Depedencias Python,Corba Servers"  
  print_notime "2/2.  Habilitando Apache Modules"  
  print_notime "=================================================="  
  pause 
}


install_epp(){
  clear 
  print_info_epp
  print_message "Instalando Nodo EPP instalado"   
  step1_install_epp_packages $EPP_PACKAGES_FILE
  step2_enable_apache_modules 
  print_message "✅ OK: Nodo EPP instalado"   
}
