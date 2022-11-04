#!/bin/sh

#
#  https://github.com/FiloSottile/age
#
#      generate new AGE gey with:
#        age key-gen -o "/tmp/age.key"
#


AGE_KEY_ENC=/tmp/agekey.enc
AGE_KEY=/tmp/.agekey


# usage:  _encrypt_file  file  file.enc
_encrypt_file() {
   input_file=$1
   encrypted=$2 
   PASSWORD=$( _get_password )
   openssl enc -aes-256-cbc -salt -md sha256 -pbkdf2 -in $input_file -out $encrypted -k $PASSWORD
}

# usage:  _decrypt_file  file.enc  file
_decrypt_file() {
   encrypted=$1 
   output_file=$2
   PASSWORD=$( _get_password )
   openssl enc -aes-256-cbc -d -md sha256 -pbkdf2 -in $encrypted -out $output_file -k $PASSWORD
}

_get_password() {
   pass=$( dmenu -P -p "enter master password :  " -c )
   echo "$pass"
}

_test() {
   KEYFILE=/tmp/key
   KEYFILE_ENC=/tmp/key.enc
   KEYFILE_DEC=/tmp/key.new

   [ -f "$KEYFILE" ] && rm $KEYFILE 
   age-keygen -o $KEYFILE
   cat $KEYFILE

   _encrypt_file "$KEYFILE" "$KEYFILE_ENC" 
   echo "encrypted: "
   cat $KEYFILE_ENC
   echo " "
   
   _decrypt_file "$KEYFILE_ENC" "$KEYFILE_DEC" 
   echo "decrypted: "
   cat $KEYFILE_DEC
   echo " "
}  

_main() {
   if [ -f "$AGE_KEY" ]; then
      herbe "age key already exists"
      exit 0
   elif [ ! -f "$AGE_KEY_ENC" ]; then
      herbe "no encrypted age key"
      exit 0 
   else
      _decrypt_file "$AGE_KEY_ENC" "$AGE_KEY"  && herbe "age key file retrieved !" &
   fi
}

_usage() {
   echo "Retrieves and decrypts AGE key ... "
   exit 2
}

# Ensure that debug mode is never enabled to
# prevent the password from leaking.
set +x

# Ensure that globbing is globally disabled
# to avoid insecurities with word-splitting.
set -f

#_test "$@"
_main "$@"
