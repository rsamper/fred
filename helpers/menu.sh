#!/bin/bash

# =========================
# Funciones de utilidades
# =========================

pause() {
  echo
  read -rp "Presione ENTER para volver al menú..."
}

print_header() {
  clear
  echo "========================================="
  echo "        INSTALADOR FRED (Bash)"
  echo "========================================="
  echo
}

# =========================
# Funciones de instalación
# =========================

install_db_node() {
  print_header
  echo "▶ Instalando Nodo Base de Datos..."
  echo
  install_db
  echo
  echo "Nodo Base de Datos"
  pause
}

install_fred_core() {
  print_header
  echo "▶ Instalando FRED CORE..."
  echo

  ./install_fred_core.sh

  echo
  echo "✅ FRED CORE instalado."
  pause
}

install_fred_epp() {
  print_header
  echo "▶ Instalando FRED EPP..."
  echo

  ./install_fred_epp.sh

  echo
  echo "✅ FRED EPP instalado."
  pause
}

install_fred_client() {
  print_header
  echo "▶ Instalando FRED Client..."
  echo

  ./install_fred_client.sh

  echo
  echo "✅ FRED Client instalado."
  pause
}

# =========================
# Menú principal
# =========================

main_menu() {
  while true; do
    print_header
    echo "Seleccione una opción:"
    echo
    echo "  1) Nodo Base de Datos"
    echo "  2) FRED CORE"
    echo "  3) FRED EPP"
    echo "  4) FRED Client"
    echo "  5) Salir"
    echo

    read -rp "Opción [1-5]: " OPTION

    case "$OPTION" in
      1) install_db_node ;;
      2) install_fred_core ;;
      3) install_fred_epp ;;
      4) install_fred_client ;;
      5)
        echo
        echo "Saliendo del instalador."
        exit 0
        ;;
      *)
        echo
        echo "❌ Opción inválida."
        sleep 1
        ;;
    esac
  done
}

