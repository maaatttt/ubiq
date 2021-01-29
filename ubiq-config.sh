#!/bin/bash
node_ip=$(hostname -I|cut -d" " -f 1)

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

if [ $hardware = RaspberryPi ]; then
        rootuser=pi
elif [ $hardware != RaspberryPi ]; then
        rootuser=root
fi

whiptail \
    --title "Welcome to Ubiq-Config" \
    --msgbox "This utility provides options for creating and managing a node for the Ubiq network, as well as helpful tools such as system updates and installing the Shinobi interface." --ok-button Continue 10 49
function advancedMenu() {
    while :; do
    ADVSEL=$(whiptail --title "ubiq-config" --fb --menu --nocancel "   Choose an option from the menu" 19 40 10 \
        "1" "Create a new Ubiq node" \
        "2" "Show current block information" \
        "3" "Update gubiq to latest version" \
        "4" "Delete chaindata & re-sync gubiq" \
        "5" "Install Shinobi Interface" \
        "6" "Install updates to the OS" \
        "7" "System information" \
        "8" "Reboot the system" \
        "9" "Shutdown the system" \
        "10" "Exit to Terminal" 3>&1 1>&2 2>&3)
    case $ADVSEL in
        1)
            if [ -f "/usr/bin/gubiq" ]; then
            whiptail --title "Ubiq Node Install" --fb --msgbox "gubiq is already installed on your system" 10 45
            elif [ "$(whoami)" != $rootuser ]; then
            whiptail --title "Block Info" --fb --msgbox "Please log in as "$rootuser" and run 'ubiq-config' again in order to perform this action." 10 47
          elif (whiptail --title "Ubiq Node Install" --fb --yesno "Would you like to begin installation of your Ubiq node now?" 10 64); then
                        if( whiptail --title "Timezone" --fb --msgbox "Please set the correct timezone for your location." 10 54); then
                        sudo dpkg-reconfigure tzdata
                        whiptail --title "Timezone" --fb --msgbox "Timezone has been set" 10 25
                        fi
            wget https://raw.githubusercontent.com/maaatttt/ubiq/master/node.sh
            sudo chmod +x node.sh
            ./node.sh
            whiptail --title "Ubiq Node Install" --fb --msgbox " You have created a Ubiq node." 10 35
          else whiptail --title "Ubiq Node Install" --fb --msgbox "Installation has been canceled." 10 35
            fi
        ;;
        2)
            if [ -f "/usr/bin/gubiq" ]; then
                if [ "$(whoami)" = $rootuser ]; then
                whiptail --title "Block Info" --fb --msgbox "Please log in as 'node' and run 'ubiq-config' again in order to perform this action." 10 49
              elif ( whiptail --title "Block Info" --fb --yesno "Would you like to display a live view of block information?" 10 64); then
                whiptail --title "Block Info" --fb --msgbox "When you are finished, pressing 'Ctrl C' then 'q' will escape back to 'ubiq-config'" 10 46
                less +F /var/log/gubiq.err.log
                fi
            else
            whiptail --title "Block Info" --fb --msgbox "There is no Ubiq node configured on this system." 10 26
            fi
        ;;
        3)
            if [ -f "/home/pi/auto.sh" ]; then
                if [ "$(whoami)" != $rootuser ] ; then
                whiptail --title "gubiq Update" --fb --msgbox "Please log in as "$rootuser" and run 'ubiq-config' again in order to perform this action." 10 47
              elif ( whiptail --title "gubiq Update" --fb --yesno "Your system is already configured for monthly automatic updates.  Would you like to update now anyway?" 10 60); then
                wget https://raw.githubusercontent.com/maaatttt/ubiq/master/gu.sh
                #chmod +x gu.sh
                #./gu.sh
              else whiptail --title "gubiq Update" --fb --msgbox "Update has been canceled." 10 29
                fi
            elif [ -f "/usr/bin/gubiq" ]; then
                if ( whiptail --title "gubiq Update" --fb --yesno "Would you like to update gubiq now?" 10 39); then
                wget https://raw.githubusercontent.com/maaatttt/ubiq/master/gu.sh
                chmod +x gu.sh
                ./gu.sh
                whiptail --title "gubiq Update" --fb --msgbox "Please reboot your system from the main menu" 10 48
              else whiptail --title "gubiq Update" --fb --msgbox "Update has been canceled." 10 29
                fi
            else whiptail --title "gubiq Update" --fb --msgbox "There is no Ubiq node configured on this system." 10 52
            fi
        ;;
        4)
            if [ -f "/usr/bin/gubiq" ]; then
                if [ "$(whoami)" = $rootuser ] ; then
                whiptail --title "Resync" --fb --msgbox "Please log in as 'node' and run 'ubiq-config' again in order to perform this action." 10 49
              elif ( whiptail --title "Resync" --fb --yesno "Would you like to delete all gubiq data and sync the blockchain from scratch?" 10 43); then
                sudo apt update
                sudo supervisorctl stop gubiq
                gubiq removedb
                whiptail --title "Resync" --fb --msgbox "Your chain data has been deleted.  Please reboot the system from the main menu." 10 45
                else
                whiptail --title "Resync" --fb --msgbox "Your chain data has not been deleted."  10 41
                fi
            else
                whiptail --title "gubiq Update" --fb --msgbox "There is no Ubiq node configured on this system." 10 52
            fi
        ;;
        5)
            if [ "$(whoami)" != $rootuser ]; then
            whiptail --title "Shinobi Interface Installation" --fb --msgbox "Please log in as "$rootuser" and run 'ubiq-config' again to perform this action." 10 47
            elif [ "$(whoami)" = $rootuser ]; then
                if [ $hardware = "RaspberryPi" ] && [ -d "/home/pi/shinobi-interface" ]; then
                whiptail --title "Shinobi Interface Installation" --fb --msgbox "Shinobi Interface is already installed on your system.  Use Shinobi by visiting "$node_ip":8888 in a browser" 11 58
                elif [ $hardware != "RaspberryPi" ] && [ -d "/root/shinobi-interface" ]; then
                whiptail --title "Shinobi Interface Installation" --fb --msgbox "Shinobi Interface is already installed on your system.  Use Shinobi by visiting "$node_ip":8888 in a browser" 11 58
              elif (whiptail --title "Shinobi Interface Installation" --fb --yesno "Would you like to install Shinobi Interface now?" 10 52); then
                clear
                wget https://raw.githubusercontent.com/maaatttt/ubiq/master/shinobi.sh
                sudo chmod +x shinobi.sh
                ./shinobi.sh
                else
                whiptail --title "Shinobi Interface Installation" --fb --msgbox "Shinobi Interface installation canceled" 10 44
                fi
            fi
        ;;
        6)
            if (whiptail --title "System Update" --fb --yesno "Would you like to update your system now?" 10 45); then
            clear
            sudo apt update
            sudo apt upgrade -y
            sudo apt full-upgrade
            whiptail --title "System Update" --fb --msgbox "Any available updates have been installed.  Please reboot the system from the main menu for any changes to take effect." 11 48
            else
            whiptail --title "System Update" --fb --msgbox "Updates have not been installed" 10 35
            fi
        ;;
        7)
            if [ -f "/usr/bin/gubiq" ]; then
              touch info.txt
              echo "Your IP Address is -" | tee -a info.txt 1>/dev/null
              echo $node_ip | tee -a info.txt 1>/dev/null
              echo "       "| tee -a info.txt 1>/dev/null
              echo "       "| tee -a info.txt 1>/dev/null
              echo "Your gubiq version information is -" | tee -a info.txt 1>/dev/null
              gubiq version | tee -a info.txt 1>/dev/null
              echo "       "| tee -a info.txt 1>/dev/null
              echo "       "| tee -a info.txt 1>/dev/null
              echo "Your SSD storage is -"| tee -a info.txt 1>/dev/null
              df /dev/sda -h | tee -a info.txt 1>/dev/null
              echo "       "| tee -a info.txt 1>/dev/null
              echo "       "| tee -a info.txt 1>/dev/null
              whiptail --textbox --fb info.txt 30 60
              sudo rm info.txt
              clear
              else whiptail --title "Block Info" --fb --msgbox "There is no Ubiq node configured on this system." 10 52
            fi
        ;;
        8)
            if (whiptail --title "System Reboot" --fb --yesno "Would you like to reboot immediately?" 10 41); then
            sudo reboot
            else
            whiptail --title "System Reboot" --fb --msgbox "Reboot Canceled" 10 19
            fi
        ;;
        9)
            if (whiptail --title "System Shutdown" --fb --yesno "Would you like to shut down immediately?" 10 44); then
            sudo shutdown -h now
            else
            whiptail --title "System Shutdown" --fb --msgbox "Shutdown Canceled" 10 21
            fi
        ;;
        10)
            break
        ;;
    esac
done
}
advancedMenu
