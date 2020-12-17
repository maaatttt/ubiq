#!/bin/bash

# This "master" script encapsulates the management of running 2 seperate setup scripts.
# This is because the second half of the setup requires running commands as a different user.
# When both parts have finished, this "master" script will handle setup for the external drive.
# It will then reboot the system.

# Update the system, add "dusk" user, give "dusk" user sudo permissions.
sudo -i
apt get update
apt get full-upgrade
adduser dusk
usermod -G sudo dusk

# Download Part 1 and Part 2 of the Dusk setup.
# Part 1 script is run as "root" and Part 2 script is run as "dusk".
wget https://raw.githubusercontent.com/maaatttt/ubiq/master/duskpi1.sh
wget https://raw.githubusercontent.com/maaatttt/ubiq/master/duskpi2.sh

# Make Part 1 executable.
chmod +x /root/duskpi1.sh

# Copy Part 2 to home dir of user "dusk".
cp /root/duskpi2.sh /home/dusk

# Make Part 2 executable ( command is run as user "dusk" ).
runuser -l dusk -c 'sudo -S chmod +x /root/duskpi2.sh'

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
