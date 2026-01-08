#!/bin/bash

# Script: script.sh
# Description: A new bash script
# Author: Your Name
# Date: 2025-10-10




step1_install_db_packages(){
  print_message "1/2 Instalando paquetes necesarios"
  draw_bar 0
  sleep 1
  
  mapfile -t packages < <(grep -v '^#' "$*" | grep -v '^$')
  if [[ ${#packages[@]} -gt 0 ]]; then
    install ${packages[@]}  # Descomenta cuando estés listo para instalar
    print_message "OK: 1/2 Paquetes FRED DB ${packages[@]} instalados exitosamente !!!!!"
  else
    print_message "INFO: No se encontraron paquetes DB válidos para instalar en el archivo '$*'..."
  fi
  sleep 2
}


step2_create_database(){
  draw_bar 50
  sleep 1
  print_message "2/2 Creando la base de datos fred-dbmanager install"
  exec_command su - postgres -c "/usr/sbin/fred-dbmanager install"
  print_message "OK: Base de datos creada exitosamente !!!!!"
}

print_info_db(){
  clear
  read -r -d '' section << 'EOF'
=================================================
La instalación de FRED DB se ejecuta en 2 pasos
1/2  Instalar Paquetes Postgres y FRED DB
2/2  Crear la base de datos FRED DB
=================================================
EOF
print_section "$section" 
}

install_db(){
   if [ -z "$DB_PACKAGES_FILE" ]; then
    print_message "Error: DB_PACKAGES_FILE no está definido o está vacío."
    exit 1
  fi

  clear 
  print_info_db  
  confirm_continue || return
  step1_install_db_packages "$DB_PACKAGES_FILE"
  step2_create_database
  draw_bar 100
  sleep 1
  print_message "OK: Base de datos instalada y creada correctamente !!!!!" 
  print_notime "Recuerda configurar la zona horaria en postgresql.conf y el archivo pg_hba.conf" 
  pause
}
