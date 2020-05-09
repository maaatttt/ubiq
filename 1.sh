#!/bin/bash

#### WELCOME! Are you using the right hardware?

echo
echo "Thank you for supporting the Ubiq network by running a node!"
echo
echo "This is meant to handle setup on the following systems..."
echo
echo " - Raspberry Pi 2B, 3B, 3B+, or 4B running Raspbian or Raspbian Lite "
echo
echo " - Odroid C2 running Armbian "
echo
echo " - Odroid XU4 running Armbian "
echo
echo " - Asus Tinkerboard, Tinkerboard S running Armbian "
echo
echo " - Libre LePotato running Armbian "
echo
read -p "Press enter to continue to setup."

#### A list of compatible hardware, which will be updated as new options become available and have been tested.

if grep -q 'Raspberry' /proc/device-tree/model;
then hardware=RaspberryPi
elif grep -q 'Tinker' /proc/device-tree/model;
then hardware=Tinkerboard
elif grep -q 'XU4' /proc/device-tree/model;
then hardware=OdroidXU4
elif grep -q 'ODROID-C2' /proc/device-tree/model;
then hardware=OdroidC2
elif grep -q 'Libre' /proc/device-tree/model;
then hardware=LibreLePotato
fi
clear

#### Let's make some helpful changes and additions...

if [ $hardware = RaspberryPi ];
then
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
fi

if [ $hardware != RaspberryPi ];
then
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
sudo mkfs.ext4 /dev/sda -L UBIQ
sudo mkdir /mnt/ssd
sudo mount /dev/sda /mnt/ssd
echo "/dev/sda /mnt/ssd ext4 defaults 0 0" | sudo tee -a /etc/fstab

#### Let's set up our Supervisor conf file so our node will keep itself online

sudo touch /etc/supervisor/conf.d/gubiq.conf
echo "[program:gubiq]" | sudo tee -a /etc/supervisor/conf.d/gubiq.conf
echo "command=/usr/bin/gubiq --verbosity 3 --rpc --rpcaddr "127.0.0.1" --rpcport "8588" --rpcapi "eth,net,web3" --maxpeers 100" | sudo tee -a /etc/supervisor/conf.d/gubiq.conf
echo "user=node" | sudo tee -a /etc/supervisor/conf.d/gubiq.conf
echo "autostart=true" | sudo tee -a /etc/supervisor/conf.d/gubiq.conf
echo "autorestart=true" | sudo tee -a /etc/supervisor/conf.d/gubiq.conf
echo "stderr_logfile=/var/log/gubiq.err.log" | sudo tee -a /etc/supervisor/conf.d/gubiq.conf
echo "stdout_logfile=/var/log/gubiq.out.log" | sudo tee -a /etc/supervisor/conf.d/gubiq.conf
echo
clear

#### Maybe you want to display your stats in public, or maybe not.

echo
read -p "Would you like to list your node on the Ubiq Network Stats Page? This will make your node name & stats available on 'https://ubiq.darcr.us'. (y/n)" CONT
if [ "$CONT" = "y" ]
then
	sudo sed -i -e "s/--maxpeers 100/--maxpeers 100 --ethstats "temporary:password@ubiq.darcr.us"/" /etc/supervisor/conf.d/gubiq.conf
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
echo
echo
echo
echo

#### If you are using a Raspberry Pi, SSH is not enabled by default like it is on systems running Armbian.

if [ $hardware != RaspberryPi ];
then
	echo "SSH is active by default with Armbian. This will allow you to log in and operate your node from another machine on your network."
fi
if [ $hardware = RaspberryPi ];
then
	read -p "Would you like to enable SSH on this system? This will allow you to log in and operate your node from another machine on your network. (y/n)" CONT
	if [ $CONT = y ]
	then
  		sudo raspi-config nonint do_ssh 0
		echo "SSH has been enabled"
		sleep 4
	else
  		echo "SSH is not active on this system.  To enable SSH in the future, you can do so in the raspi-config menu."
  		sleep 4
	fi
fi
echo
echo
echo
echo

#### Got lot's of space on that SSD? Sync it all!  Otherwise use Fast Mode to grab just the vital bits...

read -p "Would you like to set your node to "full" sync mode?  This will take more storage space and sync will take longer. (y/n)" CONT
if [ "$CONT" = "y" ];
then
	sudo sed -i -e "s/--maxpeers 100/--maxpeers 100 --syncmode "full" --gcmode "archive"/" /etc/supervisor/conf.d/gubiq.conf
	echo "Your node will sync in full, including all details of all blocks."
	sleep 4
else
	echo "Your node will sync in 'fast' mode"
	sleep 4
fi
echo
echo
echo
echo

#### You have the option of letting your system re-fetch gubiq binaries once a month.  If there is an update, it'll sort itself out.

read -p "Would you like to allow your node to auto-fetch the gubiq binaries once per month?  This will keep your node on the latest release without your interaction. (y/n)" CONT
if [ "$CONT" = "y" ]
then
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

if [ $hardware = RaspberryPi ] || [ $hardware = Tinkerboard ] || [ $hardware = OdroidXU4 ]
then    wget https://github.com/ubiq/go-ubiq/releases/download/v3.0.1/gubiq-linux-arm-7
elif [ $hardware = OdroidC2 ] || [ $hardware = LibreLePotato ]
then    wget https://github.com/ubiq/go-ubiq/releases/download/v3.0.1/gubiq-linux-arm64
fi

if [ $hardware = RaspberryPi ] || [ $hardware = Tinkerboard ] || [ $hardware = OdroidXU4 ]
        echo "06d105485aae819ba3f510d8d5916a63c34953770e277b80a78d71fe42848a67 gubiq-linux-arm-7" | sha256sum -c -; then
        echo "Checksum validated!" >&2
        sudo cp ./gubiq-linux-arm-7 /usr/bin/gubiq
else
        echo "Because the gubiq file could not be validated, node setup has been aborted."
        exit 1
fi

if [ $hardware = OdroidC2 ] || [ $hardware = LibreLePotato ]
        echo "cc03df2fedd4e02f4c15705deed36308e119c877b0ee158d8cf05c57b7fea5aa gubiq-linux-arm64" | sha256sum -c -; then
        echo "Checksum validated!" >&2
        sudo cp ./gubiq-linux-arm64 /usr/bin/gubiq
else
        echo "Because the gubiq file could not be validated, node setup has been aborted."
        exit 1
fi
echo

#### Lets put things where they belong and reboot the computer.

sudo chmod +x /usr/bin/gubiq
sudo mv /home/node /mnt/ssd
sudo ln -s /mnt/ssd/node /home
clear
echo
echo
echo
echo "The system will now reboot and begin sync automatically..."
echo
secs=$((1 * 8))
while [ $secs -gt 0 ]; do
   echo -ne "$secs\033[0K\r"
   sleep 1
   : $((secs--))
done
sudo reboot
