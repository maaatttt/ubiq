#!/bin/bash

clear
echo "Welcome to Ubiq!"
echo
echo "When Raspbian configurator opens, change password for user "pi" & set your timezone in localization options."
echo
echo "You will be asked to set a password for the new user called 'node'."
echo
echo "When setup is finished your node will restart automatically."
echo
sleep 15s
sudo raspi-config
sudo adduser node
sudo usermod -G sudo node
sudo apt-get update -q
sudo apt-get upgrade -y -q
sudo apt-get dist-upgrade -q
sudo apt-get autoremove -y -q
sudo apt-get install ntp -y -q
sudo apt-get install htop -q
sudo apt-get install supervisor -y -q
sudo sed -i -e "s/CONF_SWAPSIZE=100/CONF_SWAPSIZE=2048/" /etc/dphys-swapfile
sudo touch /etc/supervisor/conf.d/gubiq.conf
echo "[program:gubiq]" | sudo tee -a /etc/supervisor/conf.d/gubiq.conf
echo "command=/usr/bin/gubiq --verbosity 3 --rpc --rpcaddr "127.0.0.1" --rpcport "8588" --rpcapi "eth,net,web3" --maxpeers 100 --ethstats "temporary:password@ubiq.darcr.us"" | sudo tee -a /etc/supervisor/conf.d/gubiq.conf
echo "user=node" | sudo tee -a /etc/supervisor/conf.d/gubiq.conf
echo "autostart=true" | sudo tee -a /etc/supervisor/conf.d/gubiq.conf
echo "autorestart=true" | sudo tee -a /etc/supervisor/conf.d/gubiq.conf
echo "stderr_logfile=/var/log/gubiq.err.log" | sudo tee -a /etc/supervisor/conf.d/gubiq.conf
echo "stdout_logfile=/var/log/gubiq.out.log" | sudo tee -a /etc/supervisor/conf.d/gubiq.conf
echo
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
echo
read -p "Would you like to set your node to "full" sync mode?  This will take more storage space and sync will take longer. (y/n)" CONT
if [ "$CONT" = "y" ]; then
  sudo sed -i -e "s/--maxpeers 100/--maxpeers 100 --syncmode "full"/" /etc/supervisor/conf.d/gubiq.conf 
  echo "Your node will sync in 'full' mode"
  sleep 5s
else
  echo "Your node will sync in 'fast' mode"
  sleep 5s
fi
wget https://github.com/ubiq/go-ubiq/releases/download/v2.3.0/gubiq-linux-arm-7
sudo cp ./gubiq-linux-arm-7 /usr/bin/gubiq
sudo chmod +x /usr/bin/gubiq
sudo reboot
