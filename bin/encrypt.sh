#!/bin/sh

# alternative encrypt tool:  AGE
#    age --encrypt -r "$(age-keygen -y /tmp/age-key)" "$file" > "$file"".age"
#    age --decrypt -i /tmp/age-key -o "$file"".decrypted" "$file"".age"



# usage:  _encrypt_file  file  file.enc
_encrypt_file() {
   input_file=$1
   encrypted=$2 
   PASSWORD=$( _get_password )
   openssl enc -aes-256-cbc -salt -md sha256 -pbkdf2 -in $input_file -out $encrypted -k $PASSWORD
}

# usage:  _encrypt_file_base64  file  file.enc
_encrypt_file_base64() {
   input_file=$1
   encrypted=$2 
   PASSWORD=$( _get_password )
   openssl enc -aes-256-cbc -salt -md sha256 -pbkdf2 -base64 -in $input_file -out $encrypted -k $PASSWORD
}

# usage:  _decrypt_file  file.enc  file
_decrypt_file() {
   encrypted=$1 
   output_file=$2
   PASSWORD=$( _get_password )
   openssl enc -aes-256-cbc -d -md sha256 -pbkdf2 -in $encrypted -out $output_file -k $PASSWORD
}

# usage:  _decrypt_file_base64  file.enc  file
_decrypt_file_base64() {
   encrypted=$1 
   output_file=$2
   PASSWORD=$( _get_password )
   openssl enc -aes-256-cbc -d -md sha256 -pbkdf2 -base64 -in $encrypted -out $output_file -k $PASSWORD
}

_get_password() {
	if [ "$ARG_PASSWORD" = "script/cloud.sh"  ]; then
		pass="$( $HOME/bin/pashage s script/cloud.sh )"
	else
        GREEN=$($HOME/bin/getcolor green)
        COLOR_BG=$($HOME/bin/getcolor bg)
        DMENU_COLOR_OPTIONS="-nb $COLOR_BG -sb $GREEN -sf $COLOR_BG -nf $GREEN"
		
        pass=$( echo '' | dmenu -P -p "enter encryption/decryption passphrase:  " )
        #pass=$( echo '' | dmenu -P -p "enter passphrase:  " $DMENU_COLOR_OPTIONS  -c -bw 2 )
	fi
   echo "$pass"
}


_usage() {
   echo "Encryption wrapper tools ... "
   exit 2
}

# Ensure that debug mode is never enabled to
# prevent the password from leaking.
set +x

# Ensure that globbing is globally disabled
# to avoid insecurities with word-splitting.
set -f

