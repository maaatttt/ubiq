#!/bin/bash
clear
yes '' | sed 4q
cat << "EOF"
88888      88  88888888888     88888      88888888
88888      88  88888     88    88888    8888      88
88888      88  88888      88   88888   88888        88
88888      88  88888      88   88888  888888         88
88888      88  88888     88    88888  888888         88
88888      88  88888888888     88888  888888      8  88
88888      88  88888      88   88888  888888       8 88
88888      88  88888       88  88888   88888        88
 8888    888   88888      88   88888    8888      88 8
  88888888     88888888888     88888      88888888    8




Thank you for supporting the Ubiq network by maintaining a node!

This script will handle setup on the following systems;

- Raspberry Pi 3B, 3B+, or 4B running Raspberry Pi OS or Raspberry Pi OS Lite

- Asus Tinkerboard / Tinkerboard S running Armbian

- Odroid XU4 running Armbian

- Odroid C2 running Armbian

- Libre LePotato running Armbian

EOF
read -p "Press enter to continue to setup."

#### A list of compatible hardware, which will be updated as new options become available and have been tested.

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

#### Let's make some helpful changes and additions...

if [ $hardware = RaspberryPi ]; then
	echo
	echo "Your new user will be called 'node'."
    	echo
    	echo "You will now be prompted to set a password for your new user..."
	echo
    	echo "When prompted to fill in personal details, you may leave it blank."
    	echo
    	echo "Welcome to Ubiq!"
	echo
  	read -p "Press enter to continue..."
	clear
	sudo adduser node
  	sudo usermod -G sudo node
  	sudo sed -i -e "s/CONF_SWAPSIZE=100/CONF_SWAPSIZE=2048/" /etc/dphys-swapfile
  	sudo /etc/init.d/dphys-swapfile restart

elif [ $hardware != RaspberryPi ]; then
	echo
	echo "If you are running Armbian you created the user called 'node' and set it's password on first boot."
	echo
	echo "You should have also set up the network connection & adjusted the timezone settings."
  	echo
  	echo "When the setup process is complete, your system will restart."
  	echo
  	echo "Welcome to Ubiq!"
  	echo
	read -p "Press enter to continue..."
fi

clear

sudo apt update -q
sudo apt upgrade -y -q
sudo apt dist-upgrade -q
sudo apt autoremove -y -q
sudo apt install ntp -y -q
sudo apt install htop -q
sudo apt install supervisor -y -q
sudo apt install git -y -q
sudo mkfs.ext4 /dev/sda -L UBIQ # can you do this quietly?
sudo mkdir /mnt/ssd # can you do this quietly?
sudo mount /dev/sda /mnt/ssd # can you do this quietly?
echo "/dev/sda /mnt/ssd ext4 defaults 0 0" | sudo tee -a /etc/fstab

#### Setting up the Supervisor conf file so our node will keep itself online

touch /etc/supervisor/conf.d/gubiq.conf
tee /etc/supervisor/conf.d/gubiq.conf &>/dev/null <<"EOF"
[program:gubiq]
command=/usr/bin/gubiq --verbosity 3 --rpc --rpcaddr "127.0.0.1" --rpcport "8588" --rpcapi "eth,net,web3" --maxpeers 100
user=node
autostart=true
autorestart=true
stderr_logfile=/var/log/gubiq.err.log
stdout_logfile=/var/log/gubiq.out.log

EOF
clear

#### If you want, you have the option to list your node on the stats page.

echo
read -p "Would you like to list your node on the Ubiq Network Stats Page? This will make your node name & stats available on 'https://ubiq.gojupiter.tech'. (y/n)" CONT
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
  	echo "Enter the secret to list your node on the Ubiq Stats Page, then press Enter."
  	echo
  	read varpass
  	sudo sed -i -e "s/password/$varpass/" /etc/supervisor/conf.d/gubiq.conf
  	echo
