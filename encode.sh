#!/bin/bash
FPS=24
START=$(ls *.jpg | head -n 1)
END=$(ls *.jpg | tail -n 1)
# Remove extension, keep just a number
START=${START%.jpg}
END=${END%.jpg}

# set 10-base because of leading zeros
printf -v OUT "%s-%06d-%06d" $(date +"%Y-%m-%d") $[10#$START] $[10#$END]

#echo $START $END $OUT

mkdir $OUT

for i in $(seq $START $END) 
do
	printf -v n '%06d.jpg' $i
#	if [ -f $n ] ; then
		mv $n $OUT/
#	fi
done
	
#-vf scale=1280:720 \
#-vf crop=1920:1080:512:384 \

cd $OUT
ffmpeg -r $FPS \
	-pattern_type glob \
	-i "*.jpg" \
	-vcodec libx264 \
	-crf 23 \
	-pix_fmt yuv420p \
	../${OUT}.mp4

echo rm -rf ${OUT}
