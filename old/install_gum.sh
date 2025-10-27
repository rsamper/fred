#!/bin/bash
echo "Please wait. Installing Gum..."
sudo mkdir -p /etc/apt/keyrings
GPG_FILE="/etc/apt/keyrings/charm.gpg"
if [ ! -f "$GPG_FILE" ]; then
   echo "El archivo $ARCHIVO charm.gpg no existe. Procediendo a crearlo o a ejecutar una acción."
   curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
fi
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
sudo apt update && sudo apt install gum
gum spin --spinner dot --title "Gum...Ok !!!..." -- sleep 1
