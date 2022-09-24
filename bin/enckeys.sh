#! /bin/sh

# -------- notes of encrypt - decrypt with SSH keys lab ---------
#
#  # generate a keyfile (example string to be encrypted)
#  openssl rand -hex 64 > key.bin
#  
#  # generate a PEM key-pair ssh keys
#  ssh-keygen -t rsa -b 4096 -m PEM -f ./name_key -P ''
#  
#  # encrypt the key.bin keyfile with public key
#  openssl rsautl -encrypt -oaep -pubin -inkey <(ssh-keygen -e -f name_key.pub -m PKCS8) -in key.bin -out secret.key.enc
#  
#  # decrypt the secret.key.enc using private key
#  openssl rsautl -decrypt -oaep -inkey name_key -in secret.key.enc -out secret.key
#  

FOLDER_STORE_KEYS=$HOME/.enckeys
KEY_PRIVATE=~/.ssh/mykey
KEY_PUBLIC=~/.ssh/mykey.pub

PADDING="-pkcs" 
CLIPBOARD_CMD="xsel -ib"
APPENDIX_SCRIPT_KEYS="_scr"


# usage: _enc_file  input_file  encrypted_file
_enc_file() {
   input_file=$1
   encrypted=$2 
   # encrypt keyfile with public key and remove non-encrypted keyfile
   ssh-keygen -e -f "$KEY_PUBLIC" -m PKCS8 > /tmp/pubkey
   openssl rsautl -encrypt "$PADDING" -pubin -inkey /tmp/pubkey -in "$input_file" -out "$encrypted"
   rm /tmp/pubkey
   #enchive archive "$input_file" "$encrypted"
}

# usage: _dec_file  encrypted_file 
_dec_file() {
   encrypted_file="$1" 
   decrypted_file="$2"
   # decrypt the keyfile using our private key
   decrypted=$( openssl rsautl -decrypt $PADDING -inkey "$KEY_PRIVATE" -in "$encrypted_file" )
   #enchive --agent=36000 --pinentry=pinentry-gnome3 extract "$encrypted_file" "$decrypted_file"
   echo "$decrypted"
}

# usage:  _encrypt  cadena  alias  scriptonly
_encrypt() {
    echo "encrypt $1 $2" > /tmp/log
   alias="$1"
   pass="$2"
   only_scripts=$3

   [ -z $pass ] && pass="$(generatePassword)"
   echo "$pass" > /tmp/key
   destEncFile="$FOLDER_STORE_KEYS/$alias"".enc"
   [ "$only_scripts" = "yes" ] && destEncFile="$destEncFile""$APPENDIX_SCRIPT_KEYS"

   case "$alias" in 
      */*)
         newpath="$(echo "$alias" | awk -F'/' '{print $1}')"
         mkdir -p "$FOLDER_STORE_KEYS/$newpath"
         ;;
   esac
   _enc_file  /tmp/key  "$destEncFile"
   rm /tmp/key
   exit 0
}

# usage:  _decrypt  alias
_decrypt() {
    echo "decrypt $1" > /tmp/log
    if [ ! -f "$KEY_PRIVATE" ]; then
        herbe -c "no private key available" &
        echo "no private key available"
        exit 0
    fi
    
    alias="$1"
    #  xsel -ib  -> copy to clibboard
    #  xsel -cb  -> clear clibboard

    enc_key_file="$FOLDER_STORE_KEYS/$alias"".enc" 
    [ ! -f "$enc_key_file" ] && enc_key_file="$enc_key_file""$APPENDIX_SCRIPT_KEYS"
    [ ! -f "$enc_key_file" ] && echo "no key" && exit 0

    decrypted="$( _dec_file "$enc_key_file" )"

    # block to erase our key from clipboard
    if [ ! -z $clip ]; then
        {
            sleep 12s || kill 0
            $CLIPBOARD_CMD </dev/null
        } &
    fi

    [ ! -z $clip ] \
        && echo "$decrypted" | $CLIPBOARD_CMD \
        || echo "$decrypted" 
    exit 0
}

generatePassword() {
   # another options: 
   # dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev 
   # openssl rand -base64 20 

    charsAllowed="A-Z-a-z-0-9_-"
    length=24
    pass=$(LC_ALL=C tr -dc "$charsAllowed" 2>/dev/null < /dev/urandom |
            dd ibs=1 obs=1 count=$length 2>/dev/null)
    echo "$pass"
}

usage()
{
   cat <<EOF

Command line password manager. It stores and retrieves encrypted passwords. It uses asymmetric encryption (public/private SSH keypair).

Usage: $0 [ OPTIONS ]

OPTIONS:

  --name | -n     : alias or name of the password (mandatory)

  --key | -k      : password to be stored or modified under the alias/name passed by --name (optional)
                    if not present, stored password is returned 

  --clip | -c     : copy key to clipboard (deleted after 12s) instead of retrieving it directly

  --generate | -g : generate a random password in the creation of the new key (no --key allowed)

  --script-only   : this key will not apper in the dmenu client (used for unattended scripts)


EXAMPLES:

 Introducing new keys:
   enckeys.sh --key "hello baby is my key" --name mymail
   enckeys.sh --name mypage/user --key "hello baby is my key" 
   enckeys.sh --name mypage/mailpass --key "my mail key!" 
   enckeys.sh --name obscurepage --generate
   enckeys.sh --name sshscript --key admin1234 --script-only

 Retrieving existing keys:
   enckeys.sh --name mymail
   enckeys.sh --name mypage/user
   enckeys.sh --name mypage/user --clip

EOF
   exit 2
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

while [ $# -gt 0 ]; do
   doShift=""
   case "$1" in
      -n|--name)
        name="$2"
        ;;
      -k|--key)
        key="$2"
        ;;
      -c|--clip)
        clip="yes"
        doShift="yes"
        ;;
      -g|--generate)
        gen="yes"
        doShift="yes"
        ;;
      --script-only)
        scriptonly="yes"
        doShift="yes"
        ;;
    esac
    shift
    [ -z $doShift ] && shift  # only make a second shift if we are not in --clip / generate / script-only
done

[ -z $name ] && usage

if [ ! -z $key ]; then
   [ "$gen" = "yes" ] && usage
   _encrypt "$name" "$key" "$scriptonly"
else
   [ "$gen" = "yes" ] && _encrypt "$name" "" "$scriptonly" || _decrypt "$name"
fi

