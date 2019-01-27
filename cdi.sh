#!/bin/bash

sudo supervisorctl stop gubiq
wget http://headru.sh/ubiq/ubiq_block_706337.gz
echo
echo "Compare the following two SHA Hash results.."
echo
sudo shasum ubiq_block_706337.gz
echo
echo "6dd746478016bc8d19e7f89e5b51158947c27e6ddca5756fcfa21353752a8f89"
echo
echo "If the two SHA Hash results match, you may continue. If not, do not proceed!"
echo
read -p "Would you like to continue? (y/n)" CONT
if [ "$CONT" = "y" ]; then
  sudo rm -rf /mnt/ssd/node/.ubiq/chaindata
else
  exit
fi
zcat ubiq_block_706337.gz > /mnt/ssd/node/.ubiq/chaindata
sudo reboot