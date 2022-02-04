#!/bin/sh

PYTHON_CMD=~/Baixades/python/venv/bin/python
#PYTHON_CMD=" python3"

BASEDIR=$(dirname $0)
KEEPASS_CLI=$BASEDIR/keepass_cli.py
BLANK_TEMPLATE_DB=$HOME/bin/keepass_blank.kdbx
DATABASE="/tmp/backup_$(date +'%Y-%m-%d_%H.%M')"".kdbx"
KEYFILE="/tmp/keyfile.$(date +'%Y-%m-%d_%H.%M')"

USE_KEYFILE=0

# if --database arg is passed, use that
if [ "$1" = "--dbpath" ]; then
	if [ ! -z "$2" ]; then
		DATABASE="$2"
	fi	
fi

# - - - - - - - - - - - - - - - - - - - - - - - -
_askPassword() {
    echo " "
    echo -n " - Master password: "
    stty -echo
    read MASTERPWD
    stty echo
    echo ""         # force a carriage return to be output
    
    echo -n " - Retype it: "
    stty -echo
    read PWDRETYPE 
    stty echo
    echo ""         # force a carriage return to be output
    echo " "

    [ "$MASTERPWD" != "$PWDRETYPE" ] && printf "Passwords do not match\n" && exit 1
}

_enterpwd () { 
	clear
	echo ''
	echo 'MASTER PASSWORD'
	echo ''
	echo -e "\n"
	read -s -p "Type master password : " MASTERPWD
	echo ''
	read -s -p "Retype it : " MASTERPWD_retype
	[[ -z "$MASTERPWD" ]] && _userpwd
	if [[ "$MASTERPWD" != "$MASTERPWD_retype" ]]; then
		unset $MASTERPWD
		printf "\n\nPassword and retype doesn't match. Try again..."
		sleep 2
		_enterpwd
	fi
}

#------------------------
#--- [1] ASK PASSWORD ---
#------------------------
_askPassword
#_enterpwd
#echo "master password is: $MASTERPWD"
echo "database: $DATABASE"
openssl rand -base64 258 > $KEYFILE


#---------------------------
#--- [2] CREATE DATABASE ---
#---------------------------
if [ $USE_KEYFILE -eq 1 ]; then
	openssl rand -base64 258 > $KEYFILE
	echo "keyfile:  $KEYFILE"
fi
#cp "$BLANK_TEMPLATE_DB" "$DATABASE"
if [ $USE_KEYFILE -eq 1 ]; then
	$PYTHON_CMD $KEEPASS_CLI --create --database "$DATABASE" --password "$MASTERPWD" --keyfile $KEYFILE
	#$PYTHON_CMD $KEEPASS_CLI --changepwd --database "$DATABASE" --password "password" --newpwd "$MASTERPWD" --keyfile "$KEYFILE"
else
	$PYTHON_CMD $KEEPASS_CLI --create --database "$DATABASE" --password "$MASTERPWD"
	#$PYTHON_CMD $KEEPASS_CLI --changepwd --database "$DATABASE" --password "password" --newpwd "$MASTERPWD"
fi


#-----------------------
#--- [3] ADD ENTRIES ---
#-----------------------
list=$(find $HOME/.enckeys -type f | sed -e 's|.enckeys/||' -e 's/.enc//' -e 's/_scr//' -e "s|$HOME/||")

for key in $list;do
	echo "add key: $key"
	passwd="$( $HOME/bin/enckeys.sh --name "$key" )"
	if [ $USE_KEYFILE -eq 1 ]; then
		$PYTHON_CMD $KEEPASS_CLI --database "$DATABASE" --password "$MASTERPWD" --entry "$key" --entrypwd "$passwd" --keyfile "$KEYFILE"
	else
		$PYTHON_CMD $KEEPASS_CLI --database "$DATABASE" --password "$MASTERPWD" --entry "$key" --entrypwd "$passwd"
	fi

done
echo " done! "

