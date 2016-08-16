#!/bin/bash

#This is a shitty script which downloads a random image from few top posts of /r/earthporn and combines it with genius showerthoughts from /r/showerthoughts 
#to give it a really witty and philosphical look which is really popular nowadays in various social media.
#Hats off to the photographers from /r/earthporn. I do not own any pictures or thoughts. All credits to the photographers from /r/earthporn and geniuses from /r/showerthoughts.
#I am not held liable if anyone uses the iamges generated from this script and gets in legal trouble. Use it at your own risk.
#Images should not be used for commercial purposes, if there is any.

url="http://reddit.com"
img_subreddit="/r/earthporn"
text_subreddit="/r/showerthoughts"
useragent="Mozilla/5.0 (X11; Linux x86_64; rv:50.0) Gecko/20100101 Firefox/50.0"

echo "Starting brain..."
#Download earthporn & showerthoughts subreddit top few posts
wget get --header="Accept: text/html" -U $useragent --no-check-certificate -q  - $url$img_subreddit/.json -O /tmp/tp_earthporn.json
wget get --header="Accept: text/html" -U $useragent --no-check-certificate -q  - $url$text_subreddit/.json -O /tmp/tp_showerthoughts.json


#Filter images URL and titles from the subreddits. Filtering is not perfect right now, but works most of the times
#grep -Po '"url":.*?[^\\]",' /tmp/tp_earthporn.json |cut -f 4 -d '"' > /tmp/tp_earthporn_img
#sed -i -e '/crop/d' -e '1d; n; d' /tmp/tp_earthporn_img
cat /tmp/tp_earthporn.json | python -mjson.tool | grep -A 2 "source" | grep -Po '"url":.*?[^\\]",' | cut -f 4 -d '"' > /tmp/tp_earthporn_img

grep -Po '"title":.*?[^\\]",' /tmp/tp_showerthoughts.json > /tmp/tp_showerthoughts
sed -i -e '1,2d' -e "s/\"title\": \"//g" -e "s/\",//g" -e 's/\\"/\"/g' /tmp/tp_showerthoughts

#grep -Po '"author":.*?[^\\]",' /tmp/tp_earthporn.json > /tmp/tp_earthporn_author
#sed -i -e '1d' -e 's/\"author\": "//g' -e 's/\",//g' /tmp/tp_earthporn_author
cat /tmp/tp_earthporn.json | python -mjson.tool | grep -Po '"author":.*?[^\\]",' | cut -f 4 -d '"' | sed '1d' > /tmp/tp_earthporn_author

echo "Counting sheeps..."
#Count how many lines are there in each files
img_count=`cat /tmp/tp_earthporn_img | wc -l`
txt_count=`cat /tmp/tp_showerthoughts | wc -l`

#Pick random image and random thoughts
img_number=$(( ( RANDOM % $img_count )  + 1 ))
txt_number=$(( ( RANDOM % $txt_count )  + 1 ))


img_url=`sed "${img_number}q;d" /tmp/tp_earthporn_img`
text=`sed "${txt_number}q;d" /tmp/tp_showerthoughts`
credits=`sed "${img_number}q;d" /tmp/tp_earthporn_author`
caption="Photo Credits: /u/$credits"

echo "Thinking something creative.... few moments"
wget $img_url -q -O /tmp/tp_image.png
img_res=`identify /tmp/tp_image.png | awk '{print $3}'`
img_width=`echo $img_res | awk -Fx '{print $NR}'`
img_height=`echo $img_res | awk -Fx '{print $NF}'`
txt_height=$(($img_height/15))
author_height=$(($img_height/70))

echo "Giving life to thoughts...."
convert -background '#0009' -fill silver -size ${img_width}x$txt_height -gravity Center caption:"$text" /tmp/tp_caption.png
convert -background '#0009' -fill silver -size ${img_width}x$author_height -gravity southeast caption:"$caption" /tmp/tp_author.png
composite /tmp/tp_caption.png /tmp/tp_image.png -gravity center /tmp/final_tp.png
composite /tmp/tp_author.png /tmp/final_tp.png -gravity southeast /tmp/final_tp.png
firefox /tmp/final_tp.png
echo "Done. Please check your browser (firefox)"
#rm -rf /tmp/tp_*
