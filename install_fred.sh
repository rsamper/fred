#!/bin/bash
# Script: install_fred.sh
# Description: Instalacion de fred
# Author: Ricardo Samper rsamper@nic.cr
# Date: 2025-10-10
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


log_file="install.log"
# scrips files 
HELPERS_PATH="helpers"
INSTALL_PATH="install"
PACKAGES_PATH="packages"
CONFIGS_PATH="configs"

UTILS_FILE="$SCRIPT_DIR/$HELPERS_PATH/utils.sh"
MENU_FILE="$SCRIPT_DIR/$HELPERS_PATH/menu.sh"
DB_FILE="$SCRIPT_DIR/$INSTALL_PATH/db.sh"
PRE_FILE="$SCRIPT_DIR/$INSTALL_PATH/pre.sh"
EPP_FILE="$SCRIPT_DIR/$INSTALL_PATH/epp.sh"
CLIENT_FILE="$SCRIPT_DIR/$INSTALL_PATH/client.sh"
APP_FILE="$SCRIPT_DIR/$INSTALL_PATH/app.sh"
WEB_FILE="$SCRIPT_DIR/$INSTALL_PATH/web.sh"
HM_FILE="$SCRIPT_DIR/$INSTALL_PATH/hm.sh"
MINIMAL_FILE="$SCRIPT_DIR/$INSTALL_PATH/minimal.sh"


##  packages files
DB_PACKAGES_FILE="$SCRIPT_DIR/$PACKAGES_PATH/db.packages"
PRE_PACKAGES_FILE="$SCRIPT_DIR/$PACKAGES_PATH/pre.packages"
APP_PACKAGES_FILE="$SCRIPT_DIR/$PACKAGES_PATH/app.packages"
CONFIGS_FILES="$SCRIPT_DIR/$CONFIGS_PATH/"
EPP_PACKAGES_FILE="$SCRIPT_DIR/$PACKAGES_PATH/epp.packages"
WEB_PACKAGES_FILE="$SCRIPT_DIR/$PACKAGES_PATH/web.packages"
HM_PACKAGES_FILE="$SCRIPT_DIR/$PACKAGES_PATH/hm.packages"
MINIMAL_PACKAGES_FILE="$SCRIPT_DIR/$PACKAGES_PATH/minimal.packages"

safe_source() {
  [ -f "$1" ] || {
    echo "Error: no se encuentra $1"
    exit 1
  }
  source "$1"
}


safe_source "$UTILS_FILE"
safe_source "$MENU_FILE"
safe_source "$DB_FILE"
safe_source "$PRE_FILE"
safe_source "$APP_FILE"
safe_source "$CLIENT_FILE"
safe_source "$EPP_FILE"

source "$UTILS_FILE"
source "$MENU_FILE"
source "$PRE_FILE"
  
#Check mandatory files

init_files(){
  print_message  "Revisando archivos necesarios/ Checking mandatory files..."
  check_file "$UTILS_FILE"
  check_file "$MENU_FILE"   
  check_file "$PRE_FILE"  
  check_file "$DB_FILE" 
  check_file "$APP_FILE" 
  check_file "$WEB_FILE" 
  check_file "$EPP_FILE" 
  check_file "$HM_FILE" 
  check_file "$MINIMAL_FILE" 
  
  check_file "$PRE_PACKAGES_FILE" 
  check_file "$DB_PACKAGES_FILE" 
  check_file "$APP_PACKAGES_FILE" 
  check_file "$WEB_PACKAGES_FILE" 
  check_file "$HM_PACKAGES_FILE" 
  check_file "$MINIMAL_PACKAGES_FILE" 
  print_message  "Ok!!!!!"
}


init_os(){
  print_message  "Check mandatory OS..."
  check_os
  check_root
  print_message  "OS: Ok"
}
init(){
  print_message  "Initialazing..."  
  init_files
  init_os
  print_message  "Init complete: Ok"
}

copy_fred_configs() {
  print_message "Copiando archivos de configuracion FRED /etc/fred"
  cp -av ./configs/* /etc/fred
  print_message "OK: Archivos de configuracion copiados !!!!!"
}

setup_envioroment(){
  install_pre
}

# Main function
main() {
   print_message  "Running"
   init
   setup_envioroment
   main_menu
}

# Run main function
main