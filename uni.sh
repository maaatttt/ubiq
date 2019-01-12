#!/bin/bash

git clone https://github.com/ubiq/ubiq-net-intelligence-api.git
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo apt-get install -y build-essential
sudo npm install -g pm2
cd ubiq-net-intelligence-api
npm install
cd /mnt/ssd/node/ubiq-net-intelligence-api
sudo nano app.json
pm2 start app.json
pm2 startup
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u node --hp /home/node
pm2 save
sudo reboot
