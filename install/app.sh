#!/bin/bash

# Script: script.sh
# Description: A new bash script
# Author: Your Name
# Date: 2025-10-10




install_fred_client(){
 echo "9. Installing FRED-Clients"
 echo "=============================="
 install fred-client -y
 mv /usr/lib/python3/dist-packages/fred/eppdoc.py  /usr/lib/python3/dist-packages/fred/eppdoc.py.ori
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
    print_message "INFO: No se encontraron paquetes DB válidos para instalar en el archivo '$*'...."
  fi
  print_message "OK: FRED APP Node!!!!!"
  
}
print_info_app(){
  clear
  read -r -d '' section << 'EOF'
 ================================================================ 
 La instalacion de FRED CORE se ejecuta en 3 pasos  
  1/3.  Instalar paquetes: Depedencias Python,Corba Servers 
  -Depedencias Python
  -Corba Servers 
  -Apache for EPP
  -Python Daemons
  -FRED Python libs
  -FRED Daemonds
  -Enable Apache Corba
  -Enable Apache EPP  
  2/3.  Habilitando Apache Modules  
  3/3.  Copiar archivos de configuracion
=================================================================
EOF
 print_section "$section"
 }
install_app(){
  if [ -z "$APP_PACKAGES_FILE" ]; then
    print_message "Error: APP_PACKAGES_FILE no está definido o está vacío."
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
