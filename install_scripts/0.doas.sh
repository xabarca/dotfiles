#! /bin/bash

# ---- configure no password actions - sudoers -------
install_doas() {
    apt update
    apt install --no-install-recommends -y doas
    
	#echo "permit nopass keepenv $USER" | sudo tee -a /etc/doas.conf
	
	echo "permit persist keepenv $USER as root" >> /tmp/doas
   #  username ALL=(ALL) NOPASSWD: /usr/bin/reboot, /usr/bin/poweroff, /usr/bin/shutdown, /usr/bin/halt

    echo "permit nopass $USER as root cmd apt" >> /tmp/doas
    echo "permit nopass $USER as root cmd poweroff" >> /tmp/doas
    echo "permit nopass $USER as root cmd reboot" >> /tmp/doas


    #echo "permit nopass $USER" >> /tmp/doas
    # echo "permit persist $USER" >> /tmp/doas
    # echo "permit nopass $USER as root cnd poweroff" >> /tmp/doas
    #echo "permit nopass $USER as root cnd reboot" >> /tmp/doas
    # echo "permit nopass $USER as root cmd /sbin/reboot" >> /tmp/doas
    # echo "permit nopass $USER as root cmd /sbin/poweroff" >> /tmp/doas
    # echo "permit nopass $USER as root cmd /sbin/halt" >> /tmp/doas
    # echo "permit nopass $USER as root cmd /sbin/shutdown args -h now, -r now" >> /tmp/doas
    sudo cp /tmp/doas /etc/doas.conf
    sudo chown -c root:root /etc/doas.conf
    sudo chmod -c 0400 /etc/doas.conf
}

if [ $(id -u) -ne 0 ]; then
   echo "Please run as root"
   exit
fi

install_doas

