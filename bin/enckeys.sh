#! /bin/sh

# -------- notes of encrypt - decrypt with SSH keys lab ---------
#
#  # generate a keyfile (example string to be encrypted)
#  openssl rand -base64 40 > password.txt
#  
#  # generate a PEM key-pair ssh keys
#  ssh-keygen -t rsa -b 4096 -m PEM -f ./name_key -P ''
#  
#  # encrypt the key.bin keyfile with public key
#  openssl rsautl -encrypt -oaep -pubin -inkey <(ssh-keygen -e -f name_key.pub -m PKCS8) -in password.txt -out encrypted_pass.enc
#  
#  # decrypt the secret.key.enc using private key
#  openssl rsautl -decrypt -oaep -inkey name_key -in encrypted_pass.enc -out password.txt
#  

# TODO - use same folder for different modes (enchive, age....) and only change file extensions to differenciate between them.
# TODO - use scripts is necessary? Or cant be packed in a folder scripts separetely...

FOLDER_STORE_KEYS=$HOME/.enckeys
FOLDER_STORE_KEYS_ECC=$HOME/.ecckeys
KEY_PRIVATE=~/.ssh/xavi
KEY_PUBLIC=~/.ssh/xavi.pub
ECC_KEY_PRIVATE=~/.config/enchive/enchive.sec
ECC_KEY_PUBLIC=~/.config/enchive/enchive.pub

PADDING="-pkcs" 
CLIPBOARD_CMD="xsel -ib"
APPENDIX_KEYS="enc"
APPENDIX_SCRIPT_KEYS="_scr"
ECC_MODE=0


# usage:  _enc_passwd  plaintext_pass  encrypted_file
_enc_passwd() {
   pass=$1
   encrypted=$2 
   # encrypt keyfile with public key and remove non-encrypted keyfile
   if [ $ECC_MODE -eq 0 ]; then
      ssh-keygen -e -f "$KEY_PUBLIC" -m PKCS8 > /tmp/pubkey
      openssl rsautl -encrypt "$PADDING" -pubin -inkey /tmp/pubkey -out "$encrypted" <<-EOF &&
$pass
EOF
      rm /tmp/pubkey
      printf "New key added.\n"
   else
      enchive -p $ECC_KEY_PUBLIC archive /dev/stdin "$encrypted" <<-EOF &&
$pass
EOF
      printf "New key added.\n"
   fi 
}

# usage: _dec_passwd  encrypted_file 
_dec_passwd() {
   encrypted_file="$1" 
   # decrypt the keyfile using our private key
   if [ $ECC_MODE -eq 0 ]; then
      decrypted=$( openssl rsautl -decrypt $PADDING -inkey "$KEY_PRIVATE" -in "$encrypted_file" )
   else
      decrypted=$(enchive -s $ECC_KEY_PRIVATE --agent=13000 --pinentry=pinentry-gnome3 extract "$encrypted_file" /dev/stdout )
   fi
   echo "$decrypted"
}

