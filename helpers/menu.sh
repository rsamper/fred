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
  echo "    NIC CR -  INSTALADOR FRED (Bash)"
  echo "========================================="
  echo
}

# =========================
# Funciones de instalación
# =========================

install_all_nodes() {
  print_header
  echo "▶ Installing Database Node/Instalando Nodo Base de Datos..."
  echo
  
  source "$DB_FILE"
  source "$APP_FILE"
  source "$CLIENT_FILE"
  source "$EPP_FILE"
  install_db
  install_app
  install_epp
  pause
}

install_db_node() {
  print_header
  echo "▶ Installing Database Node/Instalando Nodo Base de Datos..."
  echo
  source "$DB_FILE"
  install_db
  pause
}

install_fred_core() {
  print_header
  echo "▶ Instalando FRED CORE APP..."
  echo
  source "$APP_FILE"
  install_app
}

install_fred_epp() {
  print_header
  echo "▶ Instalando FRED EPP..."
  echo
  source "$EPP_FILE"
  install_epp
 pause
}

install_fred_web() {
  print_header
  echo "▶ Instalando FRED Web..."
  echo
  source "$WEB_FILE"
  install_web
 pause
}

install_fred_HM() {
  print_header
  echo "▶ Instalando FRED HM..."
  echo
  source "$HM_FILE"
  install_hm
 pause
}

install_fred_minimal() {
  print_header
  echo "▶ Instalando FRED Minimal..."
  echo
  source "$MINIMAL_FILE"
  install_minimal
  pause
}

install_fred_client() {
  print_header
  echo "▶ Instalando FRED Client..."
  echo
  source "$CLIENT_FILE"
  install_client
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
    echo "  1) Database Node"
    echo "  2) FRED APP Node"
    echo "  3) FRED EPP"
    echo "  4) FRED Web Node"
    echo "  5) FRED HM Node"
    echo "  6) FRED Minimal"
    echo "  7) FRED Client"
    echo "  8) Todo en uno (Demo)"
    echo "  9) Salir"
    echo

    read -rp "Opción [1-5]: " OPTION

    case "$OPTION" in
      1) install_db_node ;;
      2) install_fred_core ;;
      3) install_fred_epp ;;
      4) install_fred_web ;;
      5) install_fred_HM ;;
      6) install_fred_minimal ;;
      7) install_fred_client ;;
      8) install_all_nodes ;;
      9)
        echo
        echo "Hasta pronto/ Bye !!!!!"
        sleep 1
        clear
        exit 0
        ;;
      *)
        echo
        echo "Opción inválida."
        sleep 1
        ;;
    esac
  done
}

