#!/bin/bash
clear
yes '' | sed 4q
cat << "EOF"
   ▄████████    ▄█    █▄     ▄█  ███▄▄▄▄    ▄██████▄  ▀█████████▄   ▄█
  ███    ███   ███    ███   ███  ███▀▀▀██▄ ███    ███   ███    ███ ███
  ███    █▀    ███    ███   ███▌ ███   ███ ███    ███   ███    ███ ███▌
  ███         ▄███▄▄▄▄███▄▄ ███▌ ███   ███ ███    ███  ▄███▄▄▄██▀  ███▌
▀███████████ ▀▀███▀▀▀▀███▀  ███▌ ███   ███ ███    ███ ▀▀███▀▀▀██▄  ███▌
         ███   ███    ███   ███  ███   ███ ███    ███   ███    ██▄ ███
   ▄█    ███   ███    ███   ███  ███   ███ ███    ███   ███    ███ ███
 ▄████████▀    ███    █▀    █▀    ▀█   █▀   ▀██████▀  ▄█████████▀  █▀


Thank you for supporting the Ubiq network!

This script will install the Shinobi interface locally on this system.

You will then be able to access the page from anywhere on your local network.

EOF

read -p "Press ENTER to continue to setup."

# Set ip, hardware type, and architecture variables
node_ip=$(hostname -I|cut -d" " -f 1)

if grep -q 'Raspberry' /proc/device-tree/model; then
	hardware=RaspberryPi
	arch=32bit
elif grep -q 'Tinker' /proc/device-tree/model; then
	hardware=Tinkerboard
	arch=32bit
elif grep -q 'XU4' /proc/device-tree/model; then
	hardware=OdroidXU4
	arch=32bit
elif grep -q 'ODROID-C2' /proc/device-tree/model; then
	hardware=OdroidC2
	arch=64bit
elif grep -q 'Libre' /proc/device-tree/model; then
	hardware=LibreLePotato
	arch=64bit
fi

# Updates
sudo apt update && sudo apt upgrade -y

# Install git
sudo apt install git

# Install NodeJS
curl -sL https://deb.nodesource.com/setup_15.x | bash -
sudo apt install -y nodejs

# Install npm & screen on Raspberry Pi, is preinstalled on Armbian
if [ $hardware = RaspberryPi ]; then
sudo apt install npm -y
sudo apt install screen -y
else echo "npm is installed, screen is installed"
fi

# Install yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install yarn

# Install Shinobi Interface & build it
git clone https://github.com/octanolabs/shinobi-interface
cd shinobi-interface
yarn
yarn build

sleep 10

# Insert IP Address info to Homepage field on package.json file
if [ $hardware = RaspberryPi ]; then
sed -i -e 's|"homepage": "."|"homepage": "https://'$node_ip'"|' /home/pi/shinobi-interface/package.json
elif [ $hardware != RaspberryPi ]; then
sed -i -e 's|"homepage": "."|"homepage": "https://'$node_ip'"|' /root/shinobi-interface/package.json
fi

# Rebuild with changes and serve
sudo npm run build
sleep 10
sudo yarn global add serve
sudo npm install -g serve

# Create & populate script of startup commands
if [ $hardware = RaspberryPi ]; then
sudo touch /home/pi/startup.sh
sudo chmod +x /home/pi/startup.sh
sudo tee /home/pi/startup.sh &>/dev/null <<"EOF"
screen -dmS shinobi serve -s -p 8888 /home/pi/shinobi-interface/build

EOF

elif [ $hardware != RaspberryPi ]; then
sudo touch /root/startup.sh
sudo chmod +x /root/startup.sh
sudo tee /root/startup.sh &>/dev/null <<"EOF"
screen -dmS shinobi serve -s -p 8888 /root/shinobi-interface/build

EOF
fi

# Insert script info to rc.local to run at system start
if [ $hardware = RaspberryPi ]; then
sudo sed -i "19i sh /home/pi/startup.sh" /etc/rc.local
elif [ $hardware != RaspberryPi ]; then
sed -i "13i sh /root/startup.sh" /etc/rc.local
fi

# Show user ip and port to find their instance of Shinobi
clear
echo
echo
echo
echo "You can access Shinobi from your node by visiting "$node_ip":8888 in your web browser of choice!"
echo
echo
echo

read -p "Press ENTER to reboot."
sleep 2

sudo reboot
