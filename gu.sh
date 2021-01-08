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
	sudo rm gubiq-linux-arm-7
	sudo rm /usr/bin/gubiq
	wget https://github.com/ubiq/go-ubiq/releases/download/v3.2.0/gubiq-linux-arm-7
  echo "832edbae741eb06ab6e6f02fe6b4e3234524d58ec11e2dcf67876667a8676c57  gubiq-linux-arm-7" | sha256sum -c - || exit 1

elif [ $hardware = OdroidC2 ] || [ $hardware = LibreLePotato ]; then
	sudo rm gubiq-linux-arm64
	sudo rm /usr/bin/gubiq
	wget https://github.com/ubiq/go-ubiq/releases/download/v3.2.0/gubiq-linux-arm64
  echo "50718368e382009dae2d0c2e1a786f56cfc2fd3b79c66502a80826ff67c63169 gubiq-linux-arm64" | sha256sum -c - || exit 1
fi

if [ $hardware = RaspberryPi ] || [ $hardware = Tinkerboard ] || [ $hardware = OdroidXU4 ]; then
        sudo cp ./gubiq-linux-arm-7 /usr/bin/gubiq
elif [ $hardware = OdroidC2 ] || [ $hardware = LibreLePotato ]; then
        sudo cp ./gubiq-linux-arm64 /usr/bin/gubiq
fi

sudo chmod +x /usr/bin/gubiq
sudo supervisorctl start gubiq
sudo rm $0
sudo reboot
