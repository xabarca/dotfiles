#!/bin/sh
#
# my post explaining all this:
# https://forums.bunsenlabs.org/viewtopic.php?id=5865
#
# create container & keyfile:
# dd if=/dev/urandom of=keyfile bs=1024  count=1
# dd if=/dev/zero  of=container bs=1  count=0  seek=100M
#
# encrypt container and prepare everything:
# sudo cryptsetup luksFormat --type luks2 --pbkdf argon2id --cipher aes-xts-plain64 --key-size 512 --hash sha512 container keyfile
# sudo cryptsetup luksOpen container myVol --key-file keyfile
# sudo mkfs.ext4 /dev/mapper/myVol
# sudo mount /dev/mapper/myVol /mnt/secure/
# sudo chown -R $USER /mnt/secure/
# sudo umount /mnt/secure
# sudo cryptsetup luksClose myVol
#
# open container:
# sudo cryptsetup luksOpen cointainer myDiskLabel --key-file keyfile 
# sudo mount /dev/mapper/myDiskLabel /mnt/secure
#
# close container:
# sudo umount /mnt/secure
# sudo cryptsetup luksClose myDiskLabel
#


# default values
CONTAINER_PATH=~/container
KEYFILE_PATH=~/docs/configs_project.pdf
MOUNTING_POINT=/mnt/secure

usage() {
    echo " "
    echo " secureluks  - easy wrapper for LUKS container management"
    echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - "
    echo " "
    echo " SYNTAX:"
    echo "   secureluks --open   [ OPTIONS ] - open container and mount it"
    echo "   secureluks --close  [ OPTIONS ] - close and unmount container"
    echo "   secureluks --create [ OPTIONS ] - create and configure new container"
    echo " "
    echo " OPTIONS: "
    echo "   --vol | -v         : volume path"
    echo "   --key | -k         : keyfile path"
    echo "   --mountpoint | -m  : mounting point"
    echo "   --size             : size for the new volume"
    echo " "
    echo " EXAMPLES: "
    echo "   secureluks --open "
    echo "   secureluks --open --vol /tmp/myContainer.img -m /mnt/mount1"
    echo "   secureluks --open -v myContainer -k /mnt/usb/keyfile"
    echo " "
    echo "   secureluks --close"
    echo "   secureluks --close --mountpoint /mnt/mount1"
    echo " "
    echo "   secureluks --create --size 500M" 
    echo "   secureluks --create -v volume --key /mnt/usb/keyfile -m /mnt/mount1"
    echo " "
    exit 0
}

doit_open() {
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

    uuid="$(sudo cryptsetup luksUUID ${CONTAINER_PATH})"
    sudo cryptsetup luksOpen ${CONTAINER_PATH} $uuid --key-file "$KEYFILE_PATH"
    sudo mount /dev/mapper/$uuid "$MOUNTING_POINT"
    echo "Secure disk image mounted to $MOUNTING_POINT"
    exit 0
}

doit_close() {
    quantsCrypt=$( lsblk | grep crypt | grep '/mnt' | wc -l )
    if [ $quantsCrypt -eq 0 ]; then
        echo "ERROR. No LUKS device mounted on /mnt/* to be closed."
        exit 1
    elif [ $quantsCrypt -eq 1 ]; then
        MOUNTING_POINT=$( lsblk | grep crypt | awk '{print $7}' )
        uuid=$(lsblk | grep crypt | awk '{print $1}' | tr -d '└─')
        sudo umount "$MOUNTING_POINT"
        sudo cryptsetup luksClose $uuid
        echo "Secure disk image unmounted"
        exit 0
    else
        if [ -z $mountpoint ]; then
            echo " "
            lsblk | grep crypt | awk '{print $1 "  " $4 "  " $7}'
            echo " "
            echo "More than one LUKS device mounted. Please specify the mountpoint of the LUKS device to be closed, by using optiom '--mountpoint /mnt/XXXX'"
            exit 1
        else
            quantsCrypt=$( lsblk | grep crypt | grep $mountpoint | wc -l )
            if [ $quantsCrypt -eq 1 ]; then
                MOUNTING_POINT=$( lsblk | grep crypt | awk '{print $7}' )
                uuid=$(lsblk | grep crypt | grep $mountpoint | awk '{print $1}' | tr -d '└─')
                sudo umount "$mountpoint"
                sudo cryptsetup luksClose $uuid
                echo "Secure disk image unmounted"
                exit 0
            else
                echo "ERROR. Mountpoint not correct. Please specify the correct mountpoint of the LUKS device to be closed, by using optiom '--mountpoint /mnt/XXXX'"
                exit 1
            fi
        fi
    fi
}

doit_create() {
    NEW_VOL_PATH=/tmp
    VOLUME=$NEW_VOL_PATH/volume.img
    KEYFILE=$NEW_VOL_PATH/keyfile
    LUKS_OPTIONS="--type luks2 --pbkdf argon2id --cipher aes-xts-plain64 --key-size 512 --hash sha512"
    VOL_SIZE="100M"

    [ ! -z "$size" ] && VOL_SIZE="$size"
    
    [ ! -z "$vol" ] && VOLUME="$vol"
    if [ -f "$VOLUME" ]
    then
		echo "The volume file $VOLUME already exists"
		exit 1
	fi

    # keyfile
    if [ -z "$key" ]; then
        dd if=/dev/urandom  of=$KEYFILE  bs=1024  count=1
        #openssl rand -base64 1024 > $KEYFILE
    else
       KEYFILE="$key" 
       if [ ! -f "$KEYFILE" ]
       then
		   echo "The key file $KEYFILE does not exist"
		   exit 1
	   fi
    fi

    # create volume disk
    dd if=/dev/zero  of=$VOLUME bs=1  count=0  seek=$VOL_SIZE

    # encrypt volume
    sudo cryptsetup  luksFormat $LUKS_OPTIONS $VOLUME $KEYFILE 
   
    # prepare volume (format and give permissions)
    sudo cryptsetup  luksOpen  $VOLUME myVol --key-file $KEYFILE
    sudo mkfs.ext4   /dev/mapper/myVol
    sudo mount  /dev/mapper/myVol  $MOUNTING_POINT
    sudo chown  -R  $USER  $MOUNTING_POINT
    sudo umount  $MOUNTING_POINT
    sudo cryptsetup luksClose myVol
    echo " "
    echo "Volume :: $VOLUME"
    echo "Ḱeyfile :: $KEYFILE"
    echo "Please, secure them both!"
}

main() {
    while [ $# -gt 0 ]; do
       noArgsRelated=""
       case "$1" in
          --vol|--volume|-v)
            vol="$2"
            ;;
          --mountpoint|-m)
            mountpoint="$2"
            ;;
          --key|-k)
            key="$2"
            ;;
          --size)
            size="$2"
            ;;
          --open)
            option="open"
            noArgsRelated="yes"
            ;;
          --close)
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
    
    [ -z "$option" ] && usage

    # does mount point exist ?
    [ ! -z "$mountpoint" ] && MOUNTING_POINT="$mountpoint"
    if [ ! -d "$MOUNTING_POINT" ]; then
		echo "The mounting point $MOUNTING_POINT does not exist"
		exit 1
	fi
    
    [ "$option" = "open" ] && doit_open
    [ "$option" = "close" ] && doit_close
    [ "$option" = "create" ] && doit_create
}

# sanity options
set +x
set -f
[ "$1" ] || usage && main "$@"
