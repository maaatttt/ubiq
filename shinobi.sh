#!/bin/bash

node_ip=$(hostname -I|cut -d" " -f 1)

# Updates
sudo apt update && sudo apt upgrade -y

# Install NodeJS
curl -sL https://deb.nodesource.com/setup_15.x | bash -
sudo apt install -y nodejs

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
sed -i -e 's|"homepage": "."|"homepage": "https://'$node_ip'"|' /root/shinobi-interface/package.json

# Rebuild with changes and serve
npm run build
sleep 10
yarn global add serve

# Create & populate script of startup commands
sudo touch /root/startup.sh
sudo chmod +x /root/startup.sh

sudo tee /root/startup.sh &>/dev/null <<"EOF"
screen -dmS shinobi serve -s /root/shinobi-interface/build

EOF

# Insert script info to rc.local to run at system start
sed -i "13i sh /root/startup.sh" /etc/rc.local

clear

# Show user ip and port to find their instance of Shinobi
echo
echo
echo
echo "You can access Shinobi from your node by visiting "$node_ip":5000 in your web browser of choice!"
echo
echo
echo

read -p "Press ENTER to reboot."
sleep 2

reboot
