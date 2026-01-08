#!/bin/bash

# Script: script.sh
# Description: A new bash script
# Author: Your Name
# Date: 2025-10-10

#set -e  # Exit on any error
#set -u  # Exit on undefined variables
echo "Running APP script"



install_fred_client(){
 echo "9. Installing FRED-Clients"
 echo "=============================="
 apt_install fred-client -y
 mv /usr/lib/python3/dist-packages/fred/eppdoc.py mv /usr/lib/python3/dist-packages/fred/eppdoc.py.ori
 exec_command wget https://gitlab.nic.cz/fred/client/-/raw/master/fred/eppdoc.py?ref_type=heads -O /usr/lib/python3/dist-packages/fred/eppdoc.py

}


step2_copy_fred_configs(){
  print_message "1.Instalando FRED APP Node"
  draw_bar 50
  sleep 1
  copy_fred_configs
  print_message "OK: FRED APP Node!!!!!"
  
}

step1_install_app_packages(){
  print_message "1.Instalando FRED APP Node"
  draw_bar 0
  sleep 1
  mapfile -t packages < <(grep -v '^#' "$*" | grep -v '^$')
  if [[ ${#packages[@]} -gt 0 ]]; then
    install ${packages[@]}  # Descomenta cuando estés listo para instalar
    print_message "OK: Paquetes FRED APP ${packages[@]} instalados exitosamente !!!!!"
  else
    print_message "ℹ️ INFO: No se encontraron paquetes DB válidos para instalar en el archivo '$*'...."
  fi
  print_message "OK: FRED APP Node!!!!!"
  
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
  print_notime "2/10.  Habilitando Apache Modules"  
  print_notime "3/10.  Copiar archivos de configuracion"  

  print_notime "=================================================="  
}
install_app(){
  if [ -z "$APP_PACKAGES_FILE" ]; then
    print_message "Error: DB_PACKAGES_FILE no está definido o está vacío."
    exit 1
  fi
  clear 
  print_info_app  
  #install_fred_client
  confirm_continue || return
  step1_install_app_packages $APP_PACKAGES_FILE
  step2_copy_fred_configs
  draw_bar 100
  sleep 1
  print_message "OK: Nodo FRED APP instalado"   
  echo "Favor dirigirse a /etc/fred, y modificar/crear archivos de configuracion, con la informacion de base de datos y servidor omninames "
  print_notime "Recuerda inciar los demonios de FRED"
  pause
}
