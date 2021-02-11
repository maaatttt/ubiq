# **_Ubiq_**
## ARM-based single-board computers as nodes for the Ubiq blockchain.
------------------------------------------------------------------------------------------------------------------------------

This README provides some general instructions for the initial setup of the system, and some detail about the various bash scripts used in [guides](https://blog.ubiqsmart.com/tagged/tutorial) produced for the Ubiq community to encourage anyone who is interested to set up their own node. 

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## These steps assume an ethernet connection / headless setup / accessed via SSH / an SSD drive for storage.

- [ ] Download the OS for your hardware - 

- Raspberry Pi uses [Raspberry Pi OS](https://www.raspberrypi.org/downloads/raspberry-pi-os/), the other boards use [Armbian](
https://www.armbian.com/).
  - [Raspberry Pi - 3B / 3B+ / 4B ](https://downloads.raspberrypi.org/raspios_lite_armhf_latest)
  - [Asus - Tinkerboard ](https://redirect.armbian.com/tinkerboard/Focal_current)
  - [Hardkernel - Odroid XU4](https://redirect.armbian.com/odroidxu4/Buster_legacy)
  - [Hardkernel - Odroid C2](https://redirect.armbian.com/odroidc2/Buster_current)
  - [Libre Computers - Le Potato](https://redirect.armbian.com/lepotato/Buster_current_minimal)
  - [Pine64 - RockPro64](https://redirect.armbian.com/rockpro64/Focal_current)
  
- [ ]  Flash OS to microSD card (or SSD*).
  - NOTE! * You can only boot from an SSD if you are using a Pi 3B+ or 4B. When using a Pi 4B you must be sure the [EEPROM settings](https://www.raspberrypi.org/documentation/hardware/raspberrypi/booteeprom.md) are up to date, and the primary boot media in `raspi-config` Advanced Settings is set to USB Boot.
  
  - Use [Etcher](https://www.balena.io/etcher/) to flash the OS to your microSD card (or SSD, depending).
  - For Raspberry Pi, SSH is _disabled_ by default.  [Enable by placing an empty file named **`ssh`** in boot partition of the boot media. ](https://www.raspberrypi.org/documentation/remote-access/ssh/)
  - For Armbian boards, SSH is enabled by default.

- [ ] If you _must_ use WiFi instead of a wired ethernet connection you can set up the connection inside your OS config utility.
  - Raspberry Pi - `sudo raspi-config`
  - Armbian - `armbian-config`
- [ ] First boot / Log In
  - micro SD boot : Connect the SSD drive being used for storage to the system before starting up. 
  - SSD boot : Be sure there is no microSD card installed before starting up.
  
  - Logging in via SSH -
    - **Raspberry Pi** -  log in with **`ssh user@youripaddress`**  ( Defaults - `user` : **`pi`** / `passwd` : **`raspberry`** )
    
    - **Armbian** -     log in with **`ssh user@youripaddress`**  ( Defaults - `user` : **`root`** / `passwd` : **`1234`**
  
    - Note! Raspberry Pi users should use their OS config utility ( `raspi-config` ) to change the `pi` user default password 
    - Note! Armbian users will be prompted to create a non-root user when booting a new system.  Name that new user **`node`**.
    - Note! The `ubiq-config` tool will prompt you to set your timezone when you attempt to spin up a node, you do not need to do it beforehand.
    
- [ ] Download and install the **`ubiq-config.sh`** utility.
    - `wget https://raw.githubusercontent.com/maaatttt/ubiq/master/ubiq-config.sh`
    - `sudo chmod 755 ubiq-config.sh`
    - `sudo mv ubiq-config.sh /usr/bin/ubiq-config`

- [ ] Use **ubiq-config** by inputting `ubiq-config` into the terminal at any time.

-------------------------------------------------------------------------------------------------------------------------------

## Scripts enabling the functionality for `ubiq-config` listed below.  
## Any older unused scripts are labeled as **_DEPRICATED_**.

## **[ubiq-config.sh](https://raw.githubusercontent.com/maaatttt/ubiq/master/ubiq-config.sh)** 

This is the bash script that comprises the `ubiq-config` utility.  A text-based user interface that allows users to manage the functionality of their Ubiq node through an easy-to-use graphical implementation for the command-line.  It makes possible the installation of the **[node.sh](https://raw.githubusercontent.com/maaatttt/ubiq/master/node.sh)** script.  , [gu.sh](https://raw.githubusercontent.com/maaatttt/ubiq/master/gu.sh) script, and the **[auto.sh](https://raw.githubusercontent.com/maaatttt/ubiq/master/auto.sh)** script, as well as various update commands and shutdown procedures.

------------------------------------------------------------------------------------------------------------------------------

## **[node.sh](https://raw.githubusercontent.com/maaatttt/ubiq/master/node.sh)** 

This script handles all the commands for the primary Ubiq node setup procedure.  It will configure directories, download requisite software, and prompt the user for inputs such as node name, passwords, and desired sync method. 

It is currently intended for the following hardware:
- Raspberry Pi 3B / 3B+ / 4B (Raspberry Pi OS - 32bit)
- Asus Tinkerboard / Tinkerboard S (Armbian - 32bit)
- Odroid XU4 (Armbian - 32bit)
- Odroid C2 (Armbian - 64bit)
- Libre LePotato (Armbian - 64bit)

Software downloads; apt-related system software, [supervisor](http://supervisord.org/), [htop](https://hisham.hm/htop/), [git](https://git-scm.com/), [ntp](http://www.ntp.org/), [gubiq](https://github.com/ubiq/go-ubiq/releases)

------------------------------------------------------------------------------------------------------------------------------

## **[gu.sh](https://raw.githubusercontent.com/maaatttt/ubiq/master/gu.sh)**

This script handles all the commands to update the running instance of gubiq on any node that was configured using the **[node.sh](https://raw.githubusercontent.com/maaatttt/ubiq/master/node.sh)** script.  

To simplify the procedure for updates, the gu.sh script is offered as an option during the initial node setup.  The file will delete itself upon completion of the it's task to avoid conflicts as version numbers change.

Software downloads; apt-related system software, [gubiq](https://github.com/ubiq/go-ubiq/releases/)

------------------------------------------------------------------------------------------------------------------------------

## **[auto.sh](https://raw.githubusercontent.com/maaatttt/ubiq/master/auto.sh)**

This script is run as part of an optional cron job that re-fetches an update script monthly. It is downloaded as part of the initial node setup script.  The updater downloads the [gu.sh](https://raw.githubusercontent.com/maaatttt/ubiq/master/gu.sh) script, which runs the update commands, then deletes itself to prevent file name conflict when the cron job runs again the following month.  

**Automatic updates to gubiq resulting from the [gu.sh](https://raw.githubusercontent.com/maaatttt/ubiq/master/gu.sh) script will _only_ be release versions, and _never_ pre-release beta versions.**

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
## **_The scripts below are no longer used in these processes_** 
**_DEPRICATED_**
## **[old-node.sh](https://raw.githubusercontent.com/maaatttt/ubiq/master/old-node.sh)** 

**_DEPRICATED_**

This script handles all the commands for the primary Ubiq node setup procedure.  It will configure directories, download requisite software, and prompt the user for inputs such as node name, passwords, and desired sync method. 

It is intended to run on a **(32bit)** Raspberry Pi 3B or 3B+ running Raspbian Lite, **_where the OS boots from a microSD card_**, and the system has an attached USB mass storage device for chaindata.

Software downloads; apt-related system software, [supervisor](http://supervisord.org/), [htop](https://hisham.hm/htop/), [git](https://git-scm.com/), [ntp](http://www.ntp.org/), [gubiq](https://github.com/ubiq/go-ubiq/releases)

------------------------------------------------------------------------------------------------------------------------------

## **[old-node2.sh](https://raw.githubusercontent.com/maaatttt/ubiq/master/old-node2.sh)**

**_DEPRICATED_**

This script handles all the commands for the primary Ubiq node setup procedure.  It will configure directories, download requisite software, and prompt the user for inputs such as node name, passwords, and desired sync method.

It is intended to run on a **(32bit)** Raspberry Pi 3B or 3B+ running Raspbian Lite, **_where the OS boots directly from the external media_**, and the system does **NOT** use a microSD card.

Software downloads; apt-related system software, [supervisor](http://supervisord.org/), [htop](https://hisham.hm/htop/), [git](https://git-scm.com/), [ntp](http://www.ntp.org/), [gubiq](https://github.com/ubiq/go-ubiq/releases/)

------------------------------------------------------------------------------------------------------------------------------

## **[old-node3.sh](https://raw.githubusercontent.com/maaatttt/ubiq/master/old-node3.sh)** 

**_DEPRICATED_**

This script handles all the commands for the primary Ubiq node setup procedure.  It will configure directories, download requisite software, and prompt the user for inputs such as node name, passwords, and desired sync method.

It is intended to run on a **(32bit)** system such as the Asus Tinkerboard running Armbian, **_where the OS boots from a microSD card_**, and the system has an attached USB mass storage device for chaindata.

Software downloads; apt-related system software, [supervisor](http://supervisord.org/), [htop](https://hisham.hm/htop/), [git](https://git-scm.com/), [ntp](http://www.ntp.org/), [gubiq](https://github.com/ubiq/go-ubiq/releases/)

------------------------------------------------------------------------------------------------------------------------------

## **[old-node4.sh](https://raw.githubusercontent.com/maaatttt/ubiq/master/old-node4.sh)** 

**_DEPRICATED_**

This script handles all the commands for the primary Ubiq node setup procedure.  It will configure directories, download requisite software, and prompt the user for inputs such as node name, passwords, and desired sync method.

It is intended to run on a **(64bit)** system such as the Ordoid C2 running Armbian or the Libre LePotato running Armbian, **_where the OS boots from a microSD card_**, and the system has an attached USB mass storage device for chaindata.

Software downloads; apt-related system software, [supervisor](http://supervisord.org/), [htop](https://hisham.hm/htop/), [git](https://git-scm.com/), [ntp](http://www.ntp.org/), [gubiq](https://github.com/ubiq/go-ubiq/releases/)

------------------------------------------------------------------------------------------------------------------------------

## **[old-gu2.sh](https://raw.githubusercontent.com/maaatttt/ubiq/master/old-gu2.sh)**

**_DEPRICATED_**

This script handles all the commands to update the running instance of gubiq on a system configured using **node3.sh**.  To simplify the procedure for future updates, the gu.sh script will delete itself upon completion of the it's task.

It is intended to run on a **(64bit)** system such as the Ordoid C2 running Armbian or the Libre LePotato running Armbian.

Software downloads; apt-related system software, [gubiq](https://github.com/ubiq/go-ubiq/releases/)


------------------------------------------------------------------------------------------------------------------------------

## **[nu.sh](https://raw.githubusercontent.com/maaatttt/ubiq/master/nu.sh)** 

This script handles reconfiguing aspects of older, pre-"node.sh" systems to remove depricated applications and add the neccessary inputs to allow the node to continue to appear on the [Ubiq Network Stats Page](https://ubiq.darcr.us). The script will prompt the user for inputs such as node name & passwords.  

Applicable nodes must be synced and using [Supervisor](http://supervisord.org/) to make use of this script. 

This script is intended to run on a **(32bit)** Raspberry Pi 3B or 3B+ running Raspbian Lite, or a (32bit) Asus Tinkerboard running Armbian.

Software downloads; apt-related system software,  [gubiq](https://github.com/ubiq/go-ubiq/releases/)

------------------------------------------------------------------------------------------------------------------------------

## **[old-auto2.sh](https://raw.githubusercontent.com/maaatttt/ubiq/master/old-auto2.sh)**

**_DEPRICATED_**

This script is run as part of an optional cron job that re-fetches an update script monthly. It is downloaded as part of the initial node setup script.  The updater downloads the [gu2.sh](https://raw.githubusercontent.com/maaatttt/ubiq/master/gu2.sh) script, which runs the update commands, then deletes itself to prevent file name conflict when the cron job runs again the following month.  

It is intended to run on a **(64bit)** system such as the Ordoid C2 running Armbian or the Libre LePotato running Armbian.

**Automatic updates to gubiq resulting from the [gu2.sh](https://raw.githubusercontent.com/maaatttt/ubiq/master/gu2.sh) script will _only_ be release versions, and _never_ pre-release beta versions.**

------------------------------------------------------------------------------------------------------------------------------

## Acknowledgments

Special thanks to the Ubiq developers, the Ubiq Community, and the authors of open software used in these processes.

