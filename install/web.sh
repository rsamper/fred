#!/bin/bash

# Script: script.sh
# Description: A new bash script
# Author: Your Name
# Date: 2025-10-10


step2_enable_apache_modules(){
  print_message "2. Habilitando Apache WhoIS y Corba"
  draw_bar 50
  sleep 1
  cd /etc/apache2/sites-available/
  a2ensite 02-fred-mod-eppd-apache.conf
  a2ensite 02-fred-mod-whoisd-apache
  exec_command a2enmod ssl
  exec_command a2enmod corba
  exec_command a2enmod whoisd
  exec_command systemctl restart apache2
  exec_command systemctl is-active apache2
  print_message "2/2 OK: Apache habilitado !!!!!"
}


step1_install_web_packages(){
  draw_bar 0
  sleep 1
  print_message "1.Instalando paquetes FRED Web Node"
  mapfile -t packages < <(grep -v '^#' "$*" | grep -v '^$')
  if [[ ${#packages[@]} -gt 0 ]]; then
    install ${packages[@]}  # Descomenta cuando estés listo para instalar
    print_message "OK: Paquetes FRED Web ${packages[@]} instalados exitosamente !!!!"
  else
    print_message "INFO: No se encontraron paquetes  válidos para instalar en el archivo '$*'..."
  fi
  print_message "1/2 OK: FRED Web Node!!!!!"
  }

print_info_web(){
  clear

read -r -d '' section << 'EOF'
  ===================================================================
   La instalacion de FRED Web se ejecuta en 2 pasos  
   1/2.  Instalar paquetes: Instalar Apache y Modulo WhoIs y Corba"  
   2/2.  Habilitar Modulos de Apache
  ===================================================================
EOF
 print_section "$section"
 
  
  }


install_web(){
    if [ -z "$WEB_PACKAGES_FILE" ]; then
    print_message "Error: WEB_PACKAGES_FILE no está definido o está vacío."
    exit 1
  fi
  clear 
  print_info_web
  confirm_continue || return 
  step1_install_web_packages $web_PACKAGES_FILE
  step2_enable_apache_modules
  draw_bar 100
  sleep 1 
  print_notime "OK: Nodo Web instalado !!!!!"   
  pause
}
