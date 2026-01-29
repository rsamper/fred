#!/bin/bash
# Script: copyconf_fred.sh
# Description: Copia de archivos de configuracion local a /etc/fred
# Author: Ricardo Samper rsamper@nic.cr
# Date: 2026-01-10
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


copy_fred_configs() {
  print_message "Copiando archivos de configuracion FRED /etc/fred/Copying FRED config files"
  #rm /etc/fred/*.conf
  rm -rf /etc/fred/*
  cp -av ./configs/* /etc/fred
  print_message "OK: !!!!!"
}


init(){
  print_message  "Initialazing..."  
  print_message  "Init complete: Ok"
}


# Main function
main() {
   print_message  "Running"
   init
   copy_fred_configs
}

# Run main function
main