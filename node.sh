#!/bin/bash

clear
echo "Thank you for supporting the Ubiq network! Your system will now begin configuration."
echo
echo "Your new user will be called 'node'."
echo
echo "You will now be prompted to set a password for your new user..."
echo
echo "Welcome to Ubiq!"
echo
sleep 20s
sudo adduser node
sudo usermod -G sudo node
echo "dtoverlay=pi3-disable-bt" | sudo tee -a /boot/config.txt
echo "dtoverlay=pi3-disable-wifi" | sudo tee -a /boot/config.txt
#sudo sed -i -e 's/CONF_SWAPSIZE=100/CONF_SWAPSIZE=2048/ /etc/dphys-swapfile
sudo apt-get update -q
sudo apt-get upgrade -y -q
sudo apt-get dist-upgrade -q
sudo apt-get autoremove -y -q
sudo apt-get install ntp -y -q
sudo apt-get install htop -q
sudo apt-get install supervisor -y -q
sudo apt-get install git -y -q
sudo mkfs.ext4 /dev/sda -L UBIQ
sudo mkdir /mnt/ssd
sudo mount /dev/sda /mnt/ssd
echo "/dev/sda /mnt/ssd ext4 defaults 0 0" | sudo tee -a /etc/fstab
sudo touch /etc/supervisor/conf.d/gubiq.conf
echo "[program:gubiq]" | sudo tee -a /etc/supervisor/conf.d/gubiq.conf
echo "command=/usr/bin/gubiq --verbosity 3 --rpc --rpcaddr "127.0.0.1" --rpcport "8588" --rpcapi "eth,net,web3" --maxpeers 100" | sudo tee -a /etc/supervisor/conf.d/gubiq.conf
echo "user=node" | sudo tee -a /etc/supervisor/conf.d/gubiq.conf
echo "autostart=true" | sudo tee -a /etc/supervisor/conf.d/gubiq.conf
echo "autorestart=true" | sudo tee -a /etc/supervisor/conf.d/gubiq.conf
echo "stderr_logfile=/var/log/gubiq.err.log" | sudo tee -a /etc/supervisor/conf.d/gubiq.conf
echo "stdout_logfile=/var/log/gubiq.out.log" | sudo tee -a /etc/supervisor/conf.d/gubiq.conf
cd
wget https://github.com/ubiq/go-ubiq/releases/download/v2.0.1/gubiq-linux-arm-7
sudo cp ./gubiq-linux-arm-7 /usr/bin/gubiq
sudo chmod +x /usr/bin/gubiq
sudo mv /home/node /mnt/ssd
sudo ln -s /mnt/ssd/node /home
secs=$((1 * 8))
while [ $secs -gt 0 ]; do
   echo -ne "$secs\033[0K\r"
   sleep 1
   : $((secs--))
done
sudo reboot