else
	echo "Your node will not be listed on the public site..."
fi
yes '' | sed 5q

#### If you are using a Raspberry Pi, SSH is not enabled by default like it is on systems running Armbian.

if [ $hardware != RaspberryPi ]; then
	echo "SSH is active by default with Armbian. This will allow you to log in and operate your node from another machine on your network."
elif [ $hardware = RaspberryPi ]; then
	read -p "Would you like to enable SSH on this system? This will allow you to log in and operate your node from another machine on your network. (y/n)" CONT
	if [ $CONT = y ]; then
  		sudo raspi-config nonint do_ssh 0
		echo "SSH has been enabled"
		sleep 4
	else
  		echo "SSH is not active on this system.  To enable SSH in the future, you can do so in the raspi-config menu."
  		sleep 4
	fi
fi
yes '' | sed 5q

#### You can choose to sync of all block info, or sync in fast mode to save space...

read -p "Would you like to set your node to "full" sync mode?  This will take more storage space and sync will take longer. (y/n)" CONT
if [ "$CONT" = "y" ]; then
	sudo sed -i -e "s/--maxpeers 100/--maxpeers 100 --syncmode "full" --gcmode "archive"/" /etc/supervisor/conf.d/gubiq.conf
	echo "Your node will sync in full, including all details of all blocks."
	sleep 4
else
	echo "Your node will sync in 'fast' mode"
	sleep 4
fi
yes '' | sed 5q

#### You have the option of letting your system re-fetch gubiq binaries once a month.  If there is an update, it'll sort itself out.

read -p "Would you like to allow your node to auto-fetch the gubiq binaries once per month?  This will keep your node on the latest release without your interaction. (y/n)" CONT
if [ "$CONT" = "y" ]; then
	cd
  	sudo touch auto.sh
	sudo chmod +x auto.sh
	echo "#!/bin/bash" | sudo tee -a auto.sh
  	echo "" | sudo tee -a auto.sh
  	echo "wget https://raw.githubusercontent.com/maaatttt/ubiq/master/gu.sh" | sudo tee -a auto.sh
  	echo "sudo chmod +x gu.sh" | sudo tee -a auto.sh
  	echo "./gu.sh" | sudo tee -a auto.sh
  	echo "@monthly ./auto.sh" | crontab -
	echo "Your node will download the most current version of gubiq, and restart its processes on the first of every month"
	sleep 6
else
  	echo "Your node will NOT automatically update gubiq.  All updates must be handled manually!"
  	sleep 4
fi
echo

#### Your system will pick the correct binary file to download based on how it was defined at the beginning of this script.
#### The checksum will be validated.  If valid the script will complete the setup, if invalid it will exit setup.

if [ $arch = 32bit ]; then
        wget https://github.com/ubiq/go-ubiq/releases/download/v3.1.0/gubiq-linux-arm-7
        echo "f733349c34e466e30abf340e4ee677dd7c462df0b7c0bf0c75c9cd0dbb15faf1  gubiq-linux-arm-7" | sha256sum -c - || exit 1
        sudo cp ./gubiq-linux-arm-7 /usr/bin/gubiq
elif [ $arch = 64bit ]; then
        wget https://github.com/ubiq/go-ubiq/releases/download/v3.1.0/gubiq-linux-arm64
        echo "5978700da6087fd78ffe913d90c48530e3d5f7f7927653020263b12649308194 gubiq-linux-arm64" | sha256sum -c - || exit 1
        sudo cp ./gubiq-linux-arm64 /usr/bin/gubiq
fi
echo

#### Finishing up, moving home folder to the external drive and creating a symbolic link.

sudo chmod +x /usr/bin/gubiq
sudo mv /home/node /mnt/ssd
sudo ln -s /mnt/ssd/node /home
clear
yes '' | sed 4q
echo "Your node's configuration is complete. Sync will begin automatically when the system restarts."
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
