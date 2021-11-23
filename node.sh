#!/bin/bash

clear
echo "      	█████  █████   ███████████    █████      ██████"
sleep .75
echo "      	░███  ░░███   ░░███░░░░░███  ░░███     ███░░░░███"
sleep .75
echo "      	░███   ░███    ░███    ░███   ░███    ███    ░░███"
sleep .75
echo "      	░███   ░███    ░██████████    ░███   ░███     ░███"
sleep .75
echo "      	░███   ░███    ░███░░░░░███   ░███   ░███   ██░███"
sleep .75
echo "      	░███   ░███    ░███    ░███   ░███   ░░███ ░░████"
sleep .75
echo "      	░░████████     ███████████    █████   ░░░██████░██"
sleep .75
echo "      	░░░░░░░░     ░░░░░░░░░░░    ░░░░░      ░░░░░░ ░░"
sleep 3
clear

whiptail --title "Welcome!" --fb --msgbox "Thanks for supporting the Ubiq network with a node.\n\nThis setup will work with the following hardware;\n\n- Raspberry Pi 3B\n- Raspberry Pi 3B+\n- Raspberry Pi 4B\n- Asus Tinkerboard\n- Odroid XU4\n- Odroid C2\n- Libre LePotato\n\nPress "OK" to continue to setup." 20 55

#### Setting some variables naming the hardware being used, and its architecture.
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
elif grep -q 'RockPro64' /proc/device-tree/model; then
	hardware=RockPro64
	arch=64bit
fi
clear

#### Raspberry Pi's will create a new user called "node" and assign permissions.  Armbian systems will remind about certain settings.

if [ $hardware = RaspberryPi ]; then
  whiptail --title "New User" --fb --msgbox "A new user will be created for you called 'node'.\n\nYou will be prompted to set a password for the new user.\n\nThere is NO requirment to fill in the personal details.\n\nYou will now continue to the setup.\n\nWelcome to Ubiq!" 16 60
	sudo adduser node
  sudo usermod -G sudo node
  sudo sed -i -e "s/CONF_SWAPSIZE=100/CONF_SWAPSIZE=2048/" /etc/dphys-swapfile
  sudo /etc/init.d/dphys-swapfile restart
elif [ $hardware != RaspberryPi ]; then
  whiptail --title "New User" --fb --msgbox "When running Armbian OS, you will have created a user called 'node' and set it's password on first boot.\n\nYou will now continue to the setup.\n\nWelcome to Ubiq!" 14 50
fi
clear

#### User will select the applicable boot method, which will determine location of node user home dir

if (whiptail --title "Boot Method" --fb --yesno "Which drive are you using to boot the operating system?" 10 32 --yes-button "microSD" --no-button "SSD"); then
	bootmethod=microSD
else
	bootmethod=SSD
fi
whiptail --fb --title "Boot Method" --msgbox "You have indicated that you are booting the operating system from the "$bootmethod"" 10 43

#### Update, Upgrade, Optimize & install NTP, HTOP, Supervisor and git

sudo apt update -q
sudo apt upgrade -y -q
sudo apt dist-upgrade -q
sudo apt autoremove -y -q
sudo apt install ntp -y -q
sudo apt install htop -q
sudo apt install supervisor -y -q
sudo apt install git -y -q

if [ $bootmethod = microSD ]; then
sudo mkfs.ext4 /dev/sda -L UBIQ -y
sudo mkdir /mnt/ssd
sudo mount /dev/sda /mnt/ssd
echo "/dev/sda /mnt/ssd ext4 defaults 0 0" | sudo tee -a /etc/fstab
fi

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

#### Giving the user the option to list their node on the Ubiq Network stats page, found at 'https://stats.ubiqscan.io'.

if ( whiptail --title "Ubiq Netstats" --fb --yesno "Do you want to be listed on the Ubiq Network Stats Page?\n\nNode name, peer count, and general region would be public on 'https://stats.ubiqscan.io'." 12 60 ); then
		sudo sed -i -e "s/--maxpeers 100/--maxpeers 100 --ethstats "temporary:password@stats.ubiqscan.io"/" /etc/supervisor/conf.d/gubiq.conf
		varname=$(whiptail --fb --inputbox "Input a name for your node as you would like it to be displayed on the stats site, https://stats.ubiqscan.io" --nocancel 11 60 3>&1 1>&2 2>&3)
		sudo sed -i -e "s/temporary/$varname/" /etc/supervisor/conf.d/gubiq.conf
  	whiptail --title "Ubiq Netstats" --msgbox "Your node will be named $varname." 8 40
		varpass=$(whiptail --fb --passwordbox "Enter the password to list your node on the Ubiq Stats Page" --nocancel 10 64 3>&1 1>&2 2>&3)
		sudo sed -i -e "s/password/$varpass/" /etc/supervisor/conf.d/gubiq.conf
  	whiptail --fb --title "Ubiq Netstats" --msgbox "Your node will be listed on the public site." 9 48
