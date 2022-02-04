#!/bin/sh

BASEDIR=$(dirname $0)
DATE_SUFIX="$(date +'%Y-%m-%d_%H.%M')"
BACKUP_FOLDER="/tmp/backup_""$DATE_SUFIX"

KEEPASS_DB="$BACKUP_FOLDER/keepass_""$DATE_SUFIX"".kdbx"
TEMP_BIN_FILE="$BACKUP_FOLDER/bin_""$DATE_SUFIX"".tgz"
TEMP_CONFIG_FILE="$BACKUP_FOLDER/config_""$DATE_SUFIX"".tgz"
TEMP_SECURE_FILE="$BACKUP_FOLDER/secure_""$DATE_SUFIX"".tgz"

generate_keepass_backup() {
    # generete kdbx backup
    $HOME/bin/enckeys_keepass_backup.sh --dbpath "$KEEPASS_DB"
}


backup_things() {
    cd $HOME

    tar \
      --exclude='bin/*sigpac_data*' \
      --exclude=**/.git/* \
      -czvf $TEMP_BIN_FILE \
      bin/

    tar \
      --exclude='.config/VirtualBox' \
      --exclude='.config/skypeforlinux' \
      --exclude='.config/Microsoft' \
      --exclude='.config/Microsoft Teams - Preview' \
      --exclude='.config/google-chrome' \
      --exclude='.config/Skype' \
      --exclude='.config/teams' \
      --exclude='.config/libreoffice' \
      --exclude='.config/enchive' \
      --exclude='.config/rclone' \
      --exclude=**/.git/* \
      -czvf $TEMP_CONFIG_FILE \
      .config/
    
    tar \
      --exclude=**/.git/* \
      -czvf $TEMP_SECURE_FILE \
      .ssh/* .enckeys/* .config/rclone/rclone.conf
    
    enchive archive -d $TEMP_SECURE_FILE

    cd $BASEDIR
}

mkdir -p $BACKUP_FOLDER
generate_keepass_backup
backup_things

printf "\n ** Backups generated at: $BACKUP_FOLDER \n "


