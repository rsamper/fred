#!/bin/bash
HANDLE="REG-SYSTEM"
ZONE_FQDN="cr"

pause(){
  sleep 1
  # Pausa hasta que el usuario presione una tecla
  echo
  read -n 1 -s -r -p "Presiona cualquier tecla para continuar..."
  echo
  #echo "Continuando la ejecución..."

}


confirm_continue() {
  echo ""
  read -rp "¿Desea continuar (y/n)? " RESP

  case "$RESP" in
    y|Y)
      return 0
      ;;
    *)
     echo ""
     echo "Finalizdo. Operación cancelada por el usuario."
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
    read -rp "$prompt (ENTER para aceptar, 'q' para cancelar): " value

    [[ "$value" == "q" ]] && return 1

    if [[ -n "$value" ]]; then
      printf "%s" "$value"   #  sin salto de línea extra
      return 0
    fi

    echo "Campo obligatorio." >&2
  done
}

exec_command() {
  # Captura todos los parámetros como ARRAY de comando
  local comando_a_ejecutar=("$@")

  # Validar que se recibió al menos un elemento
  if [ ${#comando_a_ejecutar[@]} -eq 0 ]; then
    echo "Error: No se recibió ningún comando para ejecutar."
    return 1
  fi

  # Mostrar el comando que se ejecutará
  echo "Ejecutando..."
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
    echo "Éxito: El comando se completó correctamente."
    return 0
  else
    echo ""
    echo "Error: El comando falló durante la ejecución."
    echo "$output"
    #exit 1 
    return 1
  fi
}

add_credit() {
  
  echo "================================="
  echo "7/8  Agregar credito a un registrador"
  echo "================================="
  REG_ID=$(ask "Registrar ID") || return 1
  ZONE_ID=$(ask "ZONE ID") || return 1
  CREDIT=$(ask "Credito ") || return
  
  cmd=(fred-admin --invoice_credit --zone_id="$ZONE_ID" --registrar_id="$REG_ID" --price="$CREDIT")
  exec_command "${cmd[@]}"
}


add_invoice_number() {
  
  echo "================================="
  echo "7/8  Crear prefijo de facturacion"
  echo "================================="

  PREFIX=$(ask "Prefix for advance") || return 1
  cmd=(fred-admin --add_invoice_number_prefix --prefix="$PREFIX" --zone_fqdn="$ZONE_FQDN" --invoice_type_name=advance)
  exec_command "${cmd[@]}"
  PREFIX=$(ask "Prefix for account") || return 1
  cmd=(fred-admin --add_invoice_number_prefix --prefix="$PREFIX" --zone_fqdn="$ZONE_FQDN" --invoice_type_name=account)
  exec_command "${cmd[@]}"
}


add_price_general() {
  
  echo "================================="
  echo "6/8  Crear la lista de precios del sistema.  Precio operacion EPP General"
  echo "================================="


  VALID_FROM=$(ask "Valid from (ej 2014-12-31 23:00:00)") || return
  PRICE=$(ask "Precio por operacion EPP (ej 25)") || return
  cmd=(fred-admin --price_add --operation="'GeneralEppOperation'" --zone_fqdn="$ZONE_FQDN" --valid_from="$VALID_FROM" --operation_price "$PRICE" --period 1)

  exec_command "${cmd[@]}"
}

add_price_renew() {

  
  echo "================================="
  echo "6/8  Crear la lista de precios del sistema".  Renovacion de dominios
  echo "================================="

  VALID_FROM=$(ask "Valid from (ej 2014-12-31 23:00:00)") || return
  PRICE=$(ask "Precio de renovacion de dominios (ej 25)") || return
  cmd=(fred-admin --price_add --operation="'RenewDomain'" --zone_fqdn="$ZONE_FQDN" --valid_from="$VALID_FROM" --operation_price "$PRICE" --period 1)
  exec_command "${cmd[@]}"
}

add_price_create() {
  echo "================================="
  echo "6/8  Crear la lista de precios del sistema.  Creacion de Dominios"
  echo "================================="


  #CERT=$(ask "Certificate fingerprint") || return 1
  VALID_FROM=$(ask "Valid from ej 2014-12-31 23:00:00") || return 1
  PRICE=$(ask "Precio por crear dominios (ej 25)") || return 1
  
  cmd=(fred-admin --price_add --operation="'CreateDomain'" --zone_fqdn="$ZONE_FQDN" --valid_from="$VALID_FROM" --operation_price "$PRICE" --period 1)
      #fred-admin --price_add --operation='CreateDomain' --zone_fqdn=cr --valid_from='2014-12-31 23:00:00'  --operation_price 333 --period 1
  exec_command "${cmd[@]}"
}

grant_zone_access() {
  
  echo "================================="
  echo "5/8  Dar acceso a la zona al Registrador"
  echo "================================="
  
  FROM_DATE=$(ask "From date (YYYY-MM-DD)") || return

  cmd=(fred-admin --registrar_add_zone --zone_fqdn="$ZONE_FQDN" --handle="$HANDLE" --from_date="$FROM_DATE")
  exec_command "${cmd[@]}"  
}


add_registrar_acl() {
  
  echo "================================="
  echo "4/8  Dar acceso al Registrador del Sistema"
  echo "================================="
  #CERT_FILE="/usr/share/fred-client/ssl/test-cert.pem"
  CERT_FILE=$(ask "Digite al ruta completa del certificado digital.  ej /usr/share/fred-client/ssl/test-cert.pem") || return 1

  if [[ ! -f "$CERT_FILE" ]]; then
    echo "Certificado no encontrado: $CERT_FILE"
    return 1
  fi
  FINGERPRINT=$(openssl x509 -noout -fingerprint -md5 -in /usr/share/fred-client/ssl/test-cert.pem | cut -d= -f2)

  #echo $FINGERPRINT
  #exit 1  
  if [[ -z "$FINGERPRINT" ]]; then
    echo "❌ No se pudo obtener fingerprint del certificado"
    return 1 
  fi

  echo "Fingerprint obtenido: $FINGERPRINT"

  PASS=$(ask "Ingrese la clave para el registrador") || return 1

  cmd=(fred-admin --registrar_acl_add  --handle="$HANDLE" --certificate="$FINGERPRINT" --password="$PASS")
  exec_command "${cmd[@]}"
}


add_registrar() {
  
  echo "================================="
  echo "3/8  Agregar Registrador del Sistema"
  echo "================================="
  
  #NAME=$(ask "Registrar name") || return 1
  HANDLE=$(ask "HANDLE ej REG-SYSTEM") || return 1
  ORGANIZATION=$(ask "Organization ej NICCR") || return 1
  COUNTRY=$(ask "Country ej CR") || return 1
  CITY=$(ask "City ej 27A") || return 1
  STREET=$(ask "Street ej SJ") || return 1
  EMAIL=$(ask "Organization Email  ej ti@nic.cr") || return 1
  URL=$(ask "Organization URL  ej www.nic.cr") || return 1
 
  
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


add_nameservers() {
  
  echo "================================="
  echo "Paso 2/8.  Agregando NSs a la zona"
  echo "================================="
 
  #while true; do
    NS=$(ask "Agregar NS (vacío para terminar)") || return 1
   # [ -z "$NS" ] && break
    ADDR=$(ask "IP del NS") || return 1
    cmd=(fred-admin --zone_ns_add --zone_fqdn="$ZONE_FQDN" --ns_fqdn="$NS")
   # [ -n "$ADDR" ] && cmd+=(--addr $ADDR)
    exec_command "${cmd[@]}"
  #done
}

form_zone() {
  ZONE_FQDN=$(ask "Ingrese el FQDN de la zona (ej: cr)") || return 1
  TTL=$(ask "Ingrese el TTL (ej: 18000)") || return 1
  HOSTMASTER=$(ask "Ingrese el email del Hostmaster ej ti.nic.cr") || return 1
  NS_FQDN=$(ask "Ingrese el nombre del servidor DNS primario (ej: ns.nic.cr)") || return 1
  return 0
}

create_zone() {
  clear
  echo "================================="
  echo "Paso 1/8.  Creacion del Registro"
  echo "================================="
  if ! form_zone; then
    echo
    echo "Operación cancelada por el usuario."
    echo
    exit 0     # 🔥 salida limpia del programa
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

}

print_info(){
  clear
  echo "================================================="
  echo "Inicializar FRED involucra los siguientes pasos"
  echo "1/8  Crear la zona servida por el Registry"
  echo "2/8  Agregar servidores de nombres NS para la zona definida"
  echo "3/8  Agregar Registrador del Sistema"
  echo "4/8  Dar acceso al Registrador del Sistema"
  echo "5/8  Dar acceso a la zona al Registrador"
  echo "6/8  Crear la lista de precios del sistema"
  echo "7/8  Crear parametros de facturacion del sistema"
  echo "8/8  Agregar credito al registrador del sistema"
  echo "================================================="
  confirm_continue || return 1
}



print_info
#create_zone
#pause 
#add_nameservers
#pause
#add_registrar
#add_registrar_acl
#pause
#grant_zone_access
#pause
#add_price_create
#pause
#add_price_renew
#pause
#add_price_general
#pause
add_invoice_number
pause
add_credit
pause
