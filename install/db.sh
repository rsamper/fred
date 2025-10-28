#!/bin/bash

# Script: script.sh
# Description: A new bash script
# Author: Your Name
# Date: 2025-10-10

#set -e  # Exit on any error
#set -u  # Exit on undefined variables

get_packages(){
    local cmd="$*"
    echo $cmd

    mapfile -t packages < <(grep -v '^#' "$*" | grep -v '^$')
    echo ${packages[@]}
    print_message "dbbbbbb"
}

install_packages(){
  
  mapfile -t packages < <(grep -v '^#' "$*" | grep -v '^$')
  print_message "5/5. Instalando: ${packages[@]}" 
  #install ${packages[@]}
  print_message "✅ OK: 5/5 Pre Requisitos  ${packages[@]} instalados exitosamente"  
}

print_info_pre(){
  clear
  print_notime "La instalacion de pre requisitos FRED se ejecuta en 5 pasos"  
  print_notime "1/5.  Configurar Keyring para los repositorios FRED"  
  print_notime "2/5.  Agregar repositorios apt"  
  print_notime "3/5.  Configurar archivo pin para descargar los paquetes correctos "  
  print_notime "4/5.  Actualizar repos FRED"  
  print_notime "5/5.  Instalar paquetes necesarios FRED"
  pause
}
install_pre(){
  print_message "Ejecutando pre.sh"  
  print_message "Instalando pre requisitos" 
  print_info_pre
 
  set_keyring
  add_source_list
  set_pin
  set_postfix  
  apt_update
  install_packages $DB_PACKAGES_FILE
  print_message "✅ OK: Requisitos instalados exitosamente" 
  pause 
}
