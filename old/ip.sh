
# ESTO FUNCIONA Y ES LA FORMA RECOMENDADA
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"


mapfile -t packages < <(grep -v '^#' "$SCRIPT_DIR/pkg.base" | grep -v '^$')
echo ${packages[@]}
