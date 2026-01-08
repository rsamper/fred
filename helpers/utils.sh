#!/bin/bash
# Script: util.sh
# Description: Funciones generales utiles
# Author: Ricardo Samper rsamper@nic.cr
# Date: 2025-10-10

get_db_packages(){
    local cmd="$*"
    echo $cmd
    mapfile -t packages < <(grep -v '^#' "$*" | grep -v '^$')
    echo ${packages[@]}
   
}

draw_bar() {
  local percent=$1
  local width=40
  local filled=$(( percent * width / 100 ))
  local empty=$(( width - filled ))

  printf "\r["
  printf "%0.s#" $(seq 1 "$filled")
  printf "%0.s-" $(seq 1 "$empty")
  printf "] %3d%%" "$percent"
}



# Timestamp para logs
timestamp() {
 date +"[%Y-%m-%d %H:%M:%S]"
}

pause(){
  sleep 1
  # Pausa hasta que el usuario presione una tecla
  read -n 1 -s -r -p "Presiona cualquier tecla para continuar..."
  echo
  #echo "Continuando la ejecución..."

}

print_log_message(){
   local text="$*"
   # Si el primer parámetro es "--quiet", no mostrar en pantalla
   if $QUIET_MODE; then
        # Solo guarda en log
        printf "\n"
        echo "$(timestamp) - $text" >> "$log_file"
        
    else
        # Muestra en pantalla y guarda en log
        echo "$(timestamp) - $text" | tee -a "$log_file"
    fi
}

print_message(){
   local text="$*"
    # Muestra en pantalla y guarda en log
    printf "\n"
    echo "$(timestamp) - $text" | tee -a "$log_file"
}

print_notime(){
  local text="$*"
  # Si el primer parámetro es "--quiet", no mostrar en pantalla
  # Muestra en pantalla y guarda en log
  echo "$text" | tee -a "$log_file"
}

