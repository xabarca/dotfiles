
#!/bin/sh

RCLONE_DESTINATION="gdrive:backup"

BASEDIR=$(dirname $0)
CLOUD=0
DATE_SUFIX="$(date +'%Y-%m-%d_%H.%M')"
LOGFILE="/tmp/backup-log-""$DATE_SUFIX"".log"

generate_keepass_backup() {
    KEEPASS_DB="$BACKUP_FOLDER/$DATE_SUFIX""_keepass.kdbx"
    $HOME/bin/enckeys_keepass_backup.sh --dbpath "$KEEPASS_DB"
}


backup_things() {
    TEMP_BIN_FILE="$BACKUP_FOLDER/$DATE_SUFIX""_bin.tgz.encx"
    TEMP_CONFIG_FILE="$BACKUP_FOLDER/$DATE_SUFIX""_config.tgz.encx"
    TEMP_SDR_FILE="$BACKUP_FOLDER/$DATE_SUFIX""_sdr.tgz.encx"
    TEMP_QMK_FILE="$BACKUP_FOLDER/$DATE_SUFIX""_qmk.tgz.encx"
    TEMP_GITS_FILE="$BACKUP_FOLDER/$DATE_SUFIX""_gits.tgz.encx"
    TEMP_SECURE_FILE="$BACKUP_FOLDER/$DATE_SUFIX""_secure.tgz.encx"
    TEMP_CHESS_FILE="$BACKUP_FOLDER/$DATE_SUFIX""_chess.tgz.encx"
    
    cd $HOME

    tar \
      --exclude='bin/*sigpac_data*' \
      --exclude=**/.git/* \
      -cz \
      bin/ \
      | enchive archive /dev/stdin "$TEMP_BIN_FILE" 

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
      -cz \
      .config/ \
      | enchive archive /dev/stdin "$TEMP_CONFIG_FILE"
    
    tar \
      -cz \
      /opt/sdr/ws___proves \
      /opt/sdr/basedatos \
      /opt/sdr/documents \
      /opt/sdr/config \
      /opt/sdr/working.txt \
      /opt/sdr/sdr_respostes_basiques_suport.txt \
      /opt/sdr/weblogiclinuxbcn01_v1.1-2.md \
      /opt/sdr/snx_install_linux30.sh \
      | enchive archive /dev/stdin "$TEMP_SDR_FILE" 
   
    tar \
      --exclude=**/.git/* \
      --exclude=**/qmk_firmware/* \
      --exclude=**/polybar/* \
      -cz \
      /opt/git_projects/ \
      | enchive archive /dev/stdin "$TEMP_GITS_FILE" 
   
    tar \
      --exclude=**/.git/* \
      -cz \
      .ssh/* \
      .ecckeys/* \
      .enckeys/* \
      .local/share/pash/*  \
      .config/rclone/rclone.conf \
      | enchive archive /dev/stdin "$TEMP_SECURE_FILE" 

    tar \
      -cz \
      altres/chess/trx_folder/ \
      altres/chess/scid_vs_pc_pieces/ \
      altres/chess/databases/*.pgn \
      altres/chess/databases/**/*.pgn \
      altres/chess/chess_training/ \
      | enchive archive /dev/stdin "$TEMP_CHESS_FILE" 


    cd /opt/git_projects/qmk_firmware/keyboards/crkbd
    tar \
      -cz \
      keymaps \
      | enchive archive /dev/stdin "$TEMP_QMK_FILE" 

    cd $BASEDIR
}

usage() { printf %s "\
backup_secure - backup all my personal and important stuff

OPTIONS:
 -d  [path]    -> destination path for backup
 -c  [yes/no]  -> put a copy of your backups in the cloud (no if option omitted)
"
exit 0
}

main() {
    while getopts 'd:c:' opcio
    do
      case $opcio in
        d) FOLDER_DEST=$OPTARG ;;
        c) [ "$OPTARG" = "yes" ] && CLOUD=1 ;;
        :) usage ;;
        ?) usage ;;
      esac
    done

    if [ -z $FOLDER_DEST ]; then
        echo "No folder destination specified. Example: backup_secure.sh /media/lode/usbdisk"
        exit 1
    fi
    if [ ! -d "$FOLDER_DEST" ]; then
        echo "Folder destination specified does not exist."
        exit 1
    fi
    # check if our destination folder is a removable pendrive/usbdisk
    case $FOLDER_DEST in
        /mnt* | /media* | /tmp*)  ;;
        *)
          echo "Destination folder is not a removable media (only /mnt/**, /media/** and /tmp/** accepted)"
          exit 1
        ;;
    esac
    
    BACKUP_FOLDER="$FOLDER_DEST/backup_""$DATE_SUFIX"
    mkdir -p $BACKUP_FOLDER
   
    if [ "$CLOUD" -eq 1 ]; then
        echo "Cloud storage selected."
    else    
        echo "Cloud storage NOT selected."
    fi

    # do the backup... 
    generate_keepass_backup
    backup_things


    # copy the backups to the cloud with rclone
    if [ "$CLOUD" -eq 1 ]; then
        printf "\ncloud uploading..."
        rclone copy $BACKUP_FOLDER $RCLONE_DESTINATION
        printf "\nclone upload finished"
    fi

    printf "\n ** Backups generated at '$BACKUP_FOLDER'"
    if [ "$CLOUD" -eq 1 ]; then
        printf " and uploaded to the cloud."
    fi
    printf "\n"
}

# sanity options
set +x
set -f
[ "$1" ] || usage && main "$@"
