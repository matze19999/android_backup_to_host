#!/bin/bash

# needed packages:
which android-tools-adb android-tools-fastboot python3 > /dev/null
if [ $? == 1 ];then
	apt update  > /dev/null
	apt install -y -no-install-recommends android-tools-adb android-tools-fastboot python3 -y  > /dev/null
fi

# Test if adb-sync is installed
if [ ! -f "/usr/local/bin/adb-sync" ];then
	git clone https://github.com/google/adb-sync
	cd adb-sync
	cp adb-sync /usr/local/bin/
	chmod +x /usr/local/bin/adb-sync
	cd ..
	rm -rf adb-sync/
fi


# install Tasker +  Wifi ADB on your android phone
# https://play.google.com/store/apps/details?id=net.dinglisch.android.taskerm
# https://play.google.com/store/apps/details?id=com.ttxapps.wifiadb

# Create a task in tasker, which enables ADB over WIFI every night to the same time

# Create a cronjob (/etc/crontab) on your host with runs at the same time (this would be 02:00 AM every night):	0 2 * * *		root	/opt/bin/android_backup-sync.sh

# The script will sync your internal storage with the BUFolder on your host. It will delete files which aren't available on your phone anymore.


# DNS-Name or IP-Adresse of your android phone
hostname=OnePlus-6

# Backup folder
BUFolder="/opt/Android_Backup/"


SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
SCRIPTNAME=`basename "$0"`
SCRIPT=$SCRIPTPATH/$SCRIPTNAME
zustand=$(adb shell dumpsys battery | grep 'powered')
mkdir -p $BUFolder

if [[ $(adb connect $hostname:5555) == *connected* ]];
then
		if [[ $zustand = *true* ]];
		then
   			adb-sync --reverse -n /sdcard/* $BUFolder
		else
			echo "Script will wait 5 minutes! Please charge your phone!"
			sleep 300
			bash $SCRIPT
			exit
		fi

else
		echo "Script will wait 5 minutes! Please enable ADB over WIFI and connect your phone to the same network!"
		sleep 300
		bash $SCRIPT
		exit
fi
