# Este archivo contiene funciones

#Setyting up required variables

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

SECONDS=0 # Reinicia el contador de tiempo a cero
LOG_FILE_NAME="install.log"

# Counters
OK=0
FAIL=0
INSTALLED=0
TOTAL_STEPS=16


# Función que toma dos argumentos, los suma y los imprime.
saludar_y_sumar() {
    local nombre="$1"
    local num1="$2"
    local num2="$3"
    local suma=$((num1 + num2))

    echo "Hola, $nombre. La suma de $num1 y $num2 es: $suma"
    # El resultado de la función es 0 (éxito) por defecto, a menos que se use 'return'
}

timestamp() {
 date +"[%Y-%m-%d %H:%M:%S]"
}

#Exceute a command, and capture error if exist
run_or_fail() {
    local command="$*"
    echo "$(timestamp) Executing: $command"
    # Ejecuta el comando y captura salida y código de error
    output=$(eval "$command" 2>&1)
    local status=$?

    if [ $status -ne 0 ]; then
        echo "❌ ERROR: Command failure: $command" | tee -a "$LOG_FILE_NAME"
        echo "🔍 Error Details: $output" | tee -a "$LOG_FILE_NAME"
        #echo "$output"
        exit $status
    else
        echo "✅ OK: Command executed succesfully. $command" | tee -a "$LOG_FILE_NAME"
    fi
    sleep 1
}

# Install  packages
apt_install() {
  # Inicializamos los contadores como variables locales para que se reinicien en cada llamada
  local ok=0
  local fail=0
  local installed=0

  # Arrays para gestionar los paquetes
  local request_packages=("$@")
  local packages_to_install=()
  local default_packages=("htop" "curl" "wget")


  # Si no se pasan argumentos, usar la lista por defecto
  if [ ${#request_packages[@]} -eq 0 ]; then
    # paquetes_solicitados=("${default_packages[@]}")
    echo "ℹ️ No se especificaron paquetes. Usando la lista por defecto: ${request_packages[*]}"
   exit 1  
fi

  echo "Verificando paquetes: ${request_packages[*]}"
  echo "$(timestamp) 🔍 Verificando estado de los paquetes solicitados..." | tee -a "$LOG_FILE_NAME"

  # 1. PRIMER BUCLE: VERIFICAR QUÉ NECESITA SER INSTALADO
  for package in "${request_packages[@]}"; do
    if dpkg -s "$package" >/dev/null 2>&1; then
      echo "$(timestamp) ✅ El paquete '$package' ya está instalado." | tee -a "$LOG_FILE_NAME"
      ((installed++))
    else
      echo "$(timestamp) 📝 El paquete '$package' se instalará." | tee -a "$LOG_FILE_NAME"
      packages_to_install+=("$package")
    fi
  done
 
  # 2. INSTALACIÓN EN LOTE (SI ES NECESARIO)
  if [ ${#packages_to_install[@]} -gt 0 ]; then
    echo "$(timestamp) 📦 Iniciando instalación de: ${packages_to_install[*]}" | tee -a "$LOG_FILE_NAME"
    # La redirección correcta para capturar salida y error es "2>&1"
    if salida=$(sudo apt install -y "${packages_to_install[@]}" 2>&1); then
      echo "$(timestamp) ✅ Todos los paquetes nuevos fueron instalados correctamente." | tee -a "$LOG_FILE_NAME"
      ok=${#packages_to_install[@]} # Todos los que intentamos, se instalaron
    else
      echo "$(timestamp) ❌ Ocurrió un error durante la instalación." | tee -a "$LOG_FILE_NAME"
      # Guardamos el log del error
      echo "$salida" | sed "s/^/$(timestamp) ERROR: /" | tee -a "$LOG_FILE_NAME"
     echo "Fin con error .....$salida" 
     exit 1
 
      # Esta parte es una estimación. APT falla como un todo, por lo que marcamos todos como fallidos.
      fail=${#packages_to_install[@]} 
    fi
  else
    echo "$(timestamp) 👍 No hay paquetes nuevos para instalar." | tee -a "$LOG_FILE_NAME"
  fi
  # 3. RESUMEN FINAL
  echo "----------------------------------------------------"
  echo "$(timestamp) 📊 Resumen final:" | tee -a "$log_file"
  echo "$(timestamp) ✅ Instalados en esta ejecución: $ok" | tee -a "$LOG_FILE_NAME"
  echo "$(timestamp) ❌ Fallidos: $fail" | tee -a "$LOG_FILE_NAME"
  echo "$(timestamp) ℹ️ Ya estaban instalados: $ya_instalado" | tee -a "$LOG_FILE_NAME"
  echo "$(timestamp) 📝 Revisa '$LOG_FILE_NAME' para más detalles." | tee -a "$LOG_FILE_NAME"
  sleep 2
  clear
}

