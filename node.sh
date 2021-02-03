#!/bin/bash
clear
yes '' | sed 4q
cat << "EOF"
88888      88  88888888888     88888      88888888
88888      88  88888     88    88888    8888      88
88888      88  88888      88   88888   88888        88
88888      88  88888      88   88888  888888         88
88888      88  88888     88    88888  888888         88
88888      88  88888888888     88888  888888     8   88
88888      88  88888      88   88888  888888     88  88
88888      88  88888       88  88888   88888      88 8
 8888     88   88888      88   88888    8888       88
  888888888    88888888888     88888      888888888 88




Thank you for supporting the Ubiq network by maintaining a node!

This script will handle setup on the following systems;

- Raspberry Pi 3B, 3B+, or 4B running Raspberry Pi OS or Raspberry Pi OS Lite

- Asus Tinkerboard / Tinkerboard S running Armbian

- Odroid XU4 running Armbian

- Odroid C2 running Armbian

- Libre LePotato running Armbian

EOF
read -p "Press ENTER to continue to setup."

#### Setting variables naming the hardware being used, and its architecture.
#### Any hardware variants discoverd to work with this script will be added over time.

node_ip=$(hostname -I | cut -f1 -d' ')

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
clear

#### Raspberry Pi's will create a new user called "node" and assign permissions.  Armbian systems will remind about certain settings.

if [ $hardware = RaspberryPi ]; then
cat << "EOF"
Your new user will be called 'node'.

You will now be prompted to set a password for your new user...

When prompted to fill in personal details, you may leave it blank.

Welcome to Ubiq!
EOF
	echo
  	read -p "Press ENTER to continue..."
	clear
	sudo adduser node
  	sudo usermod -G sudo node
  	sudo sed -i -e "s/CONF_SWAPSIZE=100/CONF_SWAPSIZE=2048/" /etc/dphys-swapfile
  	sudo /etc/init.d/dphys-swapfile restart

elif [ $hardware != RaspberryPi ]; then
cat << "EOF"
If you are running Armbian, you created the user called 'node' and set it's password on first boot.

You should have also set up the network connection & adjusted the timezone settings.

When the setup process is complete, your system will restart.

Welcome to Ubiq!
EOF
echo
	read -p "Press ENTER to continue..."
fi

clear

#### Update, Upgrade, Optimize & install NTP, HTOP, Supervisor and git

sudo apt update -q
sudo apt upgrade -y -q
sudo apt dist-upgrade -q
sudo apt autoremove -y -q
sudo apt install ntp -y -q
sudo apt install htop -q
sudo apt install supervisor -y -q
sudo apt install git -y -q
sudo mkfs.ext4 /dev/sda -L UBIQ
sudo mkdir /mnt/ssd
sudo mount /dev/sda /mnt/ssd
echo "/dev/sda /mnt/ssd ext4 defaults 0 0" | sudo tee -a /etc/fstab

#### Setting up the Supervisor conf file. This file allows Supervisor to keep gubiq processes constantly alive.

sudo touch /etc/supervisor/conf.d/gubiq.conf
sudo tee /etc/supervisor/conf.d/gubiq.conf &>/dev/null <<"EOF"
[program:gubiq]
command=/usr/bin/gubiq --verbosity 3 --http --http.addr "127.0.0.1" --http.port "8588" --http.api "eth,net,web3" --http.corsdomain "*" --http.vhosts "*" --maxpeers 100
user=node
autostart=true
autorestart=true
stderr_logfile=/var/log/gubiq.err.log
stdout_logfile=/var/log/gubiq.out.log

EOF

sudo sed -i -e "s/127.0.0.1/$node_ip/" /etc/supervisor/conf.d/gubiq.conf
clear

#### Giving the user the option to list their node on the Ubiq Network stats page, found at 'https://ubiq.gojupiter.tech'.

echo
read -p "Would you like to be listed on the Ubiq Network Stats Page? Your node name & and some details would be publicly available on 'https://ubiq.gojupiter.tech'. (y/n)" CONT
if [ "$CONT" = "y" ]; then
	sudo sed -i -e "s/--maxpeers 100/--maxpeers 100 --ethstats "temporary:password@ubiq-rpc.gojupiter.tech"/" /etc/supervisor/conf.d/gubiq.conf
  	echo "Type a name for your node to be displayed on the Network Stats website, then press Enter."
	echo
  	read varname
  	sudo sed -i -e "s/temporary/$varname/" /etc/supervisor/conf.d/gubiq.conf
  	echo
  	echo "Your node will be named $varname"
  	echo
  	sleep 4
  	echo "Enter the secret to list your node on the Ubiq Stats Page, then press ENTER."
  	echo
  	read varpass
  	sudo sed -i -e "s/password/$varpass/" /etc/supervisor/conf.d/gubiq.conf
  	echo
	echo "Your node will be listed..."
	echo
