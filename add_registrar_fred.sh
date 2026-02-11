#!/bin/bash
HANDLE="REG-SYSTEM"
ZONE_FQDN="cr"
ZONE_ID=0
REGISTRAR_ID=0

pause(){
  sleep 1
  # Pausa hasta que el usuario presione una tecla
  echo
  read -n 1 -s -r -p "Press any key for continue..."
  echo
  #echo "Continuando la ejecución..."

}


confirm_continue() {
  echo ""
  read -rp "Do you wish to continue (y/n)? " RESP

  case "$RESP" in
    y|Y)
      return 0
      ;;
    *)
     echo ""
     echo "Operation cancelled by the user."
     echo ""
     exit 1
      #return 1
      ;;
  esac
}

ask() {
  local prompt="$1"
  local value

  while true; do
    read -rp "$prompt (ENTER to accept, 'q' to cancel)): " value

    #[[ "$value" == "q" ]] && return 1

    if [[ "$value" == "q" ]]; then
     clear
     echo "Operation cancelled by the user."
     echo "Finish !!!!" >&2
     return 1
    fi
    if [[ -n "$value" ]]; then
      printf "%s" "$value"   #  sin salto de línea extra
      return 0
    fi
    echo "Madatory field" >&2
  done
}

exec_command() {
  # Captura todos los parámetros como ARRAY de comando
  local comando_a_ejecutar=("$@")

  # Validar que se recibió al menos un elemento
  if [ ${#comando_a_ejecutar[@]} -eq 0 ]; then
    echo "Error: No command recieved"
    return 1
  fi

  # Mostrar el comando que se ejecutará
  echo "Executing..."
  printf ' %q' "${comando_a_ejecutar[@]}"
  #echo

  #echo "Iniciando ejecución..."

  # Ejecutar comando capturando salida y errores
  local output
  output=$("${comando_a_ejecutar[@]}" 2>&1)
  local status=$?

  # Verificar resultado
  if [ $status -eq 0 ]; then
    echo ""
    echo "Command Succesfully"
    return 0
  else
    echo ""
    echo "Command failed"
    echo "$output"
    #exit 1 
    return 1
  fi
}

step5_get_ids() {
  clear
  echo "Getting registry IDs"
  #psql -t -U fred -c  "SELECT id FROM registrar where handle = 'REG-SYSTEM';"
  #psql -t -U fred -c "SELECT id FROM zone where fqdn = 'cr';"
  REGISTRAR_ID=$(psql -U fred -t -A -c "SELECT id FROM registrar WHERE handle = '$HANDLE';" | tr -d '[:space:]')
  ZONE_ID=$(psql -U fred -t -A -c  "SELECT id FROM zone WHERE fqdn = '$ZONE_FQDN';" | tr -d '[:space:]')
  echo "Getting IDs... Ok !!!!"
  return 0
  #echo "reg $REGISTRAR_ID"  
  #echo "zone $ZONE_FQDN" 
  #psql -t -U fred -c  "SELECT id FROM registrar where handle = 'REG-SYSTEM';"
  echo "OK !!!!!"
  
}


step4_add_credit() { 
  clear
  echo "====================================="
  echo "7/8 Add credit to registrar"
  echo "====================================="
  if [[ -z "$REGISTRAR_ID" ]]; then
    echo "Registrar not found"
    return 1
  fi

  if [[ -z "$ZONE_ID" ]]; then
    echo "Zone not found $ZONE_FQDN"
    return 1
  fi
  CREDIT=$(ask "Enter credit for $ZONE_FQDN") || exit 1
  echo "Adding...$CREDIT"
  cmd=(fred-admin --invoice_credit --zone_id="$ZONE_ID" --registrar_id="$REGISTRAR_ID" --price="$CREDIT") 
  exec_command "${cmd[@]}"
  echo "Credit added"
  echo "OK !!!!!"  
}


step3_grant_zone_access() {
  clear
  echo "=========================================="
  echo "5/8 Grant acces to the Zone"
  echo "=========================================="
  
  FROM_DATE=$(ask "Valid from date (ej YYYY-MM-DD)") || exit 1

  cmd=(fred-admin --registrar_add_zone --zone_fqdn="$ZONE_FQDN" --handle="$HANDLE" --from_date="$FROM_DATE")
  exec_command "${cmd[@]}" 
  echo "OK !!!!!"
   
}

step2_add_registrar_acl() {
  clear
  echo "============================================="
  echo "4/8 Creating login"
  echo "============================================="
  #CERT_FILE="/usr/share/fred-client/ssl/test-cert.pem"
  CERT_FILE=$(ask "Enter the full path to certificate.  (ej /usr/share/fred-client/ssl/test-cert.pem)") || exit 1

  if [[ ! -f "$CERT_FILE" ]]; then
    echo "Certificate not found!!!!: $CERT_FILE"
    return 1
  fi
  FINGERPRINT=$(openssl x509 -noout -fingerprint -md5 -in /usr/share/fred-client/ssl/test-cert.pem | cut -d= -f2)

  #echo $FINGERPRINT
  #exit 1  
  if [[ -z "$FINGERPRINT" ]]; then
    echo "The certificate fingerprint could not be obtained"
    return 1 
  fi

  echo "Fingerprint obtained: $FINGERPRINT"

  PASS=$(ask "Enter the regisrar password") || exit 1

  cmd=(fred-admin --registrar_acl_add  --handle="$HANDLE" --certificate="$FINGERPRINT" --password="$PASS")
  exec_command "${cmd[@]}"
  echo "OK !!!!!"
  
}

step1_add_registrar() {
  clear
  echo "====================================="
  echo "1/8 Add t Registrar"
  echo "====================================="
  ZONE_FQDN=$(ask "Enter the Zone  ej cr ") || exit 1
  #NAME=$(ask "Registrar name") || return 1
  HANDLE=$(ask "Enter de regisrar HANDLE  ej REG-SYSTEM") || exit 1
  ORGANIZATION=$(ask "Organizacion/Organization ej NICCR") || exit 1
  COUNTRY=$(ask "Country ej CR") || exit 1
  CITY=$(ask "City ej SJ") || exit 1
  STREET=$(ask "Street ej 27A") || exit 1
  EMAIL=$(ask "Organization Email  ej ti@nic.cr") || exit 1
  URL=$(ask "Organization URL  ej www.nic.cr") || exit 1
 
  
  cmd=(fred-admin --registrar_add --handle=$HANDLE --reg_name=$HANDLE --country=$COUNTRY --organization=$ORGANIZATION --street1=$STREET --city=$CITY --email=$EMAIL --url=$URL --dic=0000 --no_vat)
  # fred-admin --registrar_add 
  #--handle=REG-SYSTEM 
  #--reg_name=REG-SYSTEM 
  #--country=CR    
  #--organization=NICCR        
  #--street1=27A     
  #--city=SJO 
  #--email=ti@nic.cr 
  #--url=http://www.nic.cr/ 
  #--dic=0000 
  #--no_vat 
  #--system
  exec_command "${cmd[@]}"
  echo "OK !!!!!"
  
}

print_info(){
  clear
  echo "=========================================================="
  echo " FRED - Registry Initialization Script ( NIC Costa Rica )"
  echo "=========================================================="
  echo "1/4 Add System Registrar"
  echo "2/4 Grant access to the System Registrar"
  echo "3/4 Grant zone access to the Registrar"
  echo "4/4 Add credit to registrar"
  echo "================================================"
  confirm_continue || return 1
}

check_fred_admin() {
  clear
  local file="/usr/sbin/fred-admin"
  echo "Checking fred-admin utility"
  if [[ ! -f "$file" ]]; then
    echo "Error: fred-admin not found "
    echo "Make sure FRED is installed correctly."
    exit 1
  fi
}

exec_steps(){
 #check_fred_admin
 print_info
 pause
 step1_add_registrar
 pause
 step2_add_registrar_acl
 pause
 step3_grant_zone_access
 pause
 step5_get_ids
 step4_add_credit
 pause
 echo ""
 echo "Exito/Success"
 echo "Finalizado/Finish"
}


main() {
   print_message  "Running"
   exec_steps
}

# Run main function
main