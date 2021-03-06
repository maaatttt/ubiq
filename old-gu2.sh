#!/bin/bash

sudo apt-get update -q
sudo apt-get upgrade -y -q 
sudo supervisorctl stop gubiq
sudo rm gubiq-linux-arm64
sudo rm /usr/bin/gubiq
wget https://github.com/ubiq/go-ubiq/releases/download/v3.1.0/gubiq-linux-arm64
sudo cp ./gubiq-linux-arm64 /usr/bin/gubiq
sudo chmod +x /usr/bin/gubiq
sudo supervisorctl start gubiq
sudo rm $0
sudo reboot
