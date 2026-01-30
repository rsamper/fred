#!/bin/bash

# Script: script.sh
# Description: A new bash script
# Author: Your Name
# Date: 2025-10-10



step2_copy_fred_configs(){
  print_message "1.Instalando FRED APP Node"
  draw_bar 50
  sleep 1
  copy_fred_configs
  print_message "OK: FRED APP Node!!!!!"
  
}

step1_install_minimal_packages(){
  print_message "1.Instalando FRED APP Minimal Node"
  draw_bar 0
  sleep 1
  mapfile -t packages < <(grep -v '^#' "$*" | grep -v '^$')
  if [[ ${#packages[@]} -gt 0 ]]; then
    install ${packages[@]}  # Descomenta cuando estés listo para instalar
    print_message "OK: Paquetes FRED APP Minimal ${packages[@]} instalados exitosamente !!!!!"
  else
    print_message "INFO: No se encontraron paquetes válidos para instalar en el archivo '$*'...."
  fi
  print_message "OK: FRED APP Minimal Node!!!!!"
  
}
print_info_app(){
  clear
  read -r -d '' section << 'EOF'
 ================================================================ 
 La instalacion de FRED CORE se ejecuta en 2 pasos  
  1/3.  Instalar paquetes: Depedencias Python,Corba Servers 
  -Depedencias Python
  -FRED Daemonds
  -Enable Apache Corba
  -Enable Apache EPP  
  2/2.  Copiar archivos de configuracion
=================================================================
EOF
 print_section "$section"
 }
install_minimal(){
  if [ -z "$MINIMAL_PACKAGES_FILE" ]; then
    print_message "Error: MINIMAL_PACKAGES_FILE no está definido o está vacío."
    exit 1
  fi
  clear 
  print_info_app  
  #install_fred_client
  confirm_continue || return
  step1_install_minimal_packages $MINIMAL_PACKAGES_FILE
  step2_copy_fred_configs
  draw_bar 100
  sleep 1
  print_message "OK: Nodo FRED APP Minimal instalado"   
  echo "Favor dirigirse a /etc/fred, y modificar/crear archivos de configuracion, con la informacion de base de datos y servidor omninames "
  print_notime "Recuerda inciar los demonios de FRED"
  pause
}