print_step() {
  local titulo="$1"
  local longitud=${#titulo}
  echo -e "\033[1;36m$titulo\033[0m"
  printf '\033[1;36m%*s\033[0m\n' "$longitud" '' | tr ' ' '='
}

print_title(){
  local text="$*"
   width=$(tput cols)
   padding=$(( (width - ${#text}) / 2 ))
   printf "%${padding}s%s%${padding}s\n" "" "$text" ""
}

check_file(){
  if [ ! -f "$*" ]; then
    print_log_message "❌ El archivo $* no existe"
    print_log_message "End exit code 1"
    exit 1
fi
}

check_root(){
  if [ "$EUID" -ne 0 ]
   then print_log_message "❌ Please run installation as root."
   exit 1
  fi
  print_log_message "✅ Root user OK."
}

# --- Verificar versión del sistema operativo ---
check_os() {
  print_log_message "Verificando versión del sistema operativo..."

  if [ -f /etc/os-release ]; then
    # Cargar variables del archivo /etc/os-release
    . /etc/os-release

    OS_ID="${ID:-unknown}"
    OS_VERSION="${VERSION_ID:-unknown}"

    if { [ "$OS_ID" = "ubuntu" ] && [ "$OS_VERSION" = "20.04" ]; } || \
       { [ "$OS_ID" = "debian" ] && [ "$OS_VERSION" = "10" ]; }; then
      print_log_message "✅ Sistema operativo compatible: $PRETTY_NAME"
    else
      print_log_message "❌ Sistema operativo no compatible: $PRETTY_NAME"
      print_log_message "Solo se admite Ubuntu 20.04 o Debian 10."
      exit 1
    fi
  else
    print_log_message "❌ No se pudo determinar el sistema operativo (no existe /etc/os-release)."
    exit 1
  fi
}


install() {
  # Inicializamos los contadores como variables locales para que se reinicien en cada llamada
  local ok=0
  local fail=0
  local ya_instalado=0

  # Arrays para gestionar los paquetes
  local paquetes_solicitados=("$@")
  local paquetes_a_instalar=()
  local default_paquetes=("htop" "curl" "wget")
  
  # Si no se pasan argumentos, usar la lista por defecto
  if [ ${#paquetes_solicitados[@]} -eq 0 ]; then
    paquetes_solicitados=("${default_paquetes[@]}")
    print_log_message "ℹ️ No se especificaron paquetes. Usando la lista por defecto: ${paquetes_solicitados[*]}"
    exit 1
  fi

  #print_log_message "Verificando paquetes: ${paquetes_solicitados[*]}"
  print_log_message "🔍 Verificando estado de los paquetes solicitados..." | tee -a "$log_file"

  # 1. PRIMER BUCLE: VERIFICAR QUÉ NECESITA SER INSTALADO
  for paquete in "${paquetes_solicitados[@]}"; do
    if dpkg -s "$paquete" >/dev/null 2>&1; then
      print_log_message "✅ El paquete '$paquete' ya está instalado." | tee -a "$log_file"
      ((ya_instalado++))
    else
      print_log_message "📝 El paquete '$paquete' se instalará." | tee -a "$log_file"
      paquetes_a_instalar+=("$paquete")
    fi
  done
 
  # 2. INSTALACIÓN EN LOTE (SI ES NECESARIO)
  if [ ${#paquetes_a_instalar[@]} -gt 0 ]; then
    #print_log_message "📦 Iniciando instalación de: ${paquetes_a_instalar[*]}" | tee -a "$log_file"
    print_log_message "📦 Iniciando instalación de paquetes. Por favor espere..." | tee -a "$log_file"
    
    # La redirección correcta para capturar salida y error es "2>&1"
    if salida=$(sudo apt install -y "${paquetes_a_instalar[@]}" 2>&1); then
      print_log_message "✅ Todos los paquetes nuevos fueron instalados correctamente." | tee -a "$log_file"
      ok=${#paquetes_a_instalar[@]} # Todos los que intentamos, se instalaron
    else
      print_log_message "❌ Ocurrió un error durante la instalación." | tee -a "$log_file"
      # Guardamos el log del error
      echo "$salida" | sed "s/^/$(timestamp) ERROR: /" | tee -a "$log_file"
      print_log_message  "Fin con error .....$salida" 
     exit 1
 
      # Esta parte es una estimación. APT falla como un todo, por lo que marcamos todos como fallidos.
      fail=${#paquetes_a_instalar[@]} 
    fi
  else
    print_log_message "👍 No hay paquetes nuevos para instalar." | tee -a "$log_file"
  fi

  # 3. RESUMEN FINAL
  print_log_message "----------------------------------------------------"
  print_log_message "📊 Resumen final:" | tee -a "$log_file"
  print_log_message "✅ Instalados en esta ejecución: $ok" | tee -a "$log_file"
  print_log_message "❌ Fallidos: $fail" | tee -a "$log_file"
  print_log_message "ℹ️ Ya estaban instalados: $ya_instalado" | tee -a "$log_file"
  print_log_message "📝 Revisa '$log_file' para más detalles." | tee -a "$log_file"
  sleep 2
}


exec_command() {
    local cmd="$*"
    # Ejecuta el comando y captura salida y código de error
    print_log_message "Ejecutando..."
    #print_log_message "Ejecutando $cmd"
    #output=$(eval "$cmd" 2>&1)
    output=$( "$@" 2>&1 )
    local status=$?
    if [ $status -ne 0 ]; then
        QUIET_MODE=false
        print_log_message "❌ ERROR: Falló el comando: $cmd  - error: $output"
        exit 1
    fi
    print_log_message "✅ OK: El comando se ejecutó correctamente: $cmd"
    
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
     print_log_message "Finalizdo. Operación cancelada por el usuario."
     echo ""
      #exit 1
      return 1
      ;;
  esac
}

install_whiptail() {
  apt install whiptail -y
}


################################33

#print_log_message(){
#   local show=true
#   local text="$*"
#   #echo "$(timestamp) - $text" | tee -a "$log_file"
#   # Si el primer parámetro es "--quiet", no mostrar en pantalla
#    if [[ "$1" == "--quiet" ]]; then
#        show=false
#        shift  # remueve --quiet, de modo que el primer parametro sera el texto
#    fi
#    text="$*"
#    if $show; then
#        # Muestra en pantalla y guarda en log
#        echo "$(timestamp) - $text" | tee -a "$log_file"
#    else
#        # Solo guarda en log
#        echo "$(timestamp) - $text" >> "$log_file"
#    fi
#}
