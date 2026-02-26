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

step10_get_ids() {
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


step11_add_credit() { 
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



step9_add_invoice_number() {
  clear
  echo "=================================="
  echo "7/8 Create Invoice prefix" 
  echo "=================================="

  PREFIX=$(ask "Prefix for advance") || exit 1
  cmd=(fred-admin --add_invoice_number_prefix --prefix="$PREFIX" --zone_fqdn="$ZONE_FQDN" --invoice_type_name=advance)
  exec_command "${cmd[@]}"
  PREFIX=$(ask "Prefix for account") || exit 1
  cmd=(fred-admin --add_invoice_number_prefix --prefix="$PREFIX" --zone_fqdn="$ZONE_FQDN" --invoice_type_name=account)
  exec_command "${cmd[@]}"
  cmd=(fred-admin --create_invoice_prefixes --for_current_year)
  exec_command "${cmd[@]}"
  #fred-admin --invoice_add_prefix --zone_fqdn=cz --type 0 --year 2017 --prefix 401700001
  echo "OK !!!!!"
  
}


step8_add_price_general() {
  clear
  echo "=========================================================================="
  echo "6/8 Create the system price list. General EPP Operation"
  echo "=========================================================================="


  VALID_FROM=$(ask "Valid from (ej 2014-12-31 23:00:00)") || exit 1
  PRICE=$(ask "Price operation (ej 25)") || exit 1
  cmd=(fred-admin --price_add --operation="'GeneralEppOperation'" --zone_fqdn="$ZONE_FQDN" --valid_from="$VALID_FROM" --operation_price "$PRICE" --period 1)

  exec_command "${cmd[@]}"
  echo "OK !!!!!"
  
}

step7_add_price_renew() {

  clear
  echo "===================================================================="
  echo "6/8 Create the system price list. Renew Domain"
  echo "===================================================================="

  VALID_FROM=$(ask "Valid from (ej 2014-12-31 23:00:00)") || exit 1
  PRICE=$(ask "Price for renew (ej 25)") || exit 1
  cmd=(fred-admin --price_add --operation="'RenewDomain'" --zone_fqdn="$ZONE_FQDN" --valid_from="$VALID_FROM" --operation_price "$PRICE" --period 1)
  exec_command "${cmd[@]}"
  echo "OK !!!!!"
  
}

step6_add_price_create() {
  clear
  echo "================================================================="
  echo "6/8 Create the system price list. Create Domain"
  echo "================================================================="


  #CERT=$(ask "Certificate fingerprint") || return 1
  VALID_FROM=$(ask "Valid from (ej 2014-12-31 23:00:00)") || exit 1
  PRICE=$(ask "Price for create (ej 25)") || exit 1
  
  cmd=(fred-admin --price_add --operation="'CreateDomain'" --zone_fqdn="$ZONE_FQDN" --valid_from="$VALID_FROM" --operation_price "$PRICE" --period 1)
      #fred-admin --price_add --operation='CreateDomain' --zone_fqdn=cr --valid_from='2014-12-31 23:00:00'  --operation_price 333 --period 1
  exec_command "${cmd[@]}"
  echo "OK !!!!!"
  
}

step5_grant_zone_access() {
  clear
  echo "=========================================="
  echo "5/8 Grant acces to the Zone"
  echo "=========================================="
  
  FROM_DATE=$(ask "Valid from date (ej YYYY-MM-DD)") || exit 1

  cmd=(fred-admin --registrar_add_zone --zone_fqdn="$ZONE_FQDN" --handle="$HANDLE" --from_date="$FROM_DATE")
  exec_command "${cmd[@]}" 
  echo "OK !!!!!"
   
}


step4_add_registrar_acl() {
  clear
  echo "============================================="
  echo "4/8 Creating login"
  echo "============================================="
  #CERT_FILE="/usr/share/fred-client/ssl/test-cert.pem"
  # 2026 /usr/share/fred-mod-eppd/ssl/test-cert.pem 
  CERT_FILE=$(ask "Enter the full path to certificate.  (ej /usr/share/fred-client/ssl/test-cert.pem for 2026 /usr/share/fred-mod-eppd/ssl/test-cert.pem)") || exit 1

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


step3_add_registrar() {
  clear
  echo "====================================="
  echo "3/8 Add the System Registrar"
  echo "====================================="
  
  #NAME=$(ask "Registrar name") || return 1
  HANDLE=$(ask "Enter de regisrar HANDLE  ej REG-SYSTEM") || exit 1
  ORGANIZATION=$(ask "Organizacion/Organization ej NICCR") || exit 1
  COUNTRY=$(ask "Country ej CR") || exit 1
  CITY=$(ask "City ej SJ") || exit 1
  STREET=$(ask "Street ej 27A") || exit 1
  EMAIL=$(ask "Organization Email  ej ti@nic.cr") || exit 1
  URL=$(ask "Organization URL  ej www.nic.cr") || exit 1
 
  
  cmd=(fred-admin --registrar_add --handle=$HANDLE --reg_name=$HANDLE --country=$COUNTRY --organization=$ORGANIZATION --street1=$STREET --city=$CITY --email=$EMAIL --url=$URL --dic=0000 --no_vat --system)
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


step2_add_nameservers() {
  clear
  echo "==================================="
  echo "Step 2/8. Adding NSs to the zone"
  echo "===================================="
 
    NS=$(ask "Enter the NS value (ej ns.nic.cr)") || exit 1
    ADDR=$(ask "Enter the IP address (ej 200.107.200.10)") || exit 1
    cmd=(fred-admin --zone_ns_add --zone_fqdn="$ZONE_FQDN" --ns_fqdn="$NS")
    exec_command "${cmd[@]}"
    echo "OK !!!!!"
  
}

form_zone() {
  ZONE_FQDN=$(ask "Enter the FQDN of the zone  (ej: cr)") || exit 1
  TTL=$(ask "Enter the TTL of the zone (ej: 18000)") || exit 1
  HOSTMASTER=$(ask "Enter the email address (ej ti.nic.cr)") || exit 1
  NS_FQDN=$(ask "Enter the primary DNS server (ej: ns.nic.cr)") || exit 1
  return 0
}

step1_create_zone() {
  clear
  echo "================================="=
  echo "Step 1/8. Creating the zone"
  echo "=================================="
  if ! form_zone; then
    echo
    echo "Operation cancelled by the user."
    echo
    exit 0 
  fi

  cmd=(fred-admin 
    --zone_add
    --zone_fqdn="$ZONE_FQDN"
    --ex_period_min=12
    --ex_period_max=120
    --ttl="$TTL"
    --hostmaster="$HOSTMASTER"
    --refresh=900
    --update_retr=300
    --expiry=604800
    --minimum=900
    --ns_fqdn="$NS_FQDN"
  )
  #echo "${cmd[@]}"
  exec_command "${cmd[@]}"
  echo "OK !!!!!"
  return 0
}

print_info(){
  clear
  echo "=========================================================="
  echo " FRED - Registry Initialization Script ( NIC Costa Rica )"
  echo "=========================================================="
  echo "Initializing FRED involves the following steps"
  echo "1/8 Create the zone served by the Registry"
  echo "2/8 Add NS name servers for the defined zone"
  echo "3/8 Add System Registrar"
  echo "4/8 Grant access to the System Registrar"
  echo "5/8 Grant zone access to the Registrar"
  echo "6/8 Create the system price list"
  echo "7/8 Create system billing parameters"
  echo "8/8 Add credit to the system registrar"
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
 step1_create_zone
 pause 
 step2_add_nameservers
 pause
 step3_add_registrar
 pause
 step4_add_registrar_acl
 pause
 step5_grant_zone_access
 pause
 step6_add_price_create
 pause
 step7_add_price_renew
 pause
 step8_add_price_general
 pause
 step9_add_invoice_number
 pause
 step10_get_ids
 step11_add_credit
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