#!/bin/bash
HANDLE="REG-SYSTEM"
ZONE_FQDN="cr"
ZONE_ID=0
REGISTRAR_ID=0

pause(){
  sleep 1
  # Pausa hasta que el usuario presione una tecla
  echo
  read -n 1 -s -r -p "Presiona cualquier tecla para continuar.../Press any key for continue..."
  echo
  #echo "Continuando la ejecución..."

}


confirm_continue() {
  echo ""
  read -rp "¿Desea continuar (y/n)?/Do you wish to continue (y/n)? " RESP

  case "$RESP" in
    y|Y)
      return 0
      ;;
    *)
     echo ""
     echo "Finalizado. Operación cancelada por el usuario."
     echo "Completed. Operation cancelled by the user."
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
    read -rp "$prompt (ENTER para aceptar, 'q' para cancelar/ENTER to accept, 'q' to cancel)): " value

    #[[ "$value" == "q" ]] && return 1

    if [[ "$value" == "q" ]]; then
     clear
     echo "Operación cancelada por el usuario."
     echo "Fin !!!!"
     return 1
    fi
    if [[ -n "$value" ]]; then
      printf "%s" "$value"   #  sin salto de línea extra
      return 0
    fi

    echo "Campo obligatorio./Madatory field" >&2
  done
}

