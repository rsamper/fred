#!/bin/bash
# Script: install_fred.sh
# Description: Instalacion de fred
# Author: Ricardo Samper rsamper@nic.cr
# Date: 2025-10-10

#set -e  # Exit on any error
#set -u  # Exit on undefined variables

# recupera la ruta desde donde se ejecuta el script
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
QUIET_MODE=false

while [[ "$1" == "--quiet" ]]; do
    QUIET_MODE=true
    shift # Remueve el primer parámetro (que es "--quiet")
done

# 2. Validar Parámetros Posicionales (obligatorios)

# Ahora, $# contiene la cuenta SÓLO de los parámetros posicionales restantes.
if [ "$#" -lt 1 ]; then
    echo "Error: Debe proporcionar al menos un parámetro." >&2
    echo "Parámetros válidos: db, core, client, omni" >&2
    echo "Ejemplo: bash instalar_fred.sh db" >&2
    echo "Ejemplo silencioso: bash instalar_fred.sh --quiet db" >&2
    exit 1
fi


# Si se llega a esta parte, significa que se pasó al menos un parámetro.

############# root
#if [ "$EUID" -ne 0 ]
#  then echo "Please run installation as root."
#  exit
#fi


echo "Ejecutando desde la ruta $SCRIPT_DIR"
log_file="install.log"
# scrips files 
#GUM_FILE="$SCRIPT_DIR/install_gum.sh"
HELPERS_PATH="helpers"
INSTALL_PATH="install"
PACKAGES_PATH="packages"
UTILS_FILE="$SCRIPT_DIR/$HELPERS_PATH/utils.sh"
DB_FILE="$SCRIPT_DIR/$INSTALL_PATH/db.sh"
PRE_FILE="$SCRIPT_DIR/$INSTALL_PATH/pre.sh"
OMNI_FILE="$SCRIPT_DIR/$INSTALL_PATH/pre.sh"
CLIENT_FILE="$SCRIPT_DIR/$INSTALL_PATH/client.sh"
CORE_FILE="$SCRIPT_DIR/$INSTALL_PATH/core.sh"



##  packages files
DB_PACKAGES_FILE="$SCRIPT_DIR/$PACKAGES_PATH/db.packages"
PRE_PACKAGES_FILE="$SCRIPT_DIR/$PACKAGES_PATH/pre.packages"
#FRED_FILE="$SCRIPT_DIR/freddb.sh"
#CORE_PACKAGES_FILE="$SCRIPT_DIR/core.packages"
#CLIENT_PACKAGES_FILE="$SCRIPT_DIR/client.packages"
#OMNI_PACKAGES_FILE="$SCRIPT_DIR/omni.packages"


#Check mandatory files

init_files(){
  print_message  "Check mandatory files..."
  check_file "$UTILS_FILE"  
  check_file "$PRE_FILE"  
  check_file "$DB_FILE" 
  check_file "$PRE_PACKAGES_FILE" 
  check_file "$DB_PACKAGES_FILE" 
  print_message  "Mandatory files: Ok"
}

init_os(){
  print_message  "Check mandatory OS..."
  #check_os
  #check_root
  print_message  "OS: Ok"
}
init(){
  print_message  "Initialazing..."  
  init_files
  init_os
  print_message  "Init complete: Ok"
}

source "$UTILS_FILE"
source "$DB_FILE"
source "$PRE_FILE"
###############################################################

#mapfile -t packages < <(grep -v '^#' "$DB_PACKAGES_FILE" | grep -v '^$')
#echo ${packages[@]}

select_package(){
  case $1 in
      db)
          install_pre
          print_message "Instalando base de datos"
          ;;
      core )
          install_pre
          echo "FRED CORE"
          ;;
      client )
          install_pre
          echo "FRED CLIENT"
          ;;
      omni )
          install_pre
          echo "OMNI NAMES"
          ;;
      *)
         echo "Parámetro recibido: $1"
          ;;
  esac
}

# Main function
main() {
   clear 
   print_message  "Script running"
   init
   pause
   select_package $1
   #
}

# Run main function
main "$@"







##########################################################################

   #echo "Parámetro recibido: $1"    
   #get_packages $DB_PACKAGES_FILE


#if [ ! -f "$GUM_FILE" ]; then
#    echo "❌ El archivo $GUM_FILE no existe."
#    echo "End exit code 1"
#    exit 1
#fi


#if [ ! -f "$DB_PACKAGES_FILE" ]; then
#    echo "$(timestamp) ❌ El archivo $DB_PACKAGES_FILE no existe"
#    echo "End exit code 1"
#    exit 1
#fi




# Valida entrada ya que debe traer parametros
#if [ "$#" -lt 1 ]; then
#    echo "Error: Debe proporcionar al menos un parámetro" >&2 # Mostrar el error en stderr
#    echo "Para metros validos: db core client omni" >&2 # Mostrar el error en stderr
#    echo "Ejemplo instalar base de datos:  bash instalar_fred db" >&2 # Mostrar el error en stderr
#    exit 1 # Salir con un código de error
#fi

#for arg in "$@"; do
#    if [[ "$arg" == "--quiet" ]]; then
#        QUIET_MODE=true
#        break # No necesitamos seguir revisando
#    fi
#done