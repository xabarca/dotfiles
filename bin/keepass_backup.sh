#!/bin/sh

#PYTHON_CMD=~/Baixades/python/venv/bin/python
PYTHON_CMD=" python3"

BASEDIR=$(dirname $0)
KEEPASS_CLI=$BASEDIR/keepass_cli.py
BLANK_TEMPLATE_DB=$HOME/bin/keepass_blank.kdbx
DATABASE="/tmp/backup_$(date +'%Y-%m-%d_%H.%M')"".kdbx"
KEYFILE="/tmp/keyfile.$(date +'%Y-%m-%d_%H.%M')"

USE_KEYFILE=0
USE_BLANK_TEMPLATE_DB=1

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
    printf '\n'
    echo ""         # force a carriage return to be output

    [ "$MASTERPWD" != "$PWDRETYPE" ] && printf "Passwords do not match\n" && exit 1
}

ask_for_password() {
    sread MASTERPWD  "Enter password"
    sread RETYPEPWD "Enter password (again)"

    [ "$MASTERPWD" = "$RETYPEWD" ] || printf "Passwords do not match\n" && exit 1
}

backup_from_keepass() {
    ss="$( $PYTHON_CMD $KEEPASS_CLI --listentries --database "$DATABASE" --password "$MASTERPWD" )"
    ss="$( echo $ss | tr -d \' | tr -d '[],' )"
    # echo "$(echo $ss | tr ' ' '\n' )"
    echo "$(echo $ss | tr ' ' '\n' )" > /tmp/fff.txt
    cat /tmp/fff.txt
}

#------------------------
#--- [1] ASK PASSWORD ---
#------------------------
_askPassword
#echo "master password is: $MASTERPWD"
echo "database: $DATABASE"


#---------------------------
#--- [2] CREATE DATABASE ---
#---------------------------
if [ $USE_KEYFILE -eq 1 ]; then
	openssl rand -base64 258 > $KEYFILE
	echo "keyfile:  $KEYFILE"
fi

[ $USE_BLANK_TEMPLATE_DB -eq 1 ] && cp "$BLANK_TEMPLATE_DB" "$DATABASE"
	
if [ $USE_KEYFILE -eq 1 ]; then
	if [ $USE_BLANK_TEMPLATE_DB -eq 0 ]; then
		$PYTHON_CMD $KEEPASS_CLI --create --database "$DATABASE" --password "$MASTERPWD" --keyfile $KEYFILE
	else
		$PYTHON_CMD $KEEPASS_CLI --changepwd --database "$DATABASE" --password "password" --newpwd "$MASTERPWD" --keyfile "$KEYFILE"
	fi
else
	if [ $USE_BLANK_TEMPLATE_DB -eq 0 ]; then
		$PYTHON_CMD $KEEPASS_CLI --create --database "$DATABASE" --password "$MASTERPWD"
	else
		$PYTHON_CMD $KEEPASS_CLI --changepwd --database "$DATABASE" --password "password" --newpwd "$MASTERPWD"
	fi
fi


#-----------------------
#--- [3] ADD ENTRIES ---
#-----------------------
list=$($HOME/bin/pashage l)
for key in $list;do
	echo " add key: $key"
	passwd="$( $HOME/bin/pashage s $key )"
	if [ $USE_KEYFILE -eq 1 ]; then
		$PYTHON_CMD $KEEPASS_CLI --database "$DATABASE" --password "$MASTERPWD" --entry "$key" --entrypwd "$passwd" --keyfile "$KEYFILE"
	else
		$PYTHON_CMD $KEEPASS_CLI --database "$DATABASE" --password "$MASTERPWD" --entry "$key" --entrypwd "$passwd"
	fi
done

echo "done!"
echo "Maybe you sould:  scp $DATABASE termux-redmi:/sdcard/Documents"
