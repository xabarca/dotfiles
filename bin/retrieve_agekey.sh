#!/bin/sh
# Retrieves AGE private key from a base64 encrypted AGE private key

#
#  https://github.com/FiloSottile/age
#
#      generate new AGE gey with:
#        age key-gen -o "/tmp/age.key"
#

. $HOME/bin/encrypt.sh

AGE_KEY_ENC_BASE64=/tmp/agekey64.enc
AGE_KEY=/tmp/.agekey

_test() {
   KEYFILE=/tmp/key
   KEYFILE_PRIVATE_KEY=/tmp/key.priv
   KEYFILE_ENC=/tmp/key.enc
   KEYFILE_ENC_BASE64=/tmp/key.enc_base64
   
   [ -f "$KEYFILE" ] && rm $KEYFILE 
   age-keygen -o $KEYFILE
   cat $KEYFILE | grep 'AGE-SECRET' > $KEYFILE_PRIVATE_KEY
   rm $KEYFILE
   echo " "

   _encrypt_file_base64 "$KEYFILE_PRIVATE_KEY" "$KEYFILE_ENC_BASE64"
   rm "$KEYFILE_PRIVATE_KEY"
   echo "encrypted base64: "
   cat "$KEYFILE_ENC_BASE64"
   echo " "
   
   _decrypt_file_base64 "$KEYFILE_ENC_BASE64" "$KEYFILE_PRIVATE_KEY"
   echo "===== decrypted AGE public key ====="
   echo "Public key: $(age-keygen -y $KEYFILE_PRIVATE_KEY)"
   echo " "
}  

_main() {
   if [ -f "$AGE_KEY" ]; then
      herbe "age key already exists"
      exit 0
   elif [ ! -f "$AGE_KEY_ENC_BASE64" ]; then
      herbe "no encrypted age key"
      exit 0 
   else
      _decrypt_file_base64 "$AGE_KEY_ENC_BASE64" "$AGE_KEY"  && herbe "age key file retrieved !" &
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
