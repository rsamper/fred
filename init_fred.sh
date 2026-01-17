#!/bin/bash

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

exec_command(){
 
 #output=$("${cmd[@]}" 2>&1)
 output=${cmd[@]}
 
 echo $output
 return 1
 #status=$?

 if [ $status -ne 0 ]; then
   echo "ERROR ejecutando fred-admin:"
   echo "$output"
   return 1
 else
  echo "Comando ejecutado correctamente"
 fi
}

add_credit() {
  REG_ID=$(ask "REgistrar ID") || return 1
  CREDIT=$(ask "CREDIT ") || return
  
  cmd=(fred-admin --invoice_credit --zone_id=1 --registrar_id=$REG_ID --price=$CREDIT)
  exec_command "${cmd[@]}"
}


add_invoice_number() {
  PREFIX=$(ask "Prefix for advance") || return 1
  cmd=(fred-admin --add_invoice_number_prefix --prefix=$PREFIX --zone_fqdn=$ZONE_FQDN --invoice_type_name=advance)
  exec_command "${cmd[@]}"
  PREFIX=$(ask "Prefix for account") || return 1
  cmd=(fred-admin --add_invoice_number_prefix --prefix=$PREFIX --zone_fqdn=cz --invoice_type_name=account)
  exec_command "${cmd[@]}"
}


add_price_renew() {

  echo "Add price for Domain renewal"
  VALID_FROM=$(ask "Valid from (ej 2014-12-31 23:00:00)") || return
  PRICE=$(ask "Valid from (ej 25)") || return
  cmd=(fred-admin -fred-admin --price_add --operation='RenewDomain' --zone_fqdn=$ZONE_FQDN --valid_from=$VALID_FROM --operation_price $PRICE --period 1)
  exec_command "${cmd[@]}"
}

add_price_renew() {

  echo "Add price for Domain renewal"
  VALID_FROM=$(ask "Valid from (ej 2014-12-31 23:00:00)") || return
  PRICE=$(ask "Valid from (ej 25)") || return
  cmd=(fred-admin -fred-admin --price_add --operation='RenewDomain' --zone_fqdn=$ZONE_FQDN --valid_from=$VALID_FROM --operation_price $PRICE --period 1)
  exec_command "${cmd[@]}"
}

add_price_create() {
  echo "Add price for Domain creation"
  #CERT=$(ask "Certificate fingerprint") || return 1
  VALID_FROM=$(ask "Valid from ej 2014-12-31 23:00:00") || return 1
  PRICE=$(ask "Valid from (ej 25)") || return 1
  
  cmd=(fred-admin --price_add --operation='CreateDomain' --zone_fqdn=$ZONE_FQDN --valid_from=$VALID_FROM --operation_price $PRICE --period 1)
  exec_command "${cmd[@]}"
}

grant_zone_access() {
  FROM_DATE=$(ask "From date (YYYY-MM-DD)") || return

  cmd=(fred-admin --registrar_add_zone --zone_fqdn="$ZONE_FQDN" --handle="$REG_HANDLE" --from_date="$FROM_DATE")
  exec_command "${cmd[@]}"  
}


add_registrar_acl() {
  CERT=$(ask "Certificate fingerprint") || return 1
  PASS=$(ask "Password") || return 1

  cmd=(fred-admin --registrar_acl_add  --handle="$REG_HANDLE" --certificate="$CERT" --password="$PASS")
  exec_command "${cmd[@]}"
}


add_registrar() {
  NAME=$(ask "Registrar name") || return 1
  REG_HANDLE=$(ask "HANDLE ") || return 1
  ORGANIZATION=$(ask "Organization") || return 1
  COUNTRY=$(ask "Country") || return 1
 
  
  cmd=(fred-admin --registrar_add --handle=$HANDLE --reg_name="NAME" --country=$COUNTRY --no_vat --system)
  exec_command "${cmd[@]}"
}


add_nameservers() {
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
  ZONE_FQDN=$(ask "Zone FQDN (ej: cz)") || return 1
  TTL=$(ask "TTL (ej: 18000)") || return 1
  HOSTMASTER=$(ask "Hostmaster email") || return 1
  NS_FQDN=$(ask "NS primario (ej: ns.nic.cr)") || return 1
  return 0
}

create_zone() {
  if ! form_zone; then
    echo
    echo "Operación cancelada por el usuario."
    echo
    exit 0     # 🔥 salida limpia del programa
  fi

  cmd=(
    fred-admin --zone_add
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
}













#create_zone
#add_nameservers
#add_registrar
#add_registrar_acl
#grant_zone_access
#add_price_create
#add_price_renew
#add_price_general
#add_invoice_number
add_credit