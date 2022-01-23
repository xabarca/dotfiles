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
KEYFILE_PATH=~/media/obama/usb/keyfile
MOUNTING_POINT=/mnt/secure

usage() {
    echo " "
    echo " Secure  - easy wrapper for LUKS container management"
    echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - "
    echo " "
    echo " SYNTAX:"
    echo "   secure [ --open/-o | --close/-c | --create ]   [ OPTIONS ]"
    echo " "
    echo " OPTIONS: "
    echo "   --vol | -v  : volume path "
    echo "   --key | -k  : keyfile path "
    echo " "
    echo " EXAMPLES: "
    echo "   secure --open "
    echo "   secure --open --vol /tmp/myvolume.img "
    echo "   secure --open -v myVol -k /mnt/usb/keyfile"
    echo " "
    echo "   secure --close"
    echo " "
    echo "   secure --create" 
    echo "   secure --create -v myVol --key /mnt/usb/keyfile"
    echo " "
    exit 0
}

doit_up() {
    [ ! -z "$vol" ] && CONTAINER_PATH="$vol"
    if [ ! -f "$CONTAINER_PATH" ]
    then
		echo "The container LUKS image $CONTAINER_PATH does not exist"
		exit 1
	fi
   
    # keyfile
    [ ! -z "$key" ]  && KEYFILE_PATH="$key" 
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
    exit 0
}

doit_down() {
   sudo umount "$MOUNTING_POINT"
   sudo cryptsetup luksClose mntSecureLuksLabel
   echo "Secure disk image unmounted"
   exit 0
}

doit_create() {
    NEW_VOL_PATH=/tmp
    VOLUME=$NEW_VOL_PATH/volume.img
    KEYFILE=$NEW_VOL_PATH/keyfile
    LUKS_OPTIONS="--type luks2 --pbkdf argon2id --cipher aes-xts-plain64 --key-size 512 --hash sha512"

    [ ! -z "$vol" ] && VOLUME="$vol"
    if [ -f "$VOLUME" ]
    then
		echo "The volume file $VOLUME already exists"
		exit 1
	fi

    if [ ! -d "$MOUNTING_POINT" ]
    then
		echo "The mounting point $MOUNTING_POINT does not exist"
		exit 1
	fi

    # keyfile
    if [ -z "$key" ]; then
        dd if=/dev/urandom  of=$KEYFILE  bs=1024  count=1
    else
       KEYFILE="$key" 
       if [ ! -f "$KEYFILE" ]
       then
		   echo "The key file $KEYFILE does not exist"
		   exit 1
	   fi
    fi

    # create volume disk
    dd if=/dev/zero  of=$VOLUME bs=1  count=0  seek=100M

    # encrypt volume
    sudo cryptsetup  luksFormat $LUKS_OPTIONS $VOLUME $KEYFILE 
   
    # prepare volume (format and give permissions)
    sudo cryptsetup  luksOpen  $VOLUME myVol --key-file $KEYFILE
    sudo mkfs.ext4  /dev/mapper/myVol
    sudo mount /dev/mapper/myVol $MOUNTING_POINT
    sudo chown  -R  $USER  $MOUNTING_POINT
    sudo umount  $MOUNTING_POINT
    sudo cryptsetup luksClose myVol

    echo " "
    echo "Volume created on $VOLUME"
    echo "Ḱeyfile :: $KEYFILE"
    echo "Please, secure them both!"
}


while [ $# -gt 0 ]; do
   noArgsRelated=""
   case "$1" in
      --vol|-v)
        vol="$2"
        ;;
      --key|-k)
        key="$2"
        ;;
      --open|-o)
        option="open"
        noArgsRelated="yes"
        ;;
      --close|-c)
        option="close"
        noArgsRelated="yes"
        ;;
      --create)
        option="create"
        noArgsRelated="yes"
        ;;
    esac
    shift
    if [ -z $noArgsRelated ]; then
       [ ! -z $2 ] && shift 
    fi
done

[ -z $option ] && usage
[ "$option" = "open" ] && doit_up
[ "$option" = "close" ] && doit_down
[ "$option" = "create" ] && doit_create

