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
  print_message "1/5.Setting CZ Keyring"
  exec_command  mkdir -p /usr/share/keyrings/
  exec_command  wget https://archive.nic.cz/dists/cznic-archive-keyring.gpg --output-document=/usr/share/keyrings/cznic-archive-keyring.gpg
  print_message "✅ OK: 1/5.Setting CZ Keyring"
}

add_source_list() {
  print_message "2/5. Adding CZ Source list"

  local FILE="/etc/apt/sources.list.d/fred.list"
  local LINE="deb [signed-by=/usr/share/keyrings/cznic-archive-keyring.gpg] http://archive.nic.cz/public $(lsb_release -sc) main"

  sudo touch "$FILE"

  if sudo grep -Fxq "$LINE" "$FILE"; then
    print_log_message "ℹ️ La fuente ya existe, no se agrega nuevamente."
  else
    echo "$LINE" | sudo tee -a "$FILE" > /dev/null
    print_log_message "✅ Fuente agregada correctamente."
  fi

  print_message "✅ OK: 2/5. Adding CZ Source list"
}


add_source_list_old(){
# Setp 2
# FRED Source list
# Add source list for FRED
print_message "2/5.Adding CZ Source list"

if [ ! -f /etc/apt/sources.list.d/fred.list ]; then
cat << EOT >> /etc/apt/sources.list.d/fred.list
deb [signed-by=/usr/share/keyrings/cznic-archive-keyring.gpg] http://archive.nic.cz/public $(lsb_release -sc) main
EOT
fi
if grep -q "http://archive.nic.cz/public" /etc/apt/sources.list.d/fred.list; then
  print_log_message "✅ Fuente agregada correctamente."
else
  QUIET_MODE=false
  print_log_message "❌ No se encontró la línea en fred.list."
  exit 1
fi
print_message "✅ OK: 2/5.Adding CZ Source list"
}

fix_pin() {
  print_message "3.1/5. Actualizando :( CZ PIN file"
  PIN_FILE="/etc/apt/preferences.d/fred"

sudo tee -a "$PIN_FILE" > /dev/null << 'EOF'
Package: python-pyfred
Pin: version 2.15.1*
Pin-Priority: 1001
EOF
}

set_pin(){
 # Setp 3
 # FRED CZ PIN
 # Create pin file
  print_message "3/5.Setting CZ PIN file"
  exec_command wget https://fred.nic.cz/media/filer_public/71/ce/71ce3145-a4bb-4583-9ff2-218627d71d5f/20241fredpreferencesd.txt -O /etc/apt/preferences.d/fred
  fix_pin
  print_message "✅ OK: 3/5.Setting CZ PIN file"
}

apt_update(){
 # Setp 4
 # Update sources
  print_message "4/5. Update sources"
  exec_command  apt update
  print_message "✅ OK: 4/5.Update sources"
}

set_postfix(){
  debconf-set-selections <<< "postfix postfix/mailname string $(hostname)"
  debconf-set-selections <<< "postfix postfix/main_mailer_type string Internet Site"
}
install_packages(){
  
  mapfile -t packages < <(grep -v '^#' "$*" | grep -v '^$')
  print_message "5/5. Instalando: ${packages[@]}" 
  #install ${packages[@]}
  print_message "✅ OK: 5/5 Pre Requisitos  ${packages[@]} instalados exitosamente"  
}

print_info_pre(){
  clear
  print_notime "============================================================"  
  print_notime "La instalacion de pre requisitos FRED se ejecuta en 5 pasos"  
  print_notime "1/5.  Configurar Keyring para los repositorios FRED"  
  print_notime "2/5.  Agregar repositorios apt"  
  print_notime "3/5.  Configurar archivo pin para descargar los paquetes correctos "  
  print_notime "4/5.  Actualizar repos FRED"  
  print_notime "5/5.  Instalar paquetes necesarios FRED"
  print_notime "============================================================"  
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
  install_packages $PRE_PACKAGES_FILE
  print_message "✅ OK: Requisitos instalados exitosamente" 
  pause 
}



