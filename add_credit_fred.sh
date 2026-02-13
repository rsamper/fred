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
    exit 1 
    #return 1
  fi
}

step3_get_ids() {
  clear
  echo "Getting registry IDs"
  #psql -t -U fred -c  "SELECT id FROM registrar where handle = 'REG-SYSTEM';"
  #psql -t -U fred -c "SELECT id FROM zone where fqdn = 'cr';"
  REGISTRAR_ID=$(psql -U fred -t -A -c "SELECT id FROM registrar WHERE handle = '$HANDLE';" | tr -d '[:space:]')
  ZONE_ID=$(psql -U fred -t -A -c  "SELECT id FROM zone WHERE fqdn = '$ZONE_FQDN';" | tr -d '[:space:]')
  echo "Getting IDs... Ok !!!! Registrar $REGISTRAR_ID Zone $ZONE_ID" 
  #psql -t -U fred -c  "SELECT id FROM registrar where handle = 'REG-SYSTEM';"
  echo "OK !!!!!"
  return 0

}


step2_add_credit() { 
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
  CREDIT=$(ask "Enter credit for $ZONE_FQDN.  ej 1000 ") || exit 1
  echo "Adding...$CREDIT"
  cmd=(fred-admin --invoice_credit --zone_id="$ZONE_ID" --registrar_id="$REGISTRAR_ID" --price="$CREDIT") 
  exec_command "${cmd[@]}"
  echo "Credit added"
  echo "OK !!!!!"  
}


step1_get_registrar_zone() {
  clear
  echo "====================================="
  echo "1/1 Add credit to Registrar"
  echo "====================================="
  ZONE_FQDN=$(ask "Enter the Zone  ej cr ") || exit 1
  HANDLE=$(ask "Enter de regisrar HANDLE  ej REG-SYSTEM") || exit 1  
  echo $ZONE_FQDN
  echo $HANDLE 
}

print_info(){
  clear
  echo "=========================================================="
  echo " FRED - Add credit Script ( NIC Costa Rica )"
  echo "=========================================================="
  echo "1/1 Add Cretit to Registrar"
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
 step1_get_registrar_zone
 step3_get_ids
step2_add_credit
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
