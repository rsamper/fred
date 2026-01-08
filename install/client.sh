#!/bin/bash

# Script: script.sh
# Description: A new bash script
# Author: Your Name
# Date: 2025-10-10

install_fred_client(){
 echo "9. Installing FRED-Clients"
 echo "=============================="
 install fred-client -y
 mv /usr/lib/python3/dist-packages/fred/eppdoc.py /usr/lib/python3/dist-packages/fred/eppdoc.py.ori
 exec_command wget https://gitlab.nic.cz/fred/client/-/raw/master/fred/eppdoc.py?ref_type=heads -O /usr/lib/python3/dist-packages/fred/eppdoc.py

}



print_info_client(){
  clear
  print_notime "================================================="  
  print_notime "Instalacion de FRED CLIENT se ejecuta en 3 pasos"  
  
  print_notime "=================================================="  
  pause 
}
install_client(){
  clear 
  print_info_client  
  install_fred_client
  print_message "OK: FRED CLIENT instalado"   
  echo "Favor dirigirse a /etc/fred"
  echo "Y modificar/crear archivos de configuracion"
  
}
