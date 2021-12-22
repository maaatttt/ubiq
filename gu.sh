#!/bin/bash

sudo apt update -q
sudo apt upgrade -y -q

if grep -q 'Raspberry' /proc/device-tree/model; then
	hardware=RaspberryPi
elif grep -q 'Tinker' /proc/device-tree/model; then
	hardware=Tinkerboard
elif grep -q 'XU4' /proc/device-tree/model; then
	hardware=OdroidXU4
elif grep -q 'ODROID-C2' /proc/device-tree/model; then
	hardware=OdroidC2
elif grep -q 'Libre' /proc/device-tree/model; then
	hardware=LibreLePotato
fi

sudo supervisorctl stop gubiq

if [ $hardware = RaspberryPi ] || [ $hardware = Tinkerboard ] || [ $hardware = OdroidXU4 ]; then
	sudo rm gubiq-linux-arm7
	sudo rm /usr/bin/gubiq
	wget https://github.com/ubiq/go-ubiq/releases/download/v6.0.0/gubiq-linux-arm7
  echo "31a8dd7305955154a2e83b43396bfd8d92b43e0f753fb1dc4b0362930413e05c gubiq-linux-arm7" | sha256sum -c - || exit 1

elif [ $hardware = OdroidC2 ] || [ $hardware = LibreLePotato ]; then
	sudo rm gubiq-linux-arm64
	sudo rm /usr/bin/gubiq
	wget https://github.com/ubiq/go-ubiq/releases/download/v6.0.0/gubiq-linux-arm64
  echo "778c2662fbf35869e5a449b6643cf0a4247c37fe121a65befa323202e7131d5b gubiq-linux-arm64" | sha256sum -c - || exit 1
fi

if [ $hardware = RaspberryPi ] || [ $hardware = Tinkerboard ] || [ $hardware = OdroidXU4 ]; then
        sudo cp ./gubiq-linux-arm7 /usr/bin/gubiq
elif [ $hardware = OdroidC2 ] || [ $hardware = LibreLePotato ]; then
        sudo cp ./gubiq-linux-arm64 /usr/bin/gubiq
fi

sudo chmod +x /usr/bin/gubiq
sudo supervisorctl start gubiq
sudo rm $0
sudo reboot
