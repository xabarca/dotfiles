#!/bin/sh

. ~/bin/encpass.sh
PASSWORD=$( get_secret byethost ftp )

HOST=ftp.byethost4.com
USER=b4_30540675
LOCAL_PATH=/tmp

ftp -inv $HOST <<EOF
user $USER $PASSWORD
lcd $LOCAL_PATH
cd htdocs
mput *
bye
EOF

