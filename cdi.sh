#!/bin/bash

sudo supervisorctl stop gubiq
sudo wget http://headru.sh/ubiq/ubiq_block_737000.gz -O /mnt/ssd/ubiq_block_737000.gz
echo
echo "Compare the following two SHA256 Hash results.."
echo
cd /mnt/ssd
sudo sha256sum ubiq_block_737000.gz
echo
echo "ATTENTION!"
echo
echo "4a963b6835c1c695858524c67e8ea33c7944bc802ba07dcf1352a6814d131b9f"
echo
echo "If the two hash results match, continue. If not, do not proceed!"
echo
read -p "Would you like to continue? (y/n)" CONT
if [ "$CONT" = "y" ]; then
  sudo gunzip -k ubiq_block_737000.gz  | sudo tee /mnt/ssd/ubiq_block_737000
else
  exit
fi
/usr/bin/gubiq --cache 1024 import /mnt/ssd/ubiq_block_737000
sudo supervisorctl start gubiq
