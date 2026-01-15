#!/bin/bash

ask() {
  local prompt="$1"
  local value

  while true; do
    read -rp "$prompt (ENTER para aceptar, 'q' para cancelar): " value

    [[ "$value" == "q" ]] && return 1

    if [[ -n "$value" ]]; then
      printf "%s" "$value"   # 👈 sin salto de línea extra
      return 0
    fi

    echo "❌ Campo obligatorio." >&2
  done
}
exec_command(){
 output=$("${cmd[@]}" 2>&1)
 status=$?

if [ $status -ne 0 ]; then
  print_log_message "❌ ERROR ejecutando fred-admin:"
  print_log_message "$output"
  return 1
else
  print_log_message "✅ Comando ejecutado correctamente"
fi

}

grant_zone_access() {
  FROM_DATE=$(ask "From date (YYYY-MM-DD)") || return

  exec_command fred-admin --registrar_add_zone \
    --zone_fqdn="$ZONE_FQDN" \
    --handle="$REG_HANDLE" \
    --from_date="$FROM_DATE"
}


form_zone() {
  ZONE_FQDN=$(ask "Zone FQDN (ej: cz)") || exit 0  
  #ZONE_FQDN=$(ask "Zone FQDN (ej: ccr)") || return
  TTL=$(ask "TTL (ej: 18000)") || return
  HOSTMASTER=$(ask "Hostmaster email") || return
  NS_FQDN=$(ask "NS primario (ej: ns.nic.cr)") || return
}



add_registrar_acl() {
  CERT=$(ask "Certificate fingerprint") || return
  PASS=$(ask "Password") || return

  exec_command fred-admin --registrar_acl_add \
    --handle="$REG_HANDLE" \
    --certificate="$CERT" \
    --password="$PASS"
}


add_nameservers() {
  while true; do
    NS=$(ask "Agregar NS (vacío para terminar)") || return
    [ -z "$NS" ] && break

    ADDR=$(ask "IP(s) del NS (opcional)") || return

    cmd=(fred-admin --zone_ns_add --zone_fqdn="$ZONE_FQDN" --ns_fqdn="$NS")

    [ -n "$ADDR" ] && cmd+=(--addr $ADDR)

    exec_command "${cmd[@]}"
  done
}



create_zone() {
  form_zone
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

  echo "Creando zona $ZONE_FQDN"
  cmd=(fred-admin --zone_add --zone_fqdn="$ZONE_FQDN" --ex_period_min=12 --ex_period_max=120 --ttl="$TTL" --hostmaster="$HOSTMASTER" --refresh=900 --update_retr=300 --expiry=604800 --minimum=900 --ns_fqdn="$NS_FQDN")
  #cmd=(fred-admin --zone_add --zone_fqdn="$ZONE_FQDN" --ttl="$TTL")
  echo "➡️ Ejecutando comando:"
  printf ' %q' "${cmd[@]}"
  echo
  #exec_command "${cmd[@]}"
}

create_registrar() {
  cmd=(
    fred-admin --registrar_add
    --handle="$REG_HANDLE"
    --reg_name="$REG_NAME"
    --country="$COUNTRY"
  )
  

  #exec_command "${cmd[@]}"
}




#ZONE_FQDN=$(ask "Zone FQDN (ej: cz)") || exit 0
add_nameservers() {
  while true; do
    NS=$(ask "Agregar NS (vacío para terminar)") || return
    [ -z "$NS" ] && break

    ADDR=$(ask "IP(s) del NS (opcional)") || return

    cmd=(fred-admin --zone_ns_add --zone_fqdn="$ZONE_FQDN" --ns_fqdn="$NS")

    [ -n "$ADDR" ] && cmd+=(--addr $ADDR)

    exec_command "${cmd[@]}"
  done
}


create_zone

