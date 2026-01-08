#!/bin/bash
# Script: install_fred.sh
# Description: Instalacion de fred
# Author: Ricardo Samper rsamper@nic.cr
# Date: 2025-10-10

#set -e  # Exit on any error
#set -u  # Exit on undefined variables

# recupera la ruta desde donde se ejecuta el script
#SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

#QUIET_MODE=false

#while [[ "$1" == "--quiet" ]]; do
#    QUIET_MODE=true
#    shift # Remueve el primer parámetro (que es "--quiet")
#done

# 2. Validar Parámetros Posicionales (obligatorios)

# Ahora, $# contiene la cuenta SÓLO de los parámetros posicionales restantes.
#if [ "$#" -lt 1 ]; then
#    echo "Error: Debe proporcionar al menos un parámetro." >&2
#    echo "Parámetros válidos: db, core, client, omni" >&2
#    echo "Ejemplo: bash instalar_fred.sh db" >&2
#    echo "Ejemplo silencioso: bash instalar_fred.sh --quiet db" >&2
#    exit 1
#fi


# Si se llega a esta parte, significa que se pasó al menos un parámetro.

############# root
#if [ "$EUID" -ne 0 ]
#  then echo "Please run installation as root."
#  exit
#fi


#echo "Ejecutando desde la ruta $SCRIPT_DIR"

log_file="install.log"
# scrips files 
#GUM_FILE="$SCRIPT_DIR/install_gum.sh"
HELPERS_PATH="helpers"
INSTALL_PATH="install"
PACKAGES_PATH="packages"
CONFIGS_PATH="configs"

UTILS_FILE="$SCRIPT_DIR/$HELPERS_PATH/utils.sh"
MENU_FILE="$SCRIPT_DIR/$HELPERS_PATH/menu.sh"
TUI_FILE="$SCRIPT_DIR/$HELPERS_PATH/whip.sh"
DB_FILE="$SCRIPT_DIR/$INSTALL_PATH/db.sh"
PRE_FILE="$SCRIPT_DIR/$INSTALL_PATH/pre.sh"
OMNI_FILE="$SCRIPT_DIR/$INSTALL_PATH/pre.sh"
EPP_FILE="$SCRIPT_DIR/$INSTALL_PATH/epp.sh"
CLIENT_FILE="$SCRIPT_DIR/$INSTALL_PATH/client.sh"
APP_FILE="$SCRIPT_DIR/$INSTALL_PATH/app.sh"



##  packages files
DB_PACKAGES_FILE="$SCRIPT_DIR/$PACKAGES_PATH/db.packages"
PRE_PACKAGES_FILE="$SCRIPT_DIR/$PACKAGES_PATH/pre.packages"
#FRED_FILE="$SCRIPT_DIR/freddb.sh"
APP_PACKAGES_FILE="$SCRIPT_DIR/$PACKAGES_PATH/app.packages"
CONFIGS_FILES="$SCRIPT_DIR/$CONFIGS_PATH/"
EPP_PACKAGES_FILE="$SCRIPT_DIR/$PACKAGES_PATH/epp.packages"

#CLIENT_PACKAGES_FILE="$SCRIPT_DIR/client.packages"
#OMNI_PACKAGES_FILE="$SCRIPT_DIR/omni.packages"

#Check mandatory files

init_files(){
  print_message  "Revisando archivos necesarios/ Checking mandatory files..."
  check_file "$UTILS_FILE"
  check_file "$MENU_FILE"  
  check_file "$TUI_FILE"  
  check_file "$PRE_FILE"  
  check_file "$DB_FILE" 
  check_file "$PRE_PACKAGES_FILE" 
  check_file "$DB_PACKAGES_FILE" 
  print_message  "Ok!!!!!"
}

#mapfile -t packages < <(grep -v '^#' "$DB_PACKAGES_FILE" | grep -v '^$')
#echo ${packages[@]}



#select_package(){
#  echo "$1"
#  pause
#  case $1 in
#      DataBase)
#          install_pre
#          install_db
#          print_notime "Bye"
#          exit 0
#          ;;
#      app )
#          install_pre
#          echo "FRED APP"
#          install_app
#          ;;
#      client )
#          install_pre
#          install_client
#          echo "FRED CLIENT"
#          ;;
#      omni )
#          install_pre
#          echo "OMNI NAMES"
#          ;;
#      epp )
#           echo "epp"
#          install_pre
#          install_epp
#          echo "EPP Server"
#          ;;
#      config )
#          echo "Copiando archivos de configuracion"
#          copy_fred_configs    
#          ;;

#      *)
#         echo "Parámetro recibido: $1"
#          ;;
#  esac
#}

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
  #cp -av ./configs/* /etc/fred
  print_message "OK: Archivos de configuracion copiados !!!!!"
}

source "$UTILS_FILE"
source "$MENU_FILE"
source "$TUI_FILE"


source "$DB_FILE"
source "$PRE_FILE"
source "$APP_FILE"
source "$CLIENT_FILE"
source "$EPP_FILE"
source "$TUI_FILE"

###############################################################

#mapfile -t packages < <(grep -v '^#' "$DB_PACKAGES_FILE" | grep -v '^$')
#echo ${packages[@]}



#select_package(){
#  echo "$1"
#  pause
#  case $1 in
#      DataBase)
#          install_pre
#          install_db
#          print_notime "Bye"
#          exit 0
#          ;;
#      app )
#          install_pre
#          echo "FRED APP"
#          install_app
#          ;;
#      client )
#          install_pre
#          install_client
#          echo "FRED CLIENT"
#          ;;
#      omni )
#          install_pre
#          echo "OMNI NAMES"
#          ;;
#      epp )
#           echo "epp"
#          install_pre
#          install_epp
#          echo "EPP Server"
#          ;;
#      config )
#          echo "Copiando archivos de configuracion"
#          copy_fred_configs    
#          ;;

#      *)
#         echo "Parámetro recibido: $1"
#          ;;
#  esac
#}



# Main function
main() {
   print_message  "Script running"
   print_message $SCRIPT_DIR
   init
   main_menu
   
   exit 0
}

# Run main function
main "$@"