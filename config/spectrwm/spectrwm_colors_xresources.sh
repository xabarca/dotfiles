#!/bin/bash

CONF_FILE=$HOME/.config/spectrwm/spectrwm.conf
TEMPLATE_FILE=$HOME/.config/spectrwm/spectrwm.conf.template

tr_color() {
    color=$($HOME/bin/getcolor $1)
    first=$( echo $color | cut -c 2-3 )
    second=$( echo $color | cut -c 4-5 )
    third=$( echo $color | cut -c 6-7 )
    echo "rgb:$first/$second/$third"
}

change_color() {
    key=$1
    colorList=$2

    # TODO do the stuff here
}


# nomes les linies que estan al template han de ser canviades
# son del tipus:
#   key = valor(s)
# es cercara  per key i llavors es substituira la linia tal-qual esta en el template

while read -r line; do
    #echo "line :: $line"
    #key=$( echo $line | awk '{print $1"\\\t"}' )
    key=$( echo $line | awk '{print $1}' )
    colors=$( echo $line | awk -F'=' '{print $2}' )
    #echo "colors=$colors"

    colorsFinal=""
    IFS=', ' array=($colors)
    for element in "${array[@]}"; 
    do
        #echo " ** $element";
        colorsFinal="$colorsFinal $(tr_color $element),"
    done
    #echo "1 colorsFinal=$colorsFinal"
    len=`expr length "$colorsFinal"`
    len=`expr $len - 1`
    colorsFinal="$( echo "$colorsFinal" | cut -c 1-$len)"
    #echo "2 colorsFinal=$colorsFinal"

    # les keys que tenen [1] no funcionen. Igual s'han d'escapar caracters
    keyModified="$( echo "$key" | sed 's|\[|\\\[|g' )"
    #echo "KEY=$key"

    lineOriginal="$(cat $CONF_FILE | grep "^$keyModified" | grep -v '^#' | head -n 1)"
    lineOriginal="$( echo "$lineOriginal" | sed 's|\[|\\\[|g' )"
    #echo "$lineOriginal"

    lineFinal="$key = $colorsFinal"
    len=`expr length "$lineFinal"`
    len=`expr $len - 1`
    colorsFinal="$( echo "$lineFinal" | cut -c 1-$len)"
    #echo "$lineFinal"

    sed -i "s|$lineOriginal|$lineFinal|g" $CONF_FILE

done < $TEMPLATE_FILE
 
