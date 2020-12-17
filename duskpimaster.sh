#!/bin/bash

# This "master" script encapsulates the management of running 2 seperate setup scripts.
# This is because the second half of the setup requires running commands as a different user.
# When both parts have finished, this "master" script will handle setup for the external drive.
# It will then reboot the system.

clear
yes '' | sed 4q
cat << "EOF"

DDDDDDDDDDDDD       UUUUUUUU     UUUUUUUU   SSSSSSSSSSSSSSS KKKKKKKKK    KKKKKKK
D::::::::::::DDD    U::::::U     U::::::U SS:::::::::::::::SK:::::::K    K:::::K
D:::::::::::::::DD  U::::::U     U::::::US:::::SSSSSS::::::SK:::::::K    K:::::K
DDD:::::DDDDD:::::D UU:::::U     U:::::UUS:::::S     SSSSSSSK:::::::K   K::::::K
  D:::::D    D:::::D U:::::U     U:::::U S:::::S            KK::::::K  K:::::KKK
  D:::::D     D:::::DU:::::D     D:::::U S:::::S              K:::::K K:::::K
  D:::::D     D:::::DU:::::D     D:::::U  S::::SSSS           K::::::K:::::K
  D:::::D     D:::::DU:::::D     D:::::U   SS::::::SSSSS      K:::::::::::K
  D:::::D     D:::::DU:::::D     D:::::U     SSS::::::::SS    K:::::::::::K
  D:::::D     D:::::DU:::::D     D:::::U        SSSSSS::::S   K::::::K:::::K
  D:::::D     D:::::DU:::::D     D:::::U             S:::::S  K:::::K K:::::K
  D:::::D    D:::::D U::::::U   U::::::U             S:::::SKK::::::K  K:::::KKK
DDD:::::DDDDD:::::D  U:::::::UUU:::::::U SSSSSSS     S:::::SK:::::::K   K::::::K
D:::::::::::::::DD    UU:::::::::::::UU  S::::::SSSSSS:::::SK:::::::K    K:::::K
D::::::::::::DDD        UU:::::::::UU    S:::::::::::::::SS K:::::::K    K:::::K
DDDDDDDDDDDDD             UUUUUUUUU       SSSSSSSSSSSSSSS   KKKKKKKKK    KKKKKKK




Thank you for using Dusk to set up a node for Ubiq, Ethereum, or Ethereum Classic!
This script will handle setup on the following systems;
- Raspberry Pi 3B+, or 4B running Raspberry Pi OS or Raspberry Pi OS Lite
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

#### Raspberry Pi's will create a new user called "dusk" and assign permissions.  Armbian systems will remind about certain settings.

if [ $hardware = RaspberryPi ]; then
cat << "EOF"
Your new user will be called 'dusk'.
You will now be prompted to set a password for your new user...
When prompted to fill in personal details, you may leave it blank.
EOF
	echo
  	read -p "Press ENTER to continue..."
	  clear
	  sudo adduser dusk
  	sudo usermod -G sudo dusk
  	sudo sed -i -e "s/CONF_SWAPSIZE=100/CONF_SWAPSIZE=2048/" /etc/dphys-swapfile
  	sudo /etc/init.d/dphys-swapfile restart

elif [ $hardware != RaspberryPi ]; then
cat << "EOF"
If you are running Armbian, you created the user called 'dusk' and set it's password on first boot.
You should have also set up the network connection & adjusted the timezone settings.
When the setup process is complete, your system will restart.
Welcome to Dusk!
EOF
echo
	read -p "Press ENTER to continue..."
fi

# Download Part 1 and Part 2 of the Dusk setup.
# Part 1 script is run as "root" and Part 2 script is run as "dusk".
wget https://raw.githubusercontent.com/maaatttt/ubiq/master/duskpi1.sh
wget https://raw.githubusercontent.com/maaatttt/ubiq/master/duskpi2.sh

# Make Part 1 executable.
chmod +x /root/duskpi1.sh

# Copy Part 2 to home dir of user "dusk".
cp /root/duskpi2.sh /home/dusk

# Make Part 2 executable ( command is run as user "dusk" ).
runuser -l dusk -c 'sudo -S chmod +x /home/dusk/duskpi2.sh'

# Run Part 1 script.
./duskpi1.sh

# Run Part 2 script ( command is run as user "dusk" ) once Part 1 script completes.
runuser -l dusk -c ./duskpi2.sh

# Once Part 2 script completes, restart Supervisor processes to activate changes.
supervisorctl reread
supervisorctl update

# Format drive, create dir & mount, edit fstab, mv "dusk" home to external drive, symlink to home.
mkfs.ext4 /dev/sda -L UBIQ
mkdir /mnt/ssd
mount /dev/sda /mnt/ssd
echo "/dev/sda /mnt/ssd ext4 defaults 0 0" | sudo tee -a /etc/fstab
sudo mv /home/dusk /mnt/ssd
ln -s /mnt/ssd/dusk /home

# Restart the system.
reboot
