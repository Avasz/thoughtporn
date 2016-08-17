#!/bin/bash

#This is a shitty script which downloads a random image from 100 top posts of the week in /r/earthporn and combines it with genius showerthoughts from /r/showerthoughts 
#to give it a really witty and philosphical look which is really popular nowadays in various social media.
#Hats off to the photographers from /r/earthporn. I do not own any pictures or thoughts. All credits to the photographers from /r/earthporn and geniuses from /r/showerthoughts.
#I am not held liable if anyone uses the iamges generated from this script and gets in legal trouble. Use it at your own risk.
#Images should not be used for commercial purposes, if there is any.
#Avasz <avashmulmi at gmail.com>


#Internte part
url="http://reddit.com"
img_subreddit="/r/earthporn"
text_subreddit="/r/showerthoughts"
useragent="Mozilla/5.0 (X11; Linux x86_64; rv:50.0) Gecko/20100101 Firefox/50.0"
WGET="wget get --header=\"Accept: text/html\" -U $useragent --no-check-certificate -q"
tojson="python -mjson.tool"

#Local Part
DIRECTORY="$HOME/.thoughtporn"

echo "Activating Brain..."

#Check if Thoughtporn directory exists or not, if not then create it.

#Download earthporn & showerthoughts subreddit top few posts
function download {
    echo "Recharging Brain..."
    $WGET - "$url$img_subreddit/top.json?sort=top&t=week&limit=100" -O /tmp/tp_earthporn.json
    $WGET - "$url$text_subreddit/top.json?sort=top&t=week&limit=100" -O /tmp/tp_showerthoughts.json
    cat /tmp/tp_earthporn.json | $tojson | grep -A 2 "source" | grep -Po '"url":.*?[^\\]",' | cut -f 4 -d '"' > $DIRECTORY/tp_earthporn_img
    cat /tmp/tp_earthporn.json | $tojson | grep -Po '"author":.*?[^\\]",' | cut -f 4 -d '"' > $DIRECTORY/tp_earthporn_author
    cat /tmp/tp_showerthoughts.json | $tojson | grep -Po '"title":.*?[^\\]",' | sed -e "s/\"title\": \"//g" -e "s/u2019/\'/g" -e "s/\",//g" -e 's/\\"/\"/g' > $DIRECTORY/tp_showerthoughts
}

#Count how many lines are there in each files, should be 100 by default, but just in case.
function count {
    echo "Counting sheeps.."
    img_count=`cat $DIRECTORY/tp_earthporn_img | wc -l`
    txt_count=`cat $DIRECTORY/tp_showerthoughts | wc -l`
}

#Pick random image and random thoughts
function random {
    img_number=$(( ( RANDOM % $img_count )  + 1 ))
    txt_number=$(( ( RANDOM % $txt_count )  + 1 ))
    img_url=`sed "${img_number}q;d" $DIRECTORY/tp_earthporn_img`
    credits=`sed "${img_number}q;d" $DIRECTORY/tp_earthporn_author`
    text=`sed "${txt_number}q;d" $DIRECTORY/tp_showerthoughts`
}



#echo "Thinking something creative..."

function imagework {
    echo "Thinking something creative..."
    wget $img_url -q -O /tmp/tp_image.png
    img_res=`identify /tmp/tp_image.png | awk '{print $3}'`
    img_width=`echo $img_res | awk -Fx '{print $NR}'`
    img_height=`echo $img_res | awk -Fx '{print $NF}'`
    txt_height=$(($img_height/15))
    author_height=$(($img_height/40))
    caption="Photo Credits: /u/$credits"
}

#echo "Giving life to thoughts...."
#convert -background '#0009' -fill silver -size ${img_width}x$txt_height -gravity Center caption:"$text" /tmp/tp_caption.png
#convert -background '#0009' -fill silver -size ${img_width}x$author_height -gravity northwest caption:"Generated Using: http://github.com/avasz/thoughtporn" -gravity southeast caption:"$caption" /tmp/tp_author.png
#composite /tmp/tp_caption.png /tmp/tp_image.png -gravity center /tmp/final_tp.png
#composite /tmp/tp_author.png /tmp/final_tp.png -gravity southeast /tmp/final_tp.png

function work {
    echo "Painting my thoughts..."
    convert /tmp/tp_image.png \
        -background '#0009' -fill silver -size ${img_width}x$txt_height \
        caption:"$text" -gravity center -compose over -composite \
        -background '#0008' -fill silver -size ${img_width}x$author_height \
        caption:"$caption" -gravity northeast -compose over -composite \
        -background '#0008' -fill silver -size ${img_width}x$(($author_height-5)) \
        caption:"Generated using: https://github.com/avasz/thoughtporn" -gravity southeast -compose over -composite \
        /tmp/final_tp.png
}
if [ ! -d "$DIRECTORY" ]
then
    mkdir -p $DIRECTORY
fi

find $DIRECTORY -mtime +2 -exec rm {} \;

if [ ! "$(ls -A $DIRECTORY)" ]; then
    download
fi
count
random
imagework
work
mogrify -resize 1920x1080 /tmp/final_tp.png
firefox /tmp/final_tp.png
echo "Done. Please check your browser (firefox)"
#rm -rf /tmp/tp_*
