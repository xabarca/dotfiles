#!/bin/sh

PREFIX="new_"
REDUCE_50percent_expression=" -vf scale=trunc(iw/4)*2:trunc(ih/4)*2 "

FFMPEG=/opt/ffmpeg/ffmpeg-master-latest-linux64-gpl/bin/ffmpeg
#FFMPEG=ffmpeg

# ffmpeg -hide_banner -loglevel error -y -i "input.mp4" -movflags +faststart -tune film -preset slower -err_detect ignore_err -c:v libx264 -b:v 200k -b:a 64k -s 1280:720 "output.mp4"

# ffmpeg -i '00. Introduction.mp4' -vf "scale=trunc(iw/4)*2:trunc(ih/4)*2" -c:v libx265 -crf 28 intro_half.mp4


# reduce the resulting video in 50% {high + width)
: "${REDUCE_50:=0}"

FORMAT_VIDEO_ORIGINAL=mp4
MY_FORMAT=mp4
REDUCE_50percent=$REDUCE_50


for i in *.$FORMAT_VIDEO_ORIGINAL ; do 
    case "$i" in
       $PREFIX*) 
           echo "$i already converted !"
           ;;
       *) 
            newname=$( echo "$PREFIX""$i" | sed "s|$FORMAT_VIDEO_ORIGINAL|$MY_FORMAT|" )
            if [ ! -f "$newname" ]; then
                if [ "$FORMAT_VIDEO_ORIGINAL" = "m4v" ]; then
                    ffmpeg -i "$i" -c:v copy -c:a copy "$newname" 
                elif [ "$FORMAT_VIDEO_ORIGINAL" = "mkv" ]; then
                    ffmpeg -i "$i" -c:v copy -c:a copy "$newname" 
                else
                    if [ "$REDUCE_50percent" = "0" ]; then
                        ffmpeg -i "$i" -c:v  libx264 -crf 28 -preset faster "$newname"
                    else
                        ffmpeg -i "$i" $REDUCE_50percent_expression -c:v  libx264 -crf 28 -preset faster "$newname" 
                    fi
                fi
                #echo "$newname"
            fi
            ;;
    esac

done


#for i in `ls *.m4v | grep -v new_`; do 
#    new="new_$i"
#    if [ ! -f "$new" ]; then
#        #ffmpeg -i "$i" -c:v  libx264 -crf 28 -preset faster "$new" 
#        echo "$new"
#    fi
#$done
