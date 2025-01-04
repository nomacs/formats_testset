#!/bin/bash

# depends: ffmpeg,imagemagick

# generate test images in the current directory
# all pixel formats supported by ffmpeg (ffmpeg -h encoder=png)

echo "$0" > info.txt
echo "----" >> info.txt
convert --version >> info.txt
echo "----" >> info.txt
ffmpeg  -version >> info.txt

note=
extraArgs=

tmpFile=rgb-64bit.png

convert -size 1600x900 \
        -depth 64 \
        -colors $((2**64)) \
        -define "gradient:direction=SouthEast" "gradient:magenta-cyan" \
        -fill white \
        -stroke black -strokewidth 1 -draw "rectangle 20,20 220,220 line 20,20 220,220 line 20,220 220,20" \
        -fill black \
        -stroke white -strokewidth 1 -draw "rectangle 1380,0 1580,200 circle 1480,100 1490,10" \
        $extraArgs \
        "$tmpFile" || exit 1

i=0;
for pixFmt in monob gray ya8 gray16be ya16be pal8 rgb24 rgba rgb48be rgba64be; do

  i=$((i+1))
  outFile="$(printf '%03d' $i).opaque.$pixFmt.png"
  rm -fv "$outFile"

  echo generating $outFile...
  
  ffmpeg -loglevel warning -i "$tmpFile" -c:v png -pred 5 -frames:v 1 -update true -pix_fmt "$pixFmt" "$outFile" || exit 2
done

rm "$tmpFile"

tmpFile=rgba-64bit.png
rm -f "$tmpFile"

convert -size 1600x900 \
        -depth 64 \
        -colors $((2**64)) \
        -define "radial-gradient" "radial-gradient:cornflower blue-#00000000" \
        -fill white \
        -stroke black -strokewidth 1 -draw "rectangle 20,20 220,220 line 20,20 220,220 line 20,220 220,20" \
        -fill black \
        -stroke white -strokewidth 1 -draw "rectangle 1380,0 1580,200 circle 1480,100 1490,10" \
        $extraArgs \
        "$tmpFile" || exit 1

for pixFmt in ya8 ya16be rgba rgba64be; do

  i=$((i+1))
  outFile="$(printf '%03d' $i).transparent.$pixFmt.png"
  rm -fv "$outFile"

  echo generating $outFile...
  
  ffmpeg -loglevel warning -i "$tmpFile" -c:v png -pred 5 -frames:v 1 -update true -pix_fmt "$pixFmt" "$outFile" || exit 2
done

rm "$tmpFile"


tmpFile=rgba-8bit.png
rm -f "$tmpFile"

convert -size 1600x900 xc:transparent \
        -depth 8 \
        -colors $((2**64)) \
        -fill "cornflower blue" \
        -draw "circle 800,450 600,250" \
        -fill white \
        -stroke black -strokewidth 1 -draw "rectangle 20,20 220,220 line 20,20 220,220 line 20,220 220,20" \
        -fill black \
        -stroke white -strokewidth 1 -draw "rectangle 1380,10 1580,210 circle 1480,110 1490,20" \
        $extraArgs \
        "$tmpFile" || exit 1

for pixFmt in ya8 ya16be pal8 rgba rgba64be; do

  i=$((i+1))
  outFile="$(printf '%03d' $i).colorkey.$pixFmt.png"
  rm -fv "$outFile"

  echo generating $outFile...
  
  ffmpeg -loglevel warning -i "$tmpFile" -c:v png -pred 5 -frames:v 1 -update true -pix_fmt "$pixFmt" "$outFile" || exit 2
done

rm $tmpFile
