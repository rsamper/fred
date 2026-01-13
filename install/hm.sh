#!/bin/bash

# Script: script.sh
# Description: A new bash script
# Author: Your Name
# Date: 2025-10-10



step1_install_hm_packages(){
  draw_bar 0
  sleep 1
  print_message "1.Instalando paquetes FRED EPP Node"
  mapfile -t packages < <(grep -v '^#' "$*" | grep -v '^$')
  if [[ ${#packages[@]} -gt 0 ]]; then
    install ${packages[@]}  # Descomenta cuando estés listo para instalar
    print_message "OK: Paquetes FRED APP ${packages[@]} instalados exitosamente !!!!"
  else
    print_message "INFO: No se encontraron paquetes válidos para instalar en el archivo '$*'..."
  fi
  print_message "1/2 OK: FRED FRED Node!!!!!"
  }

print_info_hm(){
  clear

read -r -d '' section << 'EOF'
  ===================================================================
   La instalacion de FRED HM Hidden Master se ejecuta en 1 pasos  
   1/1.  Instalar paquetes: Instalar Apache y Modulo HM"  
  ===================================================================
EOF
 print_section "$section"
 
  
  }


install_hm(){
    if [ -z "$HM_PACKAGES_FILE" ]; then
    print_message "Error: HM_PACKAGES_FILE no está definido o está vacío."
    exit 1
  fi
  clear 
  print_info_hm
  confirm_continue || return 
  step1_install_hm_packages $EPP_PACKAGES_FILE
  #step2_enable_apache_modules
  draw_bar 100
  sleep 1 
  print_notime "OK: Nodo HM instalado !!!!!"   
  pause
}
