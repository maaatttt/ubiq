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
	wget https://github.com/ubiq/go-ubiq/releases/download/v5.0.0/gubiq-linux-arm-7
  echo "598553a57e68b8d0c298481ce1fc99d0df6df63b44c64e128ce7af38681e302e  gubiq-linux-arm-7" | sha256sum -c - || exit 1

elif [ $hardware = OdroidC2 ] || [ $hardware = LibreLePotato ]; then
	sudo rm gubiq-linux-arm64
	sudo rm /usr/bin/gubiq
	wget https://github.com/ubiq/go-ubiq/releases/download/v5.0.0/gubiq-linux-arm64
  echo "1939ef3a8776b3ff7bda368edfda53efee2815f9682922725ab4241a301d605d gubiq-linux-arm64" | sha256sum -c - || exit 1
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
