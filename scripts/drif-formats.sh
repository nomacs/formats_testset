#!/bin/bash

W=$1
H=$2
IN=$3

echo "$0 $@" > info.txt
echo "----" >> info.txt
ffmpeg -version >> info.txt

FFARGS="-loglevel error"

# planar bgr24
# ffmpeg only outputs gbrp, swap g/b to get brgp
fmt=bgrp
ffmpeg $FFARGS -i "$IN" -pix_fmt gbrp -vf "colorchannelmixer=gg=0:gb=1:bb=0:bg=1" -f rawvideo -y "$IN.$fmt.raw" || exit 1
"$(dirname $0)/raw2drif/raw2drif" $W $H $fmt "$IN.$fmt.raw" "$IN.$fmt.drif"  || exit 2
rm "$IN.$fmt.raw" || exit 3

# planar bgra32
# ffmpeg only outputs gbrp, swap g/b to get brgap
fmt=bgrap
ffmpeg $FFARGS -i "$IN" -pix_fmt gbrap -vf "colorchannelmixer=gg=0:gb=1:bb=0:bg=1" -f rawvideo -y "$IN.$fmt.raw" || exit 1
"$(dirname $0)/raw2drif/raw2drif" $W $H $fmt "$IN.$fmt.raw" "$IN.$fmt.drif"  || exit 2
rm "$IN.$fmt.raw" || exit 3

# planar rgb24
# ffmpeg only outputs gbrp, swap to get rgbp
fmt=rgbp
ffmpeg $FFARGS -i "$IN" -pix_fmt gbrp -vf "colorchannelmixer=rr=0:rb=1:gg=0:gr=1:bb=0:bg=1" -f rawvideo -y "$IN.$fmt.raw" || exit 1
"$(dirname $0)/raw2drif/raw2drif" $W $H $fmt "$IN.$fmt.raw" "$IN.$fmt.drif"  || exit 2
rm "$IN.$fmt.raw" || exit 3

# planar rgba32
# ffmpeg only outputs gbrp, swap to get rgbap
fmt=rgbap
ffmpeg $FFARGS -i "$IN" -pix_fmt gbrap -vf "colorchannelmixer=rr=0:rb=1:gg=0:gr=1:bb=0:bg=1" -f rawvideo -y "$IN.$fmt.raw" || exit 1
"$(dirname $0)/raw2drif/raw2drif" $W $H $fmt "$IN.$fmt.raw" "$IN.$fmt.drif"  || exit 2
rm "$IN.$fmt.raw" || exit 3


for fmt in rgb24 bgr24 yuv420p rgba bgra nv21 nv12 gray; do
  ffmpeg $FFARGS -i "$IN" -pix_fmt $fmt -f rawvideo -y "$IN.$fmt.raw" || exit 1
  "$(dirname $0)/raw2drif/raw2drif" $W $H $fmt "$IN.$fmt.raw" "$IN.$fmt.drif"  || exit 2
  rm "$IN.$fmt.raw" || exit 3
done

