#!/bin/bash

# depends: cjxl, imagemagick, exiftool

# generate test images in the current directory
# all images should appear the same if the loader/exiftool are working

# make 2 images for each format
# 1. No metadata
# 2. 90 CW rotation + inverted thumbnail

echo "$0" > info.txt
echo "----" >> info.txt
echo "exiftool v$(exiftool -ver)" >> info.txt
echo "----" >> info.txt
convert --version >> info.txt
echo "----" >> info.txt
heif-enc --version  >> info.txt
echo "----" >> info.txt
cjxl --version >> info.txt

# limited to formats that support EXIF metadata
for ext in jp2 heic jxl webp jpg png tiff avif; do

echo generating $ext...

for i in {1..2}; do
  outFile="img-$(printf '%03d' $i).$ext"
  tmpFile="img-tmp.$ext"
  thumbFile="thumb.jpg"
  rm -fv "$outFile"

  if [ $ext = "jxl" ]; then # imagemagick won't encode jxl
    tmpFile="img-tmp.png"
  fi
  
  note=
  extraArgs=
  if [ $(($i % 2)) -eq 0 ]; then
    note="\n90CW";
    extraArgs="-rotate -90"
  fi

  convert -size 1600x900 \
          -define "gradient:direction=45" "gradient:red-blue" \
          -gravity center \
          -font Ubuntu \
          -pointsize 200 \
          -fill grey \
          -annotate 1x1 "$i\n$ext$note" \
          -fill white \
          -stroke black -strokewidth 1 -draw "rectangle 20,20 220,220 line 20,20 220,220 line 20,220 220,20" \
          -fill black \
          -stroke white -strokewidth 1 -draw "rectangle 1380,0 1580,200 circle 1480,100 1490,10" \
          $extraArgs \
          "$tmpFile" || exit 1
  
  if [ $ext = "jxl" ]; then
    cjxl $tmpFile $outFile;
  else
    cp $tmpFile $outFile;
  fi
  
  if [ $(($i % 2)) -eq 0 ]; then
    convert $tmpFile -negate -resize 160x90 $thumbFile  || exit 2
    quicktime=""
    
    # FIXME: exiftool does not seem to support this unless the file already has metadata
    if [ $ext = "heic" ] || [ $ext = "avif" ]; then
      quicktime="-QuickTime:Rotation=270"
    fi

    exiftool -exif:all= -tagsfromfile @ -all:all '-ThumbnailImage<=thumb.jpg' -Orientation='Rotate 90 CW' $quicktime -overwrite_original $outFile || exit 3
    rm $thumbFile
  fi
  
  rm $tmpFile
  
  #if [ $ext = "jxl" ]; then
  #  cjxl $tmpFile $outFile;
  #  rm $tmpFile
  #else
  #  mv $tmpFile $outFile;
  #fi
  
done
done #extensions

# generate "encapsulated jpg" version of jxl -- this behaves differently
echo generating jxl-wrapped-jpg...
cjxl --lossless_jpeg=1 "img-001.jpg" "img-001.jpg.jxl"
cjxl --lossless_jpeg=1 "img-002.jpg" "img-002.jpg.jxl"
