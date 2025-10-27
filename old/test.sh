#!/bin/bash
set -e
clear



# Recupera la ruta actual del scrupit en ejecucion
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
#

gum style \
	--foreground 212 --border-foreground 212 --border double \
	--align center --width 50 --margin "1 2" --padding "2 4" \
	'Welcome to FRED CZ Instalation'

gum spin --spinner dot --title "Please wait..." -- sleep 3




# Format some markdown
gum format -- "# Instalation steps" "- 1.Pre requisites" "- Code" "- Template" "- Emoji"
#echo "# Gum Formats\n- Markdown\n- Code\n- Template\n- Emoji" | gum format


# Display your favorite emojis!
echo 'I :happy: Bubble Gum :candy:' | gum format -t emoji


gum spin --spinner dot --title "Buying Bubble Gum..." -- sleep 5


echo "Choose you instalation package..."
CARD=$(gum choose --height 15 FRED-DB  FRED-Client)
echo "Selection $CARD"


# Ejemplo: Verificar si un número es mayor a 10


if [[ "$CARD" == "FRED-DB" ]]; then
    echo "Las cadenas son iguales."
    source "$SCRIPT_DIR/ete.sh"
fi






# El script continúa aquí




gum confirm && echo "Ete" || echo "No"





gum style \
	--foreground 212 --border-foreground 212 --border double \
	--align center --width 50 --margin "1 2" --padding "2 4" \
	'jaja'

# Log some debug information.
gum log --structured --level debug "Creating file..." name file.txt
# DEBUG Unable to create file. name=temp.txt

# Log some error.
gum log --structured --level info "Unable to create file." name file.txt
# ERROR Unable to create file. name=temp.txt

# Include a timestamp.
gum log --time rfc822 --level error "Unable to create file."

gum log --time rfc822 --level warn "Unable to create file."


#gum input > answer.txt
#gum input --password > password.txt
