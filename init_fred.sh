#!/bin/bash

pause(){
  sleep 1
  # Pausa hasta que el usuario presione una tecla
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
      #exit 1
      return 1
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
    echo "❌ Error: No se recibió ningún comando para ejecutar."
    return 1
  fi

  # Mostrar el comando que se ejecutará
  echo "Ejecutando comando:"
  printf ' %q' "${comando_a_ejecutar[@]}"
  echo

  echo "Iniciando ejecución..."

  # Ejecutar comando capturando salida y errores
  local output
  output=$("${comando_a_ejecutar[@]}" 2>&1)
  local status=$?

  # Verificar resultado
  if [ $status -eq 0 ]; then
    echo "Éxito: El comando se completó correctamente."
    return 0
  else
    echo "Error: El comando falló durante la ejecución."
    echo "---- Salida de error ----"
    echo "$output"
    echo "-------------------------"
    return 1
  fi
}

add_credit() {
  clear
  echo "================================="
  echo "7/8  Agregar credito a un registrador"
  echo "================================="
  REG_ID=$(ask "Registrar ID") || return 1
  CREDIT=$(ask "Credito ") || return
  
  cmd=(fred-admin --invoice_credit --zone_id=1 --registrar_id=$REG_ID --price=$CREDIT)
  exec_command "${cmd[@]}"
}


add_invoice_number() {
  clear
  echo "================================="
  echo "7/8  Crear prefijo de facturacion"
  echo "================================="

  PREFIX=$(ask "Prefix for advance") || return 1
  cmd=(fred-admin --add_invoice_number_prefix --prefix=$PREFIX --zone_fqdn=$ZONE_FQDN --invoice_type_name=advance)
  exec_command "${cmd[@]}"
  PREFIX=$(ask "Prefix for account") || return 1
  cmd=(fred-admin --add_invoice_number_prefix --prefix=$PREFIX --zone_fqdn=cz --invoice_type_name=account)
  exec_command "${cmd[@]}"
}


add_price_general() {
 clear
  echo "================================="
  echo "6/8  Crear la lista de precios del sistema.  Precio operacion EPP General"
  echo "================================="


  VALID_FROM=$(ask "Valid from (ej 2014-12-31 23:00:00)") || return
  PRICE=$(ask "Precio por operacion EPP (ej 25)") || return
  cmd=(fred-admin -fred-admin --price_add --operation='RenewDomain' --zone_fqdn=$ZONE_FQDN --valid_from=$VALID_FROM --operation_price $PRICE --period 1)
  exec_command "${cmd[@]}"
}

add_price_renew() {

  clear
  echo "================================="
  echo "6/8  Crear la lista de precios del sistema".  Renovacion de dominios
  echo "================================="

  VALID_FROM=$(ask "Valid from (ej 2014-12-31 23:00:00)") || return
  PRICE=$(ask "Precio de renovacion de dominios (ej 25)") || return
  cmd=(fred-admin -fred-admin --price_add --operation='RenewDomain' --zone_fqdn=$ZONE_FQDN --valid_from=$VALID_FROM --operation_price $PRICE --period 1)
  exec_command "${cmd[@]}"
}

add_price_create() {
  clear
  echo "================================="
  echo "6/8  Crear la lista de precios del sistema.  Creacion de Dominios"
  echo "================================="


  #CERT=$(ask "Certificate fingerprint") || return 1
  VALID_FROM=$(ask "Valid from ej 2014-12-31 23:00:00") || return 1
  PRICE=$(ask "Precio por crear dominios (ej 25)") || return 1
  
  cmd=(fred-admin --price_add --operation='CreateDomain' --zone_fqdn=$ZONE_FQDN --valid_from=$VALID_FROM --operation_price $PRICE --period 1)
  exec_command "${cmd[@]}"
}

grant_zone_access() {
  clear
  echo "================================="
  echo "5/8  Dar acceso a la zona al Registrador"
  echo "================================="
  
  FROM_DATE=$(ask "From date (YYYY-MM-DD)") || return

  cmd=(fred-admin --registrar_add_zone --zone_fqdn="$ZONE_FQDN" --handle="$REG_HANDLE" --from_date="$FROM_DATE")
  exec_command "${cmd[@]}"  
}


add_registrar_acl() {
  clear
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


  if [[ -z "$FINGERPRINT" ]]; then
    echo "❌ No se pudo obtener fingerprint del certificado"
    return 1 
  fi

  echo "Fingerprint obtenido: $FINGERPRINT"

  PASS=$(ask "Ingrese la clave para el registrador") || return 1

  cmd=(fred-admin --registrar_acl_add  --handle="$REG_HANDLE" --certificate="$CERT" --password="$PASS")
  exec_command "${cmd[@]}"
}


add_registrar() {
  clear
  echo "================================="
  echo "3/8  Agregar Registrador del Sistema"
  echo "================================="
  
  NAME=$(ask "Registrar name") || return 1
  REG_HANDLE=$(ask "HANDLE ") || return 1
  ORGANIZATION=$(ask "Organization") || return 1
  COUNTRY=$(ask "Country") || return 1
 
  
  cmd=(fred-admin --registrar_add --handle=$HANDLE --reg_name="NAME" --country=$COUNTRY --no_vat --system)
  exec_command "${cmd[@]}"
}


add_nameservers() {
  clear
  echo "================================="
  echo "Paso 2/8.  Agregando NSs a la zona"
  echo "================================="
 
  while true; do
    NS=$(ask "Agregar NS (vacío para terminar)") || return 1
    [ -z "$NS" ] && break
    ADDR=$(ask "IP(s) del NS (opcional)") || return 1
    cmd=(fred-admin --zone_ns_add --zone_fqdn="$ZONE_FQDN" --ns_fqdn="$NS")
    [ -n "$ADDR" ] && cmd+=(--addr $ADDR)
    exec_command "${cmd[@]}"
  done
}

form_zone() {
  ZONE_FQDN=$(ask "Ingrese el FQDN de la zona (ej: cr)") || return 1
  TTL=$(ask "Ingrese el TTL (ej: 18000)") || return 1
  HOSTMASTER=$(ask "Ingrese el email del Hostmaster ") || return 1
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
  confirm_continue || return
}



print_info
create_zone 
add_nameservers
add_registrar
add_registrar_acl
grant_zone_access
add_price_create
add_price_renew
add_price_general
add_invoice_number
add_credit