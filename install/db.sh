#!/bin/bash

# Script: script.sh
# Description: A new bash script
# Author: Your Name
# Date: 2025-10-10

#set -e  # Exit on any error
#set -u  # Exit on undefined variables
echo "Running DB script"

get_db_packages(){
    local cmd="$*"
    echo $cmd

    mapfile -t packages < <(grep -v '^#' "$*" | grep -v '^$')
    echo ${packages[@]}
   
}

install_db_packages(){
  print_message "1/2 Instalando paquetes necestarios"
  mapfile -t packages < <(grep -v '^#' "$*" | grep -v '^$')
  if [[ ${#packages[@]} -gt 0 ]]; then
    install ${packages[@]}  # Descomenta cuando estés listo para instalar
    print_message "OK: 2/2 Paquetes FRED DB ${packages[@]} instalados exitosamente"
  else
    print_message "INFO: No se encontraron paquetes DB válidos para instalar en el archivo '$*'."
  fi
}


create_db(){
  print_message "2/3 Creando la base de datos fred-dbmanager install"
  exec_command su - postgres -c "/usr/sbin/fred-dbmanager install"
  print_message "OK: Base de datos creada"
}

print_info_db(){
  clear
  print_notime "================================================="  
  print_notime "La instalacion de FRED DB se ejecuta en 3 pasos"  
  print_notime "1/2  Instalar Pauetes"  
  print_notime "2/2  Crear la base de datos FRED DB"  
  print_notime "=================================================="  
   
}
install_db(){
  clear 
  print_info_db  
  confirm_continue || return
  install_db_packages $DB_PACKAGES_FILE
  create_db
  print_message "OK: Base de datos instalada y creada correctamente" 
  print_message "Recuerda configurar la zona horaria en postgresql.conf y el archivo pg_hba.conf" 
  pause``
}
