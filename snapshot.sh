#!/bin/bash
#
# Create Raspberry Pi time-lapse snap shots and copy them
# for further processing via SSH.
#
# Author: Martin Bruchanov bruchy(at)gmail.com
#
# Limitations:
# - raspistill initialize and deinitialize PiCamera subsystem
#   everytime it is called, the frame ratio is around 1 frame
#   per 8 seconds.
# 

TIME_OUT=0 #seconds
OUTDIR=/mnt/ramdisk # local filesystem for temporary storage
REMOTE=/home/pi-tlv/$(date +"%Y%m%d")
CROP=1920x1080+512+384 # Width x Height + x + y 
CTRLC=0
SSH_HOST=pi-tlv@encoder

trap "printf '\nCtrl-C pressed, exiting...'; CTRLC=1" SIGINT 

ssh $SSH_HOST "mkdir $REMOTE"

i=0
while true
do
	DATE=$(date +"%Y-%m-%d_%H%M%S")
	OUT_BASENAME=$OUTDIR/$DATE
	printf -v OUT_FRAME "$OUTDIR/%06d.jpg" $i
	raspistill -e bmp -o - -rot 180 --nopreview --exposure auto --timeout 1 | \
	gm convert bmp:- -verbose \
		-set comment "$DATE" \
		-crop $CROP JPG:$OUT_FRAME
	scp $OUT_FRAME $SSH_HOST:$REMOTE
	rm -f ${OUTDIR}/*.jpg
	sleep $TIME_OUT
	if [ $CTRLC -eq 1 ] 
	then
		exit
	fi
	: $[i++]
done