else
	echo
	echo "Your node will not be listed on the public site..."
fi
yes '' | sed 5q

#### If you are using Raspberry Pi OS, SSH is not enabled by default like it is on systems running Armbian.

if [ $hardware != RaspberryPi ]; then
	echo "SSH is active by default with Armbian. This will allow you to log in and operate your node from another machine on your network."
elif [ $hardware = RaspberryPi ]; then
	read -p "Would you like to enable SSH on this system? This will allow you to log in and operate your node from another machine on your network. (y/n)" CONT
	if [ $CONT = y ]; then
  		sudo raspi-config nonint do_ssh 0
		echo
		echo "SSH has been enabled"
		sleep 4
	else
  		echo "SSH is not active on this system.  To enable SSH in the future, you can do so in the raspi-config menu."
  		sleep 4
	fi
fi
yes '' | sed 5q

#### Giving the user the option to sync all blocks in full, or sync in "fast" mode which saves space...

read -p "Would you like to set your node to sync in 'full archive' mode?  This will take more storage space and sync will take longer. (y/n)" CONT
if [ "$CONT" = "y" ]; then
	sudo sed -i -e "s/--maxpeers 100/--maxpeers 100 --syncmode "full" --gcmode "archive"/" /etc/supervisor/conf.d/gubiq.conf
  echo
  echo "Your node will sync in 'full archive' mode."
	sleep 4
else
  echo
  echo "Your node will sync in 'fast' mode"
	sleep 4
fi
yes '' | sed 5q

#### Giving the user an option to let the system automatically update gubiq using a cron job.

read -p "Would you like your node to download the most currnet gubiq binary file monthly?   If a new version is released, this will automatically replace the outdated one. (y/n)" CONT
if [ "$CONT" = "y" ]; then
	touch auto.sh
	chmod +x auto.sh
	tee auto.sh &>/dev/null << "EOF"
#!/bin/bash

wget https://raw.githubusercontent.com/maaatttt/ubiq/master/gu.sh
sudo chmod +x gu.sh
./gu.sh
EOF
  echo "@monthly ./auto.sh" | crontab -
  echo
  echo "Your node will download the most current version of gubiq, and restart its processes on the first of every month"
	sleep 6
else
  echo
  echo "Your node will NOT automatically update gubiq.  All updates must be handled manually!"
  sleep 4
fi
echo

#### System will determine the correct binary file to download based on how it was defined at the beginning of this script.
#### The binary file's checksum will be validated.  If it is valid, the script will complete the setup. If it is invalid, it will exit setup.

if [ $arch = 32bit ]; then
        wget https://github.com/ubiq/go-ubiq/releases/download/v5.0.0/gubiq-linux-arm-7
        echo "598553a57e68b8d0c298481ce1fc99d0df6df63b44c64e128ce7af38681e302e  gubiq-linux-arm-7" | sha256sum -c - || exit 1
        sudo cp ./gubiq-linux-arm-7 /usr/bin/gubiq
elif [ $arch = 64bit ]; then
        wget https://github.com/ubiq/go-ubiq/releases/download/v5.0.0/gubiq-linux-arm64
        echo "1939ef3a8776b3ff7bda368edfda53efee2815f9682922725ab4241a301d605d gubiq-linux-arm64" | sha256sum -c - || exit 1
        sudo cp ./gubiq-linux-arm64 /usr/bin/gubiq
fi
echo

#### Changing permissions, moving and linking the user's home folder, and rebooting the system to begin blockchain sync.

sudo chmod +x /usr/bin/gubiq
sudo mv /home/node /mnt/ssd
sudo ln -s /mnt/ssd/node /home
clear
yes '' | sed 4q
echo "The setup is complete. Sync will begin automatically when the system restarts."
echo
read -p "Press ENTER to reboot now."
echo
secs=$((1 * 8))
while [ $secs -gt 0 ]; do
   echo -ne "$secs\033[0K\r"
   sleep 1
   : $((secs--))
done
sudo reboot
