#!/bin/bash

FULL_PATH_VM=~/qemuVMs
MEM_VM=2048
HD_VM_SIZE="8G"

# if set to 1 -> no qemu executed (testing purposes)
DEVELOPMENT_MODE=0


usage()
{
  echo " "	
  echo "Usage:  vm -[ OPTIONS ]"
  echo " "	
  echo "Options: "	
  echo "   -n : name of VM"
  echo "   -d : full path to ISO image (cdrom)"
  echo "   -m : RAM memory in MB (default 2GB)"
  echo "   -s : name of the new snapshot to be created"
  echo "   -r : name of the snapshot to be restored"
  echo "   -i : hard disk info (size, snapshots...)"
  echo "   -p : full path where VM disks are stored (change default one)"
  echo "   -l : list of all VMs currently available in default path"
  echo "   -e : examples of use"
  echo " "	
  exit 2
}

examples()
{
  echo " "	
  echo "Examples of use:"
  echo "----------------"	
  echo " "	
  echo "- create a new VM named 'devuanLAB' using 4GB of RAM with a cdrom with devuan.iso attached to boot into"
  echo "     vm -n devuanLAB -d /path/to/devuan.iso -m 4096"
  echo " "	
  echo "- start the VM named 'voidlinuxtest' having the VM path on /media/usb/vms"
  echo "     vm -n voidlinuxtest -p /media/usb/vms"
  echo " "	
  echo "- take a new snapshot named 'basesnap' to the VM named 'voidlinuxtest'"
  echo "     vm -n voidlinuxtest -s basesnap"
  echo " "	
  echo "- restore the VM named 'voidlinuxtest' with the snapshot previously created with name 'basesnap'"
  echo "     vm -n voidlinuxtest -r basesnap"
  echo " "	
  echo "- list all details of HD of the VM named 'devuanLAB' (size in disk, maxim size, snapshots)"
  echo "     vm -n devuanLAB -i"
  echo " "	
  exit 2
}

deleteEmptyFolders() {
	# delete all empty folders (unsuccessful tests)
	if [ -d "$FULL_PATH_VM" ]; then
		find $FULL_PATH_VM  -empty  -type d  -delete
	fi
}

createFolder() {
  PATH_TO_VM="$FULL_PATH_VM/$VMNAME"
  if [ ! -d "$PATH_TO_VM" ]; then
	  mkdir -p $PATH_TO_VM
	  echo "$PATH_TO_VM created."
  fi
}

diskInfo() {
   PATH_TO_VM="$FULL_PATH_VM/$VMNAME"
   HD_VM="$FULL_PATH_VM/$VMNAME/$VMNAME.qcow2"
   [ ! -f "$HD_VM" ] && echo "HD info selected for VM '$VMNAME', but not disk was found." && exit 2
   if [ "$DEVELOPMENT_MODE" == "0" ]; then
	  qemu-img info $HD_VM
   fi   
#   if [ -d "$PATH_TO_VM" ]; then
#	  ls -lah $PATH_TO_VM | grep qcow2 | awk '{print $5" - "$10}' | sort
#   else
#	  echo "$VMNAME does not exist." && exit 2
#   fi
}


function internet_found_qemu {
	# https://forum.archlabslinux.com/t/bash-functions/3422/7
   qemu-system-x86_64 -enable-kvm -m 4G -cpu host -soundhw hda -vga virtio -display gtk,gl=on -drive file="$1",format=raw,cache=none,if=virtio
}
function internet_found_qemu-iso {
	# https://forum.archlabslinux.com/t/bash-functions/3422/7
   qemu-system-x86_64 -enable-kvm -m 4G -cpu host -soundhw hda -vga virtio -display gtk,gl=on -cdrom "$1" -boot order=d -drive file="$2",format=raw,cache=none,if=virtio
}
function internet_found_qemu-live {
	# https://forum.archlabslinux.com/t/bash-functions/3422/7
   qemu-system-x86_64 -enable-kvm -m 4G -cpu host -soundhw hda -vga virtio -display gtk,gl=on -cdrom "$1"
}


