#!/bin/bash

sudo apt-get update -q
sudo apt-get upgrade -y -q 
sudo supervisorctl stop gubiq
pm2 kill
sudo npm remove pm2 -g
sudo apt-get remove nodejs
sudo rm gubiq-linux-arm-7
sudo rm /usr/bin/gubiq
wget https://github.com/ubiq/go-ubiq/releases/download/v2.3.0/gubiq-linux-arm-7
sudo cp ./gubiq-linux-arm-7 /usr/bin/gubiq
sudo chmod +x /usr/bin/gubiq
sudo sed -i -e "s/--maxpeers 100/--maxpeers 100 --ethstats "temporary:password@ubiq.darcr.us"/" /etc/supervisor/conf.d/gubiq.conf
echo
echo "Type a name for your node to be displayed on the Network Stats website, then press Enter."
echo
read varname
sudo sed -i -e "s/temporary/$varname/" /etc/supervisor/conf.d/gubiq.conf
echo
echo "Your node will be named $varname"
echo
sleep 4
echo "Enter the secret to list your node on the Ubiq Stats Page, then press Enter."
echo
read varpass
sudo sed -i -e "s/password/$varpass/" /etc/supervisor/conf.d/gubiq.conf
sleep 2s
read -p "Would you like to set your node to "full" sync mode?  This will take more storage space and sync will take longer. (y/n)" CONT
if [ "$CONT" = "y" ]; then
  sudo sed -i -e "s/--maxpeers 100/--maxpeers 100 --syncmode "full"/" /etc/supervisor/conf.d/gubiq.conf 
else
  echo "Your node will sync in 'fast' mode"
  sleep 4
fi
sudo supervisorctl start gubiq
sudo reboot
