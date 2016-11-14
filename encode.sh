#!/bin/bash
# Read input files sequence
START=$(ls *.jpg | head -n 1)
if [ -z $START ] ; then
	echo "No files to process, exiting..."
	exit
fi

END=$(ls *.jpg | tail -n 1)
# Remove extension, keep just a number
START=${START%.jpg}
END=${END%.jpg}
# -----------------------------------------------------------------------------

####################
# Global variables #
####################

FPS=25 # Output video frame per second rate
TZ='America/Halifax'
FFCAT=/usr/local/bin/ffcat.sh
DATE=$(TZ=$TZ date +"%Y-%m-%d")
FINAL=Halifax_Harbour_${DATE}.mp4
OUTPUT_DIR=/home/pi-tlv/website

# set 10-base because of leading zeros
printf -v OUT "%s-%06d-%06d" $DATE  $[10#$START] $[10#$END]

#echo $START $END $OUT

# Move files to temporary directory
mkdir $OUT

for i in $(seq $START $END) 
do
	printf -v n '%06d.jpg' $i
#	if [ -f $n ] ; then
		mv $n $OUT/
#	fi
done
	
#-vf scale=1280:720 \
#-vf  "crop=1920:1080:512:384" \

( cd $OUT
  ffmpeg -r $FPS \
	-pattern_type glob \
	-i "*.jpg" \
	-vcodec libx264 \
	-crf 23 \
	-pix_fmt yuv420p \
	../${OUT}.mp4
   rm -rf ../${OUT}
)

# Join temporary files and publish
$FFCAT -y ${DATE}*.mp4 $OUTPUT_DIR/$FINAL