else
		whiptail --fb --title "Ubiq Netstats" --msgbox "Your node will not be listed on the stats site." 9 51
fi

#### If you are using Raspberry Pi OS, SSH is not enabled by default like it is on systems running Armbian.

if [ $hardware != RaspberryPi ]; then
	whiptail --title "SSH Configuration" --fb --msgbox "SSH is active by default with Armbian.\n\nThis will allow you to operate your node by logging in from another machine on your network." 12 52
elif [ $hardware = RaspberryPi ]; then
	if (whiptail --title "SSH Configuration" --fb --yesno "Would you like to enable SSH on this system?\n\nThis will allow you to operate your node by logging in from another machine on your network." 12 52 ); then
  		sudo raspi-config nonint do_ssh 0
			whiptail --title "SSH Configuration" --fb --msgbox "SSH has been enabled" 9 24
  else
  		whiptail --title "SSH Configuration" --fb --msgbox "SSH has not been activated on this system.\n\nTo enable SSH in the future, you can do so by using the 'raspi-config' menu." 12 46
	fi
fi

#### Giving the user the option to sync all blocks in full, or sync in "fast" mode which saves space...

if ( whiptail --title "Sync Method" --fb --yesno "Would like to sync in 'full archive' mode or 'fast mode'?\n\nFull archive mode will use more drive space and time to complete sync is longer." --yes-button "Full" --no-button "Fast" 12 61 ); then
	sudo sed -i -e "s/--maxpeers 100/--maxpeers 100 --syncmode "full" --gcmode "archive"/" /etc/supervisor/conf.d/gubiq.conf
  whiptail --title "Sync Method" --fb --msgbox "Your node will sync in 'full archive' mode." 9 48
else
	whiptail --title "Sync Method" --fb --msgbox "Your node will sync in 'fast' mode." 9 39
fi

#### Giving the user an option to let the system automatically update gubiq using a cron job.

if ( whiptail --title "Automatic Updates" --fb --yesno "Do you want to download the gubiq binary monthly?\n\nThis will update your node if there has been a new version released in the previous month." 12 53); then
		touch auto.sh
		chmod +x auto.sh
		tee auto.sh &>/dev/null << "EOF"
#!/bin/bash

wget https://raw.githubusercontent.com/maaatttt/ubiq/master/gu.sh
sudo chmod +x gu.sh
./gu.sh

EOF
    echo "@monthly ./auto.sh" | crontab -
  	whiptail --title "Automatic Updates" --fb --msgbox "Your node will automatically handle updates.\n\nGubiq binaries will be redownloaded on the first of each month & the node will reboot."  12 48
else
   	whiptail --title "Automatic Updates" --fb --msgbox "Your node will not automatically update gubiq.\n\nUpdates must be handled manually by using the 'ubiq-config' utility in your terminal." 12 50
fi


#### System will determine the correct binary file to download based on how it was defined at the beginning of this script.
#### The binary file's checksum will be validated.  If it is valid, the script will complete the setup. If it is invalid, it will exit setup.

if [ $arch = 32bit ]; then
        wget https://github.com/ubiq/go-ubiq/releases/download/v5.3.0/gubiq-linux-arm7
        echo "4373f9ace456325290887af581b3db53211797123758b84240fa629358395022 gubiq-linux-arm7" | sha256sum -c - || exit 1
        sudo cp ./gubiq-linux-arm7 /usr/bin/gubiq
        sudo chmod +x /usr/bin/gubiq
elif [ $arch = 64bit ]; then
        wget https://github.com/ubiq/go-ubiq/releases/download/v5.3.0/gubiq-linux-arm64
        echo "a7b54a1bf451b9e66cc4676bcf574b1c35841d8689e70bb789e33917ddc3d1b6 gubiq-linux-arm64" | sha256sum -c - || exit 1
        sudo cp ./gubiq-linux-arm64 /usr/bin/gubiq
        sudo chmod +x /usr/bin/gubiq
fi

#### Changing permissions, moving and linking the user's home folder, and rebooting the system to begin blockchain sync.

if [ $bootmethod = microSD ]; then
sudo mv /home/node /mnt/ssd
sudo ln -s /mnt/ssd/node /home
fi
clear

whiptail --title "Setup" --fb --msgbox "The initial setup is complete! \n\nSync will begins automatically after a system restart.\n\nPress "Ok" to reboot now." 14 35
sudo reboot
