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
	wget https://github.com/ubiq/go-ubiq/releases/download/v5.2.1/gubiq-linux-arm7
  echo "cf1588a0d30eeb2a8a5339ab48248b04aef5dc148b6513aac26dd4da9fe29614 gubiq-linux-arm7" | sha256sum -c - || exit 1

elif [ $hardware = OdroidC2 ] || [ $hardware = LibreLePotato ]; then
	sudo rm gubiq-linux-arm64
	sudo rm /usr/bin/gubiq
	wget https://github.com/ubiq/go-ubiq/releases/download/v5.2.1/gubiq-linux-arm64
  echo "cef43a8d126d78b80151262b16b10e55b5d028f3d2cae31ba6e983188c0297cf gubiq-linux-arm64" | sha256sum -c - || exit 1
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
