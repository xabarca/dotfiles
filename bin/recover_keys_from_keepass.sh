#!/bin/sh

. $HOME/bin/encrypt.sh 

#PYTHON_CMD=~/Baixades/python/venv/bin/python
PYTHON_CMD=" python3"

BASEDIR=$(dirname $0)
KEEPASS_CLI=$BASEDIR/keepass_cli.py
DATABASE="/home/xavi/base.kdbx" 
KEYFILE="/tmp/keyfile.$(date +'%Y-%m-%d_%H.%M')"

NEW_AGE_KEY=/tmp/new_age_key
NEW_AGE_KEY_BASE64=/tmp/new_age_key_base64
#AGE_KEY=/tmp/.age.key
PASH_DIR="/tmp/pash.$(date +'%Y-%m-%d_%H.%M')"
PASH_EXT=age

USE_KEYFILE=0

# if --database arg is passed, use that
if [ "$1" = "--dbpath" ]; then
	if [ ! -z "$2" ]; then
		DATABASE="$2"
	fi	
fi

# - - - - - - - - - - - - - - - - - - - - - - - -
_askPassword() {
    echo -n " - Master password: "
    stty -echo
    read MASTERPWD
    stty echo
    echo ""         # force a carriage return to be output
}

#------------------------
#--- [1] ASK PASSWORD ---
#------------------------
_askPassword
echo "database: $DATABASE"


#--------------------------------
#--- [2] GET A NEW AGE KEY   ----
#--------------------------------
age-keygen -o /tmp/tempk
cat /tmp/tempk | grep 'AGE-SECRET' > "$NEW_AGE_KEY"
rm /tmp/tempk



#---------------------------------
#--- [3] GET LIST OF ENTRIES  ----
#---------------------------------
ss="$( $PYTHON_CMD $KEEPASS_CLI --listentries --database "$DATABASE" --password "$MASTERPWD" )"
ss="$( echo $ss | tr -d \' | tr -d '[],' )"
# if keepass returns some estrange characters
ss="$( echo $ss | sed 's|\/\/\/|#|g' | sed 's|\/||g' | sed 's|#|\/|g' )"
echo "$(echo $ss | tr ' ' '\n' )" > /tmp/fff.txt
if [ "$( cat /tmp/fff.txt | head -n 1 )" = "Invalid" ]; then
	echo "wrong password"
	exit 2
fi


#---------------------------------
#--- [4] OBTAIN ENCRYPTED KEYS  --
#---------------------------------
pubkey=$(age-keygen -y $NEW_AGE_KEY)
while read -r name; do
    pass="$( $PYTHON_CMD $KEEPASS_CLI --getsecret --database "$DATABASE" --password "$MASTERPWD" --entry "$name" )"
    echo "... $name"
    case "$name" in 
      */*)
         newpath="$(echo "$name" | awk -F'/' '{print $1}')"
         mkdir -p "$PASH_DIR/$newpath"
         ;;
   esac
   echo "$pass" | age -r "$pubkey" -o "$PASH_DIR/$name.$PASH_EXT"
done < /tmp/fff.txt


#------------------------------------
#--- [5] ENCRYPT AGE KEY (base64)  --
#------------------------------------
_encrypt_file_base64 "$NEW_AGE_KEY" "$NEW_AGE_KEY_base64"


echo "done!"
echo "New AGE key stored in $NEW_AGE_KEY"
echo "New base64 AGE key stored in ${NEW_AGE_KEY}_base64 - Save it in ~/.config/age/"
echo "Keys stored in $PASH_DIR directory"


