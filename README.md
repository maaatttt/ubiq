# **_Ubiq_**
## Bash scripts related to configuring and maintaining nodes for the Ubiq blockchain using ARM-based single-board computers.
------------------------------------------------------------------------------------------------------------------------------

This README provides further detail about the various bash scripts used in [guides](https://blog.ubiqsmart.com/tagged/tutorial) produced for the _[Ubiq Community](https://www.ubiqescher.com/)_ to encourage and assist network participants to operate their own independant node. 

These scripts & guides do not generate accounts or private keys, nor instruct users how to do so.  

There may be further instructionals in the future related to operators broadcasting their own transactions with their node via a wallet such as [Pyrus](https://pyrus.ubiqsmart.com/), however there is no intention to instruct users to store funds within the gubiq instance running on their node.

The nodes generated through these methods are intended to act as an archive, an access point, and a peer.  

They are not intended to be a wallet!

Please read the file descriptions below carefully to ensure you are using the correct version for your system.

##

## **[node.sh](https://raw.githubusercontent.com/maaatttt/ubiq/master/node.sh)** 

This script handles all the commands for the primary Ubiq node setup procedure.  It will configure directories, download requisite software, and prompt the user for inputs such as node name, passwords, and desired sync method. 

It is currently intended for the following hardware:
- Raspberry Pi 3B / 3B+ / 4B (Raspberry Pi OS - 32bit)
- Asus Tinkerboard / Tinkerboard S (Armbian - 32bit)
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

## **[old-node.sh](https://raw.githubusercontent.com/maaatttt/ubiq/master/old-node.sh)** 

**DEPRICATED**

This script handles all the commands for the primary Ubiq node setup procedure.  It will configure directories, download requisite software, and prompt the user for inputs such as node name, passwords, and desired sync method. 

It is intended to run on a **(32bit)** Raspberry Pi 3B or 3B+ running Raspbian Lite, **_where the OS boots from a microSD card_**, and the system has an attached USB mass storage device for chaindata.

Software downloads; apt-related system software, [supervisor](http://supervisord.org/), [htop](https://hisham.hm/htop/), [git](https://git-scm.com/), [ntp](http://www.ntp.org/), [gubiq](https://github.com/ubiq/go-ubiq/releases)

------------------------------------------------------------------------------------------------------------------------------

## **[old-node2.sh](https://raw.githubusercontent.com/maaatttt/ubiq/master/old-node2.sh)**

**DEPRICATED**

This script handles all the commands for the primary Ubiq node setup procedure.  It will configure directories, download requisite software, and prompt the user for inputs such as node name, passwords, and desired sync method.

It is intended to run on a **(32bit)** Raspberry Pi 3B or 3B+ running Raspbian Lite, **_where the OS boots directly from the external media_**, and the system does **NOT** use a microSD card.

Software downloads; apt-related system software, [supervisor](http://supervisord.org/), [htop](https://hisham.hm/htop/), [git](https://git-scm.com/), [ntp](http://www.ntp.org/), [gubiq](https://github.com/ubiq/go-ubiq/releases/)

------------------------------------------------------------------------------------------------------------------------------

## **[old-node3.sh](https://raw.githubusercontent.com/maaatttt/ubiq/master/old-node3.sh)** 

**DEPRICATED**

This script handles all the commands for the primary Ubiq node setup procedure.  It will configure directories, download requisite software, and prompt the user for inputs such as node name, passwords, and desired sync method.

It is intended to run on a **(32bit)** system such as the Asus Tinkerboard running Armbian, **_where the OS boots from a microSD card_**, and the system has an attached USB mass storage device for chaindata.

Software downloads; apt-related system software, [supervisor](http://supervisord.org/), [htop](https://hisham.hm/htop/), [git](https://git-scm.com/), [ntp](http://www.ntp.org/), [gubiq](https://github.com/ubiq/go-ubiq/releases/)

------------------------------------------------------------------------------------------------------------------------------

## **[old-node4.sh](https://raw.githubusercontent.com/maaatttt/ubiq/master/old-node4.sh)** 

**DEPRICATED**

This script handles all the commands for the primary Ubiq node setup procedure.  It will configure directories, download requisite software, and prompt the user for inputs such as node name, passwords, and desired sync method.

It is intended to run on a **(64bit)** system such as the Ordoid C2 running Armbian or the Libre LePotato running Armbian, **_where the OS boots from a microSD card_**, and the system has an attached USB mass storage device for chaindata.

Software downloads; apt-related system software, [supervisor](http://supervisord.org/), [htop](https://hisham.hm/htop/), [git](https://git-scm.com/), [ntp](http://www.ntp.org/), [gubiq](https://github.com/ubiq/go-ubiq/releases/)

------------------------------------------------------------------------------------------------------------------------------

## **[old-gu2.sh](https://raw.githubusercontent.com/maaatttt/ubiq/master/old-gu2.sh)**

**DEPRICATED**

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

**DEPRICATED**

This script is run as part of an optional cron job that re-fetches an update script monthly. It is downloaded as part of the initial node setup script.  The updater downloads the [gu2.sh](https://raw.githubusercontent.com/maaatttt/ubiq/master/gu2.sh) script, which runs the update commands, then deletes itself to prevent file name conflict when the cron job runs again the following month.  

It is intended to run on a **(64bit)** system such as the Ordoid C2 running Armbian or the Libre LePotato running Armbian.

**Automatic updates to gubiq resulting from the [gu2.sh](https://raw.githubusercontent.com/maaatttt/ubiq/master/gu2.sh) script will _only_ be release versions, and _never_ pre-release beta versions.**

------------------------------------------------------------------------------------------------------------------------------

## Acknowledgments

Special thanks to the Ubiq developers, the Ubiq Community, and the authors of open software used in these processes.