startWM() {
	# TODO  explore the possibilities of shared folders:
	#       https://wiki.archlinux.org/index.php/QEMU#QEMU's_built-in_SMB_server

	
	#  >> http://forums.debian.net/viewtopic.php?f=16&t=144775
	#  >> by Head_on_a_Stick
	#
	#  #!/bin/sh
	#  qemu-system-x86_64 -enable-kvm \
    #                 -m 2G \
    #                 -cpu host \
    #                 -smp cores=4 \
    #                 -drive file=/home/$user/qemu/disk.img,format=raw,cache=none,if=virtio \
    #                 -soundhw hda \
    #                 -vga qxl \
    #                 -device virtio-serial-pci \
    #                 -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
    #                 -chardev spicevmc,id=spicechannel0,name=vdagent \
    #                 -spice unix,addr=/tmp/vm_spice.socket,disable-ticketing \
    # -- basic options to here
    #                 -device nec-usb-xhci,id=usb \
    #                 -chardev spicevmc,name=usbredir,id=usbredirchardev1 \
    #                 -device usb-redir,chardev=usbredirchardev1,id=usbredirdev1 \
    #                 -chardev spicevmc,name=usbredir,id=usbredirchardev2 \
    #                 -device usb-redir,chardev=usbredirchardev2,id=usbredirdev2 \
    # -- usb passthrough
    #                 -fsdev local,id=qemu_dev,path=/home/$user/Public,security_model=none \
    #                 -device virtio-9p-pci,fsdev=qemu_dev,mount_tag=qemu_mount \
    # -- shared folder
    #                 &
    #
	#  remote-viewer "spice+unix:///tmp/vm_spice.socket"
	
	
	
	HD_VM="$FULL_PATH_VM/$VMNAME/$VMNAME.qcow2"
	if [ ! -f "$HD_VM" ]; then
		[ -z "$ISO" ] &&  echo "No HD to boot into. ISO is mandatory." && exit 2
		createHD
	fi
	
	if [ -z "$ISO" ]; then
	    echo "Run VM in HD mode..."
	    if [ "$DEVELOPMENT_MODE" == "0" ]; then
			qemu-system-x86_64 \
			   --enable-kvm \
			   -m $MEM_VM \
			   -M q35 \
			   -cpu host,kvm=off \
			   -smp cores=2,threads=2 \
			   -rtc base=localtime \
			   -hda $HD_VM \
			   -usb -device usb-tablet
		fi
	else
	   if [ ! -f "$ISO" ]; then
		   echo "$ISO does not exist."  && exit 2
	   fi
	   echo "Run VM in cdrom mode..."
	   if [ "$DEVELOPMENT_MODE" == "0" ]; then
		   qemu-system-x86_64 \
			  --enable-kvm \
			  -m $MEM_VM \
			  -cpu host,kvm=off \
			  -M q35 \
			  -smp cores=2,threads=2 \
			  -rtc base=localtime \
			  -hda $HD_VM \
			  -cdrom $ISO \
			  -boot d \
			  -usb -device usb-tablet
		fi
	fi
}

createHD() {
	createFolder
	if [ "$DEVELOPMENT_MODE" == "0" ]; then
		qemu-img create -f qcow2  $HD_VM  $HD_VM_SIZE 
	fi
	echo "$VMNAME.qcow2 created."
}

craeteSnapshot() {
	# Parameters to snapshot subcommand:
    #  'snapshot' is the name of the snapshot to create, apply or delete
    #  '-a' applies a snapshot (revert disk to saved state)
    #  '-c' creates a snapshot
    #  '-d' deletes a snapshot
    #  '-l' lists all snapshots in the given image  
    #
    # EXAMPLE:  qemu-img snapshot  -c snapname  myHD.qcow2	
    #    
    HD_VM="$FULL_PATH_VM/$VMNAME/$VMNAME.qcow2"
    [ ! -f "$HD_VM" ] && echo "No existing image named $VMNAME.qcow2." && exit 2
	if [ "$DEVELOPMENT_MODE" == "0" ]; then
		qemu-img snapshot  -c $SNAPSHOT_NEW_NAME  $HD_VM
	fi
	echo "$SNAPSHOT_NEW_NAME snapshot created to $VMNAME.qcow2"
}

restoreSnapshot() {
	# TODO  from documentation (man qemu-img), use this built-in snapshots tool
	# Parameters to snapshot subcommand:
    #  'snapshot' is the name of the snapshot to create, apply or delete
    #  '-a' applies a snapshot (revert disk to saved state)
    #  '-c' creates a snapshot
    #  '-d' deletes a snapshot
    #  '-l' lists all snapshots in the given image  
    HD_VM="$FULL_PATH_VM/$VMNAME/$VMNAME.qcow2"
    [ ! -f "$HD_VM" ] && echo "No existing image named $VMNAME.qcow2." && exit 2
	if [ "$DEVELOPMENT_MODE" == "0" ]; then
		qemu-img snapshot  -a $SNAPSHOT_RESTORE_NAME  $HD_VM
	fi
	echo "$VMNAME.qcow2 back to snapshot $SNAPSHOT_RESTORE_NAME"
}

listVMs() {
    llista=$(find $FULL_PATH_VM -name *.qcow2)
    #printf "%b\n" $llista
    for f in $llista; do
        fileinfo=$(ls -lh $f)
        echo "$(echo  $fileinfo | awk '{print $5}') $f"
    done
    exit 0
}


# ---------------------------------------------------------
# ---------------------------------------------------------
# ---------------------------------------------------------

while getopts ':n:d:m:s:r:p:iel' c
do
  case $c in
    n) VMNAME=$OPTARG ;;
    d) ISO=$OPTARG ;;
    m) MEM_VM=$OPTARG ;;
    s) SNAPSHOT_NEW_NAME=$OPTARG ;;
    r) SNAPSHOT_RESTORE_NAME=$OPTARG ;;
    p) FULL_PATH_VM=$OPTARG ;;
    i) INFO_HD="y" ;;
    e) EXAMPLES="y" ;;
    l) listVMs ;;
    :) usage ;;
    ?) usage ;;
  esac
done

deleteEmptyFolders
[ ! -z $EXAMPLES ] && examples
[ -z $VMNAME ] && usage
[ "$DEVELOPMENT_MODE" == "1" ] && echo " << development mode >>"

# convert to lowercase
VMNAME=${VMNAME,,}

if [ ! -z $SNAPSHOT_NEW_NAME ]; then
	# convert to lowercase
	SNAPSHOT_NEW_NAME=${SNAPSHOT_NEW_NAME,,}
	craeteSnapshot
elif [ ! -z  $SNAPSHOT_RESTORE_NAME ]; then
	# convert to lowercase
	SNAPSHOT_RESTORE_NAME=${SNAPSHOT_RESTORE_NAME,,}
	restoreSnapshot
elif [ ! -z  $INFO_HD ]; then
	diskInfo
else
	startWM
fi

