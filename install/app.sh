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

copy_fred_conf(){
 echo "10. Copy conf files"
 echo "=============================="
 apt_install fred-client -y
 mv /usr/lib/python3/dist-packages/fred/eppdoc.py mv /usr/lib/python3/dist-packages/fred/eppdoc.py.ori
 exec_command wget https://gitlab.nic.cz/fred/client/-/raw/master/fred/eppdoc.py?ref_type=heads -O /usr/lib/python3/dist-packages/fred/eppdoc.py

}

install_fred_client(){
 echo "9. Installing FRED-Clients"
 echo "=============================="
 apt_install fred-client -y
 mv /usr/lib/python3/dist-packages/fred/eppdoc.py mv /usr/lib/python3/dist-packages/fred/eppdoc.py.ori
 exec_command wget https://gitlab.nic.cz/fred/client/-/raw/master/fred/eppdoc.py?ref_type=heads -O /usr/lib/python3/dist-packages/fred/eppdoc.py

}

enable_apache_epp(){
  print_message "8. Habilitando apache for EPP"
  cd /etc/apache2/sites-available/
  a2ensite 02-fred-mod-eppd-apache.conf
  exec_command a2enmod ssl
  
  exec_command systemctl restart apache2
  exec_command systemctl is-active apache2
  print_message "✅ OK: Apache habilitado."
}

enable_apache_corba(){
  print_message "7. Habilitando apache for corba"
  exec_command a2enmod corba
  exec_command systemctl restart apache2
  print_message "✅ OK: Apache Corba habilitado"
}


install_fred_daemons(){
  print_message "6.Instalando FRED daemonds"
  print_message "✅ OK: FRED FRED daemonds"
}

install_fred_python_libs(){
  print_message "5.Instalando FRED Python libs"
  print_message "✅ OK: FRED Python libs"
}

install_python_daemons(){
  print_message "4.Instalando Python Daemons"
  print_message "✅ OK: Python Daemons Instalados"
}

install_apache_server(){
  print_message "3.Instalando Apache for EPP"
  print_message "✅ OK: Apache EPP. Instalado"
  #apt_install apache2 libapache2-mod-corba libapache2-mod-eppd
}

install_corba_server(){
  print_message "2.Instalando Corba Server Omninames"
  print_message "✅ OK: Omninames Instalado"
 
} 

install_python_dependencies(){
  print_message "1.Instalando dependencias pyhton"
  print_message "✅ OK: Dependencias Python instaladas"
  
}

print_info_app(){
  clear
  print_notime "================================================="  
  print_notime "La instalacion de FRED CORE se ejecuta en 3 pasos"  
  print_notime "1/3.  Instalar Depedencias Python"  
  print_notime "2/3.  Instalar Corba Servers"  
  print_notime "3/3.  Instalar Apache for EPP"
  print_notime "4/3.  Instalar Python Daemons"
  print_notime "5/3.  Instalar FRED Python libs"
  print_notime "6/3.  Instalar FRED Daemonds"
  print_notime "7/3.  Instalar Enable Apache Corba"  
  print_notime "8/3.  Instalar Enable Apache EPP"  
  print_notime "9/3.  Instalar FRED Client"  
  print_notime "10/3.  Copiando archvios de configuracion"  
  print_notime "=================================================="  
  pause
}
install_app(){
  clear 
  print_info_app  
  install_python_dependencies
  install_corba_servers
  install_apache_server
  install_python_daemons
  install_fred_python_libs
  install_fred_daemonds
  install_apache_epp
  enable_apache_corba
  enable_apache_epp
  install_fred_client
  install_app_packages $APP_PACKAGES_FILE
  print_message "✅ OK: FRED CORE instalado"   
  echo "Favor dirigirse a /etc/fred"
  echo "Y modificar/crear archivos de configuracion"
  print_message "Recuerda inciar los demonios de FRED" 
}
