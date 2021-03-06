#! /bin/sh


# TODO :  verify if a PATH_FILE exist
#         maybe delte and re-create the temp encryption lab folder
#         store the password into an external file (not hardcoded here)
#  [ -d $TMP_DIR ] && rm -r $TMP_DIR

# format:  [rclone alias name]:[remote folder]
CLOUD_RCLONE_ALIAS="gdrive:mycloud"

FOLDER_TEMP_ENCRYPTIONS="/tmp/encryption_lab"
PASSWORD="jfj33f33f3hi3hi3i"



usage()
{
   echo "Usage: $0 [ -p | --put FILE ] [ -g | --get FILE ] [ -l | --list ]"
   exit 2
}


_list_files() {
   rclone lsl "$CLOUD_RCLONE_ALIAS"
   exit 2
}

_put_file_to_cloud() {
   file=$1
   [ -d $FOLDER_TEMP_ENCRYPTIONS ] && rm -r $FOLDER_TEMP_ENCRYPTIONS 
   mkdir -p "$FOLDER_TEMP_ENCRYPTIONS"
   encrypted_file="$FOLDER_TEMP_ENCRYPTIONS/$file"
   _encrypt_file "$file" "$encrypted_file"
   rclone copy "$encrypted_file" "$CLOUD_RCLONE_ALIAS"
}

_get_file_from_cloud() {
   file=$1
   [ -d $FOLDER_TEMP_ENCRYPTIONS ] && rm -r $FOLDER_TEMP_ENCRYPTIONS 
   mkdir -p "$FOLDER_TEMP_ENCRYPTIONS"
   rclone copy "$CLOUD_RCLONE_ALIAS/$file" "$FOLDER_TEMP_ENCRYPTIONS"
   mv "$FOLDER_TEMP_ENCRYPTIONS/$file" "$FOLDER_TEMP_ENCRYPTIONS/enc_$file" 
   _decrypt_file  "$FOLDER_TEMP_ENCRYPTIONS/enc_$file" "$FOLDER_TEMP_ENCRYPTIONS/$file" 
   cp "$FOLDER_TEMP_ENCRYPTIONS/$file" .
}

# usage:  _encrypt_file  file  file.enc
_encrypt_file() {
   input_file=$1
   encrypted=$2 
   openssl enc -aes-256-cbc -salt -md sha256 -pbkdf2 -in $input_file -out $encrypted -k $PASSWORD
}

# usage:  _decrypt_file  file.enc  file
_decrypt_file() {
   encrypted=$1 
   output_file=$2
   openssl enc -aes-256-cbc -d -md sha256 -pbkdf2 -in $encrypted -out $output_file -k $PASSWORD
}




case $1 in
	-p|--put)  FILE_PATH=$2  ACTION="put"  ;;
	-g|--get)  FILE_PATH=$2  ACTION="get"  ;;
	-l|--list) ACTION="list"  ;;
	*) usage ;;
esac

[ -z "$ACTION" ] && usage
[ "$ACTION" = "list" ] && _list_files
[ -z "$FILE_PATH" ] && usage

if [ "$ACTION" = "get" ];
then
   _get_file_from_cloud $FILE_PATH
elif [ "$ACTION" = "put" ];
then
   _put_file_to_cloud $FILE_PATH
fi

