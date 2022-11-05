#!/bin/sh

URL=https://chessmood.com/course/opening-principles

DATE_SUFIX="$(date +'%Y-%m-%d_%H.%M.%S')"
LOGFILE="/tmp/backup-log-""DATE_SUFIX"".log"

FFMPEG=/opt/ffmpeg/ffmpeg-master-latest-linux64-gpl/bin/ffmpeg

BASE_PATH="/tmp/""$DATE_SUFIX""_chessmood"
COOKIES_FILE=$BASE_PATH/cookies
FILE=$BASE_PATH/links.txt
FILE_AUDIO=$BASE_PATH/audio.txt
FILE_VIDEO=$BASE_PATH/video.txt

mkdir -p $BASE_PATH
cd $BASE_PATH


if [ ! -z "$1" ]; then
   URL="$1"
fi

# get the cookie from FIREFOX
# $HOME/bin/cookiefire > $COOKIES_FILE

# get the cookies from a chessmood.com scrap usinhg python 
# internally, the python scripts saves the cookie file as "./cookies"
python3 $HOME/bin/chessmood_scraper.py

# curl -c : creates cookie
# curl -b : uses the cookie
#curl -c "$COOKIES_FILE" -u "canadianclubxxx@gmail.com:mypassword" https://chessmood.com/login

curl -b "$COOKIES_FILE" $URL > /tmp/page.html
#curl --cookie "chessmood_session=$COOKIE" $URL > page2.html

lynx -dump /tmp/page.html | grep episode  | grep https | awk '{print $2}' | grep -v overview > $FILE


while read -r line; do
   yt-dlp --cookies "$COOKIES_FILE" $line  
   #yt-dlp --cookies-from-browser firefox $line 
done < $FILE

#rm *.temp.mp4
#rm $FILE_AUDIO
#rm $FILE_VIDEO

#for i in "$(ls *.m4a)"; do
#   echo "$i" >> $FILE_AUDIO
#done

#for i in "$(ls *.mp4)"; do
#   echo "$i" >> $FILE_VIDEO
#done

#for n in $(seq 1 $(cat $FILE_AUDIO | wc -l)); do
#   audio="$(sed "${n}q;d" $FILE_AUDIO)"
#   video="$(sed "${n}q;d" $FILE_VIDEO)"
#   position=$( echo "$audio" | grep -b -o '\[' | awk 'BEGIN {FS=":"}{print $1}' )
#   outname="final_""$(echo "$audio" | cut -c 1-$position )"".mp4"
#   ffmpeg -i "$video" -i "$audio" -c:v copy -c:a aac "$outname"
#done


REDUCE_50percent_expression=" -vf scale=trunc(iw/4)*2:trunc(ih/4)*2 "
for i in *.mp4; do
    newname="new_$i"
    $FFMPEG -i "$i" $REDUCE_50percent_expression -c:v  libx264 -crf 28 -preset faster "$newname"
    rm "$i"
done


