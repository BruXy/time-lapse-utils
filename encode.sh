#!/bin/bash
#
# Author: Martin 'BruXy' Bruchanov, bruchy(at)gmail.com
#

####################
# Global variables #
####################

FPS=25 # Output video frame per second rate
TZ='America/Halifax'
FFCAT=/usr/local/bin/ffcat.sh # script for concatenating of video files
DATE=$(TZ=$TZ date +"%Y-%m-%d")
FINAL=Halifax_Harbour_${DATE}.mp4
OUTPUT_DIR=/home/pi-tlv/website

#-----------------------------------#
# Move files to temporary directory #
#-----------------------------------#

FIRST_FILE=$(ls ${DATE}*.jpg | head -n 1)

if [ -z "$FIRST_FILE" ] ; then
       echo "No files to process, exiting..."
       exit
fi

TMP_DIR=${FIRST_FILE/%.jpg/} # also used as output filename
mkdir $TMP_DIR
mv ${DATE}*.jpg $TMP_DIR

#----------------------------#
# Encode images to MP4 video #
#----------------------------#
	
#-vf scale=1280:720 \
#-vf  "crop=1920:1080:512:384" \

( cd $TMP_DIR
  ffmpeg -r $FPS \
	-pattern_type glob \
	-i "*.jpg" \
	-vcodec libx264 \
	-crf 23 \
	-pix_fmt yuv420p \
	../${TMP_DIR}.mp4
)

# Erase temporary directory
rm -rf ${TMP_DIR}

# Join temporary files and publish
$FFCAT -y ${DATE}*.mp4 $OUTPUT_DIR/$FINAL