exec_command() {
  # Captura todos los parámetros como ARRAY de comando
  local comando_a_ejecutar=("$@")

  # Validar que se recibió al menos un elemento
  if [ ${#comando_a_ejecutar[@]} -eq 0 ]; then
    echo "Error: No se recibió ningún comando para ejecutar./ No command recived"
    return 1
  fi

  # Mostrar el comando que se ejecutará
  echo "Ejecutando.../Executing..."
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
    echo "Éxito: El comando se completó correctamente./Succesfylly"
    return 0
  else
    echo ""
    echo "Error: El comando falló durante la ejecución./Failed"
    echo "$output"
    #exit 1 
    return 1
  fi
}

step10_get_ids() {
  echo "Obteniendo datos IDs/ Getting IDs"
  #psql -t -U fred -c  "SELECT id FROM registrar where handle = 'REG-SYSTEM';"
  #psql -t -U fred -c "SELECT id FROM zone where fqdn = 'cr';"
  REGISTRAR_ID=$(psql -U fred -t -A -c "SELECT id FROM registrar WHERE handle = '$HANDLE';" | tr -d '[:space:]')
  ZONE_ID=$(psql -U fred -t -A -c  "SELECT id FROM zone WHERE fqdn = '$ZONE_FQDN';" | tr -d '[:space:]')
  echo "Obteniendo datos IDs/Getting IDs... Ok !!!!"
  return 0
  #echo "reg $REGISTRAR_ID"  
  #echo "zone $ZONE_FQDN" 
  #psql -t -U fred -c  "SELECT id FROM registrar where handle = 'REG-SYSTEM';"
 
}


step11_add_credit() { 
  echo "================================="
  echo "7/8  Agregar credito a un registrador"
  echo "7/8  Add credit to registrar"
  echo "================================="
  if [[ -z "$REGISTRAR_ID" ]]; then
    echo "Registrar not found"
    return 1
  fi

  if [[ -z "$ZONE_ID" ]]; then
    echo "Zone not found cz"
    return 1
  fi
  CREDIT=$(ask "Digite el creditro agregar a $HANDLE para la zona $ZONE_FQDN /Enter credit for $ZONE_FQDN") || exit 1
  echo "Agregando...$CREDIT"
  echo "Adding...$CREDIT"
  cmd=(fred-admin --invoice_credit --zone_id="$ZONE_ID" --registrar_id="$REGISTRAR_ID" --price="$CREDIT") 
  exec_command "${cmd[@]}"
  echo "Credito added"

}


step9_add_invoice_number() {
  
  echo "================================="
  echo "7/8 Crear prefijo de facturacion"
  echo "7/8 Create Invoice prefix" 
  echo "================================="

  PREFIX=$(ask "Prefijo para avanzada/Prefix for advance") || exit 1
  cmd=(fred-admin --add_invoice_number_prefix --prefix="$PREFIX" --zone_fqdn="$ZONE_FQDN" --invoice_type_name=advance)
  exec_command "${cmd[@]}"
  PREFIX=$(ask "Prefijo account/Prefix for account") || exit 1
  cmd=(fred-admin --add_invoice_number_prefix --prefix="$PREFIX" --zone_fqdn="$ZONE_FQDN" --invoice_type_name=account)
  exec_command "${cmd[@]}"
  cmd=(fred-admin --create_invoice_prefixes --for_current_year)
  exec_command "${cmd[@]}"
  #fred-admin --invoice_add_prefix --zone_fqdn=cz --type 0 --year 2017 --prefix 401700001
}


step8_add_price_general() {
  
  echo "================================="
  echo "6/8 Crear la lista de precios del sistema.  Precio operacion EPP General"
  echo "6/8 Create the system price list. General EPP Operation"
  echo "================================="


  VALID_FROM=$(ask "Valido desde/Valid from (ej 2014-12-31 23:00:00)") || exit 1
  PRICE=$(ask "Precio por operacion EPP/Price operation (ej 25)") || exit 1
  cmd=(fred-admin --price_add --operation="'GeneralEppOperation'" --zone_fqdn="$ZONE_FQDN" --valid_from="$VALID_FROM" --operation_price "$PRICE" --period 1)

  exec_command "${cmd[@]}"
}

step7_add_price_renew() {

  
  echo "================================="
  echo "6/8  Crear la lista de precios del sistema".  Renovacion de dominios
  echo "Create the system price list. Renew Domain"
  echo "================================="

  VALID_FROM=$(ask "Valid from (ej 2014-12-31 23:00:00)") || exit 1
  PRICE=$(ask "Precio de renovacion de dominios (ej 25)") || exit 1
  cmd=(fred-admin --price_add --operation="'RenewDomain'" --zone_fqdn="$ZONE_FQDN" --valid_from="$VALID_FROM" --operation_price "$PRICE" --period 1)
  exec_command "${cmd[@]}"
}

step6_add_price_create() {
  echo "================================="
  echo "6/8 Crear la lista de precios del sistema.  Creacion de Dominios"
  echo "6/8 Create the system price list. Create Domain"
  echo "================================="


  #CERT=$(ask "Certificate fingerprint") || return 1
  VALID_FROM=$(ask "Valido desde/ Valid from (ej 2014-12-31 23:00:00)") || exit 1
  PRICE=$(ask "Precio por crear dominios (ej 25)") || exit 1
  
  cmd=(fred-admin --price_add --operation="'CreateDomain'" --zone_fqdn="$ZONE_FQDN" --valid_from="$VALID_FROM" --operation_price "$PRICE" --period 1)
      #fred-admin --price_add --operation='CreateDomain' --zone_fqdn=cr --valid_from='2014-12-31 23:00:00'  --operation_price 333 --period 1
  exec_command "${cmd[@]}"
}

step5_grant_zone_access() {
  
  echo "================================="
  echo "5/8 Dar acceso a la zona al Registrador"
  echo "5/8 Grant acces to the Zone $ZONE_FQDN"
  echo "================================="
  
  FROM_DATE=$(ask "Valida desde la fecha/From date (ej YYYY-MM-DD)") || exit 1

  cmd=(fred-admin --registrar_add_zone --zone_fqdn="$ZONE_FQDN" --handle="$HANDLE" --from_date="$FROM_DATE")
  exec_command "${cmd[@]}"  
}


step4_add_registrar_acl() {
  
  echo "================================="
  echo "4/8 Dar acceso al Registrador del Sistema"
  echo "4/8 Creating login access"
  
  echo "================================="
  #CERT_FILE="/usr/share/fred-client/ssl/test-cert.pem"
  CERT_FILE=$(ask "Digite al ruta completa del certificado digital/Enter the full path of the digital certificate.  (ej /usr/share/fred-client/ssl/test-cert.pem)") || exit 1

  if [[ ! -f "$CERT_FILE" ]]; then
    echo "Certificado no encontrado/Certificadte not found!!!!: $CERT_FILE"
    return 1
  fi
  FINGERPRINT=$(openssl x509 -noout -fingerprint -md5 -in /usr/share/fred-client/ssl/test-cert.pem | cut -d= -f2)

  #echo $FINGERPRINT
  #exit 1  
  if [[ -z "$FINGERPRINT" ]]; then
    echo "No se pudo obtener fingerprint del certificado/The certificate fingerprint could not be obtained"
    return 1 
  fi

  echo "Fingerprint obtenido/Fingerprint obtained: $FINGERPRINT"

  PASS=$(ask "Ingrese la clave para el registrador/Enter the regisrar password") || exit 1

  cmd=(fred-admin --registrar_acl_add  --handle="$HANDLE" --certificate="$FINGERPRINT" --password="$PASS")
  exec_command "${cmd[@]}"
}


step3_add_registrar() {
  
  echo "================================="
  echo "3/8 Agregar Registrador del Sistema"
  echo "3/8 Add the System Registrar"
  echo "================================="
  
  #NAME=$(ask "Registrar name") || return 1
  HANDLE=$(ask "Ingrese el HANDLE del resgistrador/Enter de regisrar HANDLE  ej REG-SYSTEM") || exit 1
  ORGANIZATION=$(ask "Organizacion/Organization ej NICCR") || exit 1
  COUNTRY=$(ask "Pais/Country ej CR") || exit 1
  CITY=$(ask "Cidad/City ej 27A") || exit 1
  STREET=$(ask "Calle/Street ej SJ") || exit 1
  EMAIL=$(ask "Email/Organization Email  ej ti@nic.cr") || exit 1
  URL=$(ask "URL/Organization URL  ej www.nic.cr") || exit 1
 
  
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
}


step2_add_nameservers() {
  
  echo "================================="
  echo "Paso 2/8. Agregando NSs a la zona"
  echo "Step 2/8. Adding NSs to the zone"
  echo "================================="
 
    NS=$(ask "Agregar NS/Enter the NS value (ej ns.nic.cr)") || exit 1
    ADDR=$(ask "IP del NS/Enter the IP address (ej 200.107.200.10)") || exit 1
    cmd=(fred-admin --zone_ns_add --zone_fqdn="$ZONE_FQDN" --ns_fqdn="$NS")
    exec_command "${cmd[@]}"
}

form_zone() {
  ZONE_FQDN=$(ask "Ingrese el FQDN de la zona/Enter the FQDN of the zone  (ej: cr)") || exit 1
  TTL=$(ask "Ingrese el TTL/Enter the TTL of the zone (ej: 18000)") || exit 1
  HOSTMASTER=$(ask "Ingrese el email del Hostmaster/Enter the email address (ej ti.nic.cr)") || exit 1
  NS_FQDN=$(ask "Ingrese el nombre del servidor DNS primario/Enter the primary DNS server (ej: ns.nic.cr)") || exit 1
  return 0
}

step1_create_zone() {
  clear
  echo "================================="
  echo "Paso 1/8.  Creacion del Registro"
  echo "Step 1/8. Creating the Record"
  echo "================================="
  if ! form_zone; then
    echo
    echo "Operación cancelada por el usuario."
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
  return 0
}

print_info(){
  clear
  echo "================================================="
  echo "Inicializar FRED involucra los siguientes pasos"
  echo "1/8 Crear la zona servida por el Registry"
  echo "2/8 Agregar servidores de nombres NS para la zona definida"
  echo "3/8 Agregar Registrador del Sistema"
  echo "4/8 Dar acceso al Registrador del Sistema"
  echo "5/8 Dar acceso a la zona al Registrador"
  echo "6/8 Crear la lista de precios del sistema"
  echo "7/8 Crear parametros de facturacion del sistema"
  echo "8/8 Agregar credito al registrador del sistema"
  echo "================================================="
  echo "Initializing FRED involves the following steps"
  echo "1/8 Create the zone served by the Registry"
  echo "2/8 Add NS name servers for the defined zone"
  echo "3/8 Add System Registrar"
  echo "4/8 Grant access to the System Registrar"
  echo "5/8 Grant zone access to the Registrar"
  echo "6/8 Create the system price list"
  echo "7/8 Create system billing parameters"
  echo "8/8 Add credit to the system registrar"
  echo "================================================="
  confirm_continue || return 1
}


exec_steps(){
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
}


main() {
   print_message  "Running"
   exec_steps
}

# Run main function
main