# usage:  _encrypt  cadena  alias
_encrypt() {
   alias="$1"
   pass="$2"

   [ $ECC_MODE -eq 1 ] && FOLDER_STORE_KEYS=$FOLDER_STORE_KEYS_ECC

   [ -z $pass ] && pass="$(generatePassword)"
   destEncFile="$FOLDER_STORE_KEYS/$alias"".$APPENDIX_KEYS"
   [ "$scriptonly" = "yes" ] && destEncFile="$destEncFile""$APPENDIX_SCRIPT_KEYS"

   case "$alias" in 
      */*)
         newpath="$(echo "$alias" | awk -F'/' '{print $1}')"
         mkdir -p "$FOLDER_STORE_KEYS/$newpath"
         ;;
   esac
   _enc_passwd  "$pass"  "$destEncFile"
   exit 0
}

# usage:  _decrypt  alias
_decrypt() {
    if [ ! -f "$KEY_PRIVATE" ]; then
        herbe -c "no private key available" &
        echo "no private key available"
        exit 0
    fi
    
    alias="$1"
    #  xsel -ib  -> copy to clibboard
    #  xsel -cb  -> clear clibboard

    [ $ECC_MODE -eq 1 ] && FOLDER_STORE_KEYS=$FOLDER_STORE_KEYS_ECC

    enc_key_file="$FOLDER_STORE_KEYS/$alias"".$APPENDIX_KEYS"
    [ ! -f "$enc_key_file" ] && enc_key_file="$enc_key_file""$APPENDIX_SCRIPT_KEYS"
    [ ! -f "$enc_key_file" ] && echo "no key" && exit 0

    decrypted="$( _dec_passwd "$enc_key_file" )"

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

_dmenu() {
   COLOR=$( $HOME/bin/getcolor color4 )
   COLOR_BG=$( $HOME/bin/getcolor bg )
   COLOR_OPTIONS="-nb $COLOR_BG -sb $COLOR -sf $COLOR_BG -nf $COLOR"
   msg1="Choose your key: "

   ECC_MODE=1
   clip=yes
   cd $HOME
   list=$(find .ecckeys -type f -name *.enc | sed -e 's|.ecckeys/||' -e 's/.enc//')

   target=$( printf "$list" | dmenu -i -c -l 8 -bw 2 -p "$msg1" $COLOR_OPTIONS)
   [ -z $target ] && exit 0
   verification=$(echo $list | grep $target | wc -l)
   [ $verification -eq 0 ] && exit 0

   _decrypt "$target" 
   herbe "password copied to clipboard" &
}

generatePassword() {
   # another options: 
   # dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev 
   # openssl rand -base64 20 

    charsAllowed="A-Z-a-z-0-9_-"
    length=30
    pass=$(LC_ALL=C tr -dc "$charsAllowed" 2>/dev/null < /dev/urandom |
            dd ibs=1 obs=1 count=$length 2>/dev/null)
    echo "$pass"
}

_usage() {
   cat <<EOF

Command line password manager. It stores and retrieves encrypted passwords. It uses asymmetric encryption (public/private SSH keypair or an ECC keypair).

Usage: $0 [ OPTIONS ]

OPTIONS:

  --name | -n     : alias or name of the password (mandatory)

  --key | -k      : password to be stored or modified under the alias/name passed by --name (optional)
                    if not present, stored password is returned 

  --clip | -c     : copy key to clipboard (deleted after 12s) instead of retrieving it directly

  --generate | -g : generate a random password in the creation of the new key (no --key allowed)

  --script-only   : this key will not appear in the dmenu client (used for unattended scripts)

  --ecc           : use ECC (elliptic curve cryptography) mode (false by default)

  --dmenu         : open a dmenu client to select & clip a key


EXAMPLES:

 Introducing new keys:
   enckeys.sh --key "hello baby is my key" --name mymail
   enckeys.sh --name mypage/user --key "hellobaby_is_my_key" 
   enckeys.sh --name mypage/mailpass --key "my_mail_key!" 
   enckeys.sh --name fastmail/bob --generate
   enckeys.sh --ecc --name fastmail/alice --key qawsedrf17
   enckeys.sh --name sshscript --key admin1234 --script-only

 Retrieving existing keys:
   enckeys.sh --name mymail --ecc
   enckeys.sh --name mypage/user
   enckeys.sh --name mypage/user --clip

 Open dmenu client:
   enckeys.sh --dmenu

EOF
   exit 2
}


_main() {
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
         --ecc)
            ECC_MODE=1
            doShift="yes"
            ;;
         --dmenu)
            dmenuclient=yes
            ECC_MODE=1
            clip=yes
            doShift="yes"
            ;;
         -h|--h|--help)
            _usage
            ;;
      esac
      shift
      [ -z $doShift ] && shift  # only make a second shift if we are not in --clip / generate / script-only / ecc
   done

   [ ! -z $dmenuclient ] && _dmenu 
   [ -z $name ] && _usage

   if [ ! -z $key ]; then
      [ "$gen" = "yes" ] && _usage
         _encrypt "$name" "$key"
   else
      [ "$gen" = "yes" ] && _encrypt "$name" || _decrypt "$name"
   fi
}

main2 () {
# name  key  clip  generate  script-only  ecc  dmenu 

# [a] add
# [g] get
# [s] mark as script
# [e] ecc mode
# [d] dmenu

   while getopts a:g:sed opt
      do case "$opt" in
         a) name="$OPTARG" opcio=add ;;
         g) name="$OPTARG" opcio=get ;;
         s) name="$OPTARG" opcio=script ;;
         e) ECC_MODE=1 ;;
	     m) _dmenu ;;
         *) _usage ;;
	  esac
   done

# [n]name
# [k]key
# [c]lip 
# [g]enerate
# [s]cript-only
# [e]cc
# [d]menu
   while getopts n:k:cgsed opt
      do case "$opt" in
         n) name="$OPTARG" ;;
         k) key="$OPTARG" ;;
         c) clip="yes" ;;
         g) gen="yes" ;;
         s) scriptonly="yes" ;;
         e) ECC_MODE=1 ;;
	     m) _dmenu ;;
         *) _usage ;;
	  esac
   done

   [ -z $name ] && _usage

}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#- - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Ensure that debug mode is never enabled to
# prevent the password from leaking.
set +x

# Ensure that globbing is globally disabled
# to avoid insecurities with word-splitting.
set -f 

[ "$1" ] || _usage && _main "$@"
