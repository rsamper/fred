#!/bin/bash

# Script: script.sh
# Description: A new bash script
# Author: Your Name
# Date: 2025-10-10

#set -e  # Exit on any error
#set -u  # Exit on undefined variables
echo "Running DB script"

get_packages(){
    local cmd="$*"
    echo $cmd

    mapfile -t packages < <(grep -v '^#' "$*" | grep -v '^$')
    echo ${packages[@]}
    print_message "dbbbbbb"
}

install_db_packages(){
  mapfile -t packages < <(grep -v '^#' "$*" | grep -v '^$')
  if [[ ${#packages[@]} -gt 0 ]]; then
    print_message "Instalando: ${packages[@]}" 
    install ${packages[@]}  # Descomenta cuando estés listo para instalar
    print_message "✅ OK: 3/3 Paquetes FRED DB ${packages[@]} instalados exitosamente"
  else
    print_message "ℹ️ INFO: No se encontraron paquetes DB válidos para instalar en el archivo '$*'."
  fi
}


create_db(){
  print_message "Creando la base de datos fred-dbmanager install"
  exec_command su - postgres -c "/usr/sbin/fred-dbmanager install"
  print_message "✅ OK: Base de datos creada"
}

print_info_db(){
  clear
  print_notime "================================================="  
  print_notime "La instalacion de FRED DB se ejecuta en 3 pasos"  
  print_notime "1/3.  Instalar PostFix"  
  print_notime "2/3.  Instalar la base de datos PostgreSQL"  
  print_notime "3/3.  Instalar el paquete FRED DB"  
  print_notime "=================================================="  
  pause
}
install_db(){
  clear 
  print_info_db  
  install_db_packages $DB_PACKAGES_FILE
  create_db
  print_message "✅ OK: Base de datos instalada y creada correctamente" 
  print_message "Recuerda configurar la zona horaria en postgresql.conf y el archivo pg_hba.conf" 
}
