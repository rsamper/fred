#!/bin/bash
# Script: pre.sh
# Description: Instala pre requisitos de FRED
# Author: Ricardo Samper rsamper@nic.cr
# Date: 2025-10-10

#set -e  # Exit on any error
#set -u  # Exit on undefined variables

print_message "Incluyendo pre.sh"

set_keyring(){
  # Setp 1
  # Create keyring
  print_message "1.Setting CZ Keyring"
  exec_command  mkdir -p /usr/share/keyrings/
  exec_command  wget https://archive.nic.cz/dists/cznic-archive-keyring.gpg --output-document=/usr/share/keyrings/cznic-archive-keyring.gpg
  print_message "✅ OK: 1.Setting CZ Keyring"
}

add_source_list(){
# Setp 2
# FRED Source list
# Add source list for FRED
print_message "2.Adding CZ Source list"

if [ ! -f /etc/apt/sources.list.d/fred.list ]; then
cat << EOT >> /etc/apt/sources.list.d/fred.list
deb [signed-by=/usr/share/keyrings/cznic-archive-keyring.gpg] http://archive.nic.cz/public $(lsb_release -sc) main
EOT
fi
if grep -q "http://archive.nic.cz/public" /etc/apt/sources.list.d/fred.list; then
  print_message "✅ Fuente agregada correctamente."
else
  print_message "❌ No se encontró la línea en fred.list."
fi
print_message "✅ OK: 2.Adding CZ Source list"
}

set_pin(){
 # Setp 3
 # FRED CZ PIN
 # Create pin file
  print_message "3.Setting CZ PIN file"
  exec_command wget https://fred.nic.cz/media/filer_public/71/ce/71ce3145-a4bb-4583-9ff2-218627d71d5f/20241fredpreferencesd.txt -O /etc/apt/preferences.d/fred
  print_message "✅ OK: 3.Setting CZ PIN file"
}

apt_update(){
 # Setp 4
 # Update sources
  print_message "4.Update souces"
  exec_command  apt update
  print_message "✅ OK: 4.Update sources"
}

set_postfix(){
  debconf-set-selections <<< "postfix postfix/mailname string $(hostname)"
  debconf-set-selections <<< "postfix postfix/main_mailer_type string Internet Site"
}
install_packages(){
  mapfile -t packages < <(grep -v '^#' "$*" | grep -v '^$')
  print_message "Instalando ${packages[@]}" 
  install ${packages[@]}
  print_message "✅ OK: PRE Requisitos instalados exitosamente"  
}
install_pre(){
  print_message "Ejecutando pre.sh"  
  print_message "Instalando pre requisitos"  
  set_keyring
  add_source_list
  set_pin
  set_postfix
  apt_update
  install_packages $PRE_PACKAGES_FILE
  print_message "✅ OK: Requisitos instalados exitosamente"  
}



