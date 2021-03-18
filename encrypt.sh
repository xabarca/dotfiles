#! /bin/sh

PASSWORD="jfj33f33f3hi3hi3i"


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
	_encrypt_file $PATH_IN $PATH_OUT
else
	_decrypt_file $PATH_IN $PATH_OUT
fi

