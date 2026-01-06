#!/bin/bash
# Script: util.sh
# Description: Funciones generales utiles
# Author: Ricardo Samper rsamper@nic.cr
# Date: 2025-10-10


greenting(){
 whiptail --title "NIC CR FRIENDLY FRED INSTALLER" \
         --backtitle "NIC CR" \
         --msgbox "Bienvenido a la instalacion de FRED Registry" 7 40
}

greenting_menu(){
 whiptail --title "NIC CR FRIENDLY FRED INSTALLER" \
         --backtitle "NIC CR" \
         --msgbox "Para iniciar debes seleccionar el componente a instalar" 7 60
}

main_menu(){
ans=$(whiptail --title "MENU" \
               --menu "Elige una opción" 15 80 5 \
               "DataBase" "Instala componentes y crea la base de datos FRED" \
               "Core" "Instala los componentes basicos, para del Registry - FRED CORE" \
               "EPP" "Instala el Servidor EPP" \
               "Client" "Instala FRED-Client" \
               3>&1 1<&2 2>&3)
 echo $ans
}

database_dialog(){
ans=$(whiptail --title "MENU" \
               --menu "Elige una opción" 15 80 5 \
               "DB" "Instala componentes y crea la base de datos FRED" \
               "Core" "Instala los componentes basicos, para del Registry - FRED CORE" \
               "EPP" "Instala el Servidor EPP" \
               "Client" "Instala FRED-Client" \
               3>&1 1<&2 2>&3)
 echo $ans
}

app_dialog(){
ans=$(whiptail --title "MENU" \
               --menu "Elige una opción" 15 80 5 \
               "Base de datos" "Instala componentes y crea la base de datos FRED" \
               "Core" "Instala los componentes basicos, para del Registry - FRED CORE" \
               "EPP" "Instala el Servidor EPP" \
               "Client" "Instala FRED-Client" \
               3>&1 1<&2 2>&3)
  echo $ans
}

epp_dialog(){
ans=$(whiptail --title "MENU" \
               --menu "Elige una opción" 15 80 5 \
               "Base de datos" "Instala componentes y crea la base de datos FRED" \
               "Core" "Instala los componentes basicos, para del Registry - FRED CORE" \
               "EPP" "Instala el Servidor EPP" \
               "Client" "Instala FRED-Client" \
               3>&1 1<&2 2>&3)
 echo $ans
}

additonal_menu(){
ans=$(whiptail --title "MENU" \
               --menu "Elige una opción" 15 80 5 \
               "Base de datos" "Instala componentes y crea la base de datos FRED" \
               "Core" "Instala los componentes basicos, para del Registry - FRED CORE" \
               "EPP" "Instala el Servidor EPP" \
               "Client" "Instala FRED-Client" \
               3>&1 1<&2 2>&3)
 echo $ans
}


#whiptail --title "NIC CR" \
#         --infobox "Bienvenido" 7 40
#########################
#TERM=vt220
#whiptail --title "https://atareao.es" \
#         --backtitle "Mensaje de fondo" \
#         --infobox "Este es el mensaje que se muestra" 7 40

#########################################################3
#TERM=vt220
#whiptail --title "NIC CR" \
#         --backtitle "Mensaje de fondo" \
#         --infobox "Este es el mensaje que se muestra" 7 40 

#whiptail --title "https://atareao.es" \
#         --msgbox "Este es el mensaje que se muestra" 7 40

##########################3
#whiptail --title "https://atareao.es" \
#         --yesno "¿Quiere continuar?" 7 40
#######################################################
#whiptail --title "https://atareao.es" \
#         --yesno "¿Quiere continuar?" 7 40
#ans=$?
#echo $ans
#if [ $ans -eq 0 ]
#then
#    echo "Respondió si"
#else
#    echo "Respondió no"
#fi


######################33
#respuesta=$(whiptail --title "https://atareao.es" \
#                     --inputbox "¿Cual es tu nombre?" 7 40 Pepe \
#                     3>&1 1>&2 2>&3)
#status=$?
#if [ $status = 0 ]
#then
#    echo "Tu nombre es: $respuesta"
#else
#    echo "No me has querido decir el nombre"
#fi

##########################3
#ans=$(whiptail --title "https://atareao.es" \
#               --radiolist "Elige un color" 10 80 4 \
#               "AZUL" "azul" OFF \
#               "ROJO" "rojo" OFF \
#               "GRIS" "gris" ON \
#               "LILA" "lila" OFF \
#               3>&1 1<&2 2>&3)
#echo $ans
################################
#ans=$(whiptail --title "https://atareao.es" \
#               --checklist "Elige uno o varios colores" 10 80 4 \
#               "AZUL" "azul" OFF \
#               "ROJO" "rojo" ON \
#               "GRIS" "gris" ON \
#               "LILA" "lila" OFF \
#               3>&1 1<&2 2>&3)
#echo $ans

####################33
#ans=$(whiptail --title "https://atareao.es" \
#               --menu "Elige una opción" 10 80 2 \
#               "Añadir" "Añadir un usuario" \
#               "Modificar" "Modificar un usuario" \
#               "Eliminar" "Eliminar un usuario" \
#               "Listar" "Listar los usuarios" \
#               3>&1 1<&2 2>&3)
#echo $ans

#{
#    for i in {0..100..10};do
#        sleep 1
#        echo $i
#    done
#} | whiptail --title "https://atareao.es" \
#             --gauge "Espera mientras termino..." 5 40 0


#whiptail --title "Check list example" --checklist \
#"Choose user's permissions" 20 78 4 \
#"NET_OUTBOUND" "Allow connections to other hosts" ON \
#"NET_INBOUND" "Allow connections from other hosts" OFF \
#"LOCAL_MOUNT" "Allow mounting of local devices" OFF \
#"REMOTE_MOUNT" "Allow mounting of remote devices" OFF