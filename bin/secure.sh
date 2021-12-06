#!/bin/sh
#
# my post explaining all this:
# https://forums.bunsenlabs.org/viewtopic.php?id=5865
#
# sudo cryptsetup luksOpen diskImage.iso secureLuks --key-file  ~/.secureKeyFile.txt
# sudo mount /dev/mapper/secureLuks /mnt/secure
#
# sudo umount /mnt/secure
# sudo cryptsetup luksClose secureLuks
#

CONTAINER_PATH=~/container
KEYFILE_PATH=~/myUltraSecureKeyFile
MOUNTING_POINT=/mnt/secure

if [ $# -eq 0 ]
then
    echo " "
    echo "Correct syntax is:  secure up/down"
    echo " "
elif [ "$1" = "up" ]
then
    if [ ! -f "$CONTAINER_PATH" ]
    then
		echo "The container LUKS image $CONTAINER_PATH does not exist"
		exit 1
	fi
    if [ ! -f "$KEYFILE_PATH" ]
    then
		echo "The key file $KEYFILE_PATH does not exist"
		exit 1
	fi
    if [ ! -d "$MOUNTING_POINT" ]
    then
		echo "The mounting point $MOUNTING_POINT does not exist"
		exit 1
	fi

    sudo cryptsetup luksOpen ${CONTAINER_PATH} mntSecureLuksLabel --key-file "$KEYFILE_PATH"
    sudo mount /dev/mapper/mntSecureLuksLabel "$MOUNTING_POINT"
    echo "Secure disk image mounted to $MOUNTING_POINT"
elif [ "$1" = "down" ]
then
   sudo umount "$MOUNTING_POINT"
   sudo cryptsetup luksClose mntSecureLuksLabel
   echo "Secure disk image unmounted"
else
    echo " "
    echo "Correct syntax is:  secure up/down"
    echo " "
fi
