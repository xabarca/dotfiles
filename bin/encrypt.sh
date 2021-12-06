#! /bin/bash

PASSWORD="abcdefghijk123456789"

# -------- lab notes of encrypt / decrypt with SSH keys ---------
#
#  # 1) generate a keyfile
#  openssl rand -hex 64 > key.bin
#  
#  # 2) encrypt myimage.jpg with keyfile key.bin
#  openssl enc -aes-256-cbc -salt -md sha256 -pbkdf2 -in  myimage.jpg -out myimage.jpg.enc -pass file:./key.bin
#  
#  # 3) generate a PEM key-pair ssh keys
#  ssh-keygen -t rsa -m PEM -f /tmp/sshKeysName -P ''
#  
#  # 4) encrypt the key.bin keyfile with public key
#  openssl rsautl -encrypt -oaep -pubin -inkey <(ssh-keygen -e -f /tmp/sshKeysName.pub -m PKCS8) -in key.bin -out secret.key.enc
#  
#  # 5) send files to final user:  secret.key.enc  &  myimage.jpg.enc
#  
#  # 6) final user decrypts the secret.key.enc using the private key
#  openssl rsautl -decrypt -oaep -inkey /tmp/sshKeysName -in secret.key.enc -out secret.key
#  
#  # 7) finally decrypt myimage.jpg.enc to get back the original myimage.jpg
#  openssl enc -aes-256-cbc -d -md sha256 -pbkdf2 -in myimage.jpg.enc -out myimage2.jpg -pass file:./secret.key
#  


FOLDER_TEMP_ENCRYPTIONS=/tmp/encypt_lab
KEYFILE=/tmp/keyfile
KEYFILE_ENC=/tmp/keyfile.enc
KEY_PUBLIC=/tmp/sshKeysName.pub
KEY_PRIVATE=/tmp/sshKeysName

# usage: _enc_file  input_file  encrypted_file
_enc_file() {
   [ -d $FOLDER_TEMP_ENCRYPTIONS ] && rm -r $FOLDER_TEMP_ENCRYPTIONS 
   mkdir -p "$FOLDER_TEMP_ENCRYPTIONS"
   input_file=$1
   encrypted=$2 
   # gerate keyfile
   openssl rand -hex 64 > $KEYFILE
   # encrypt file 
   openssl enc -aes-256-cbc -salt -md sha256 -pbkdf2 -in $input_file -out $encrypted -pass file:$KEYFILE
   # encrypt keyfile with public key and remove non-encrypted keyfile
   openssl rsautl -encrypt -oaep -pubin -inkey <(ssh-keygen -e -f $KEY_PUBLIC -m PKCS8) -in $KEYFILE -out $KEYFILE_ENC
   # remove the temp key
   rm $KEYFILE
}

# usage: _dec_file  encrypted_file  encrypted_keyfile  decrypted_file
_dec_file() {
   [ -d $FOLDER_TEMP_ENCRYPTIONS ] && rm -r $FOLDER_TEMP_ENCRYPTIONS 
   mkdir -p "$FOLDER_TEMP_ENCRYPTIONS"
   encrypted_file=$1 
   encrypted_keyfile=$2
   decrypted_file=$3
   # decrypt the keyfile using our private key
   openssl rsautl -decrypt -oaep -inkey $KEY_PRIVATE -in $encrypted_keyfile -out $KEYFILE
   # decrypt the file using our decrypted keyfile
   openssl enc -aes-256-cbc -d -md sha256 -pbkdf2 -in $encrypted_file -out $decrypted_file -pass file:$KEYFILE
   # remove the key
   rm $KEYFILE
}


# -------------------------------------------------------------------------------- 

#   secret=$(echo "this is a secret." | openssl enc -e -des3 -base64 -pass pass:mypasswd -pbkdf2)
#   echo "${secret}" | openssl enc -d -des3 -base64 -pass pass:mypasswd -pbkdf2


usage()
{
   echo "Usage: $0 [ -e INPUT_FILE | -d INPUT_FILE ] [ -o OUTPUT_FILE ]"
   exit 2
}

# usage:  _encrypt_text  cadena
_encrypt_text() {
   #var_encrypted=$( echo $1 | openssl aes-256-cbc -a -salt -pass pass:somePASSWORD )
   var_encrypted=$( echo $1 | openssl aes-256-cbc -a -salt -pass pass:$PASSWORD )
   echo $var_encrypted
}

# usage:  _decrypt_text  enc-cadena
_decrypt_text() {
   echo $1 | openssl aes-256-cbc -d -a -pass pass:$PASSWORD
}

# usage:  _encrypt_file  file  file.enc
_encrypt_file() {
   input_file=$1
   encrypted=$2 
   openssl enc -aes-256-cbc -salt -in $input_file -out $encrypted -k $PASSWORD
}

# usage:  _decrypt_file  file.enc  file
_decrypt_file() {
   encrypted=$1 
   output_file=$2
   openssl enc -aes-256-cbc -d -in $encrypted -out $output_file -k $PASSWORD
}


# TEST  encrypt  words
_test_word() {
	a=$( _encrypt_text $1 )
	echo $a
	_decrypt_text $a
}

# TEST  encrypt  files
_test_files() {
	_encrypt_file  file.txt  file.enc
	_decrypt_file  file.enc  original.txt
}



# usage 
# command -e file -o file.enc
# command -d file.enc -o file
while getopts 'e:d:o:' c
do
  case $c in
    e) PATH_IN=$OPTARG  ACTION="enc" ;;
    d) PATH_IN=$OPTARG  ACTION="dec" ;;
    o) PATH_OUT=$OPTARG ;;
    h|?) usage ;;
    *) usage ;;
  esac
done

[ -z "$ACTION" ] && usage
[ -z "$PATH_OUT" ] && usage

if [ "$ACTION" = "enc" ];
then
	#_encrypt_file $PATH_IN $PATH_OUT
	_enc_file $PATH_IN $PATH_OUT
else
	#_decrypt_file $PATH_IN $PATH_OUT
	_dec_file $PATH_IN  $KEYFILE_ENC  $PATH_OUT
fi

