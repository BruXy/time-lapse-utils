#!/usr/bin/env python
from __future__ import print_function
import ephem
import sys
from datetime import date, datetime, tzinfo, timedelta
from dateutil import tz
from time import strftime, sleep
from os import system, remove
from PIL import Image

# https://picamera.readthedocs.io/en/release-1.12/

####################
# Global variables #
####################

DEBUG       = True
RAM_DISK    = "/mnt/ramdisk"
SLEEP       = 0 
CP_CMD      = "( scp {0} pi-tlv@encoder:/home/pi-tlv ; rm {0} ) &"
TZ_Halifax  = 'America/Halifax'
TZ          = tz.gettz(TZ_Halifax)
SUN         = ephem.Sun()
IMG_NAME    = '{timestamp:%Y-%m-%d-%H%M%S}.jpg'
OFFSET_RISE = -40 # start N minutes earlier
OFFSET_SET  = 40

#Position coordinates for:
#    1505 Barrington Street, Halifax, NS B3J, 44.644557, -63.572071

position     = ephem.Observer()
position.lat = '44.644557'
position.lon = '-63.572071'
position.elevation = 30.0

#############
# Functions #
#############

def get_today(offset_days = 0):
    """ Return today day in format YYYY/MM/DD. 

        @param: offset_days can set tommorow date with +1
    """
    today = datetime.now() + timedelta(days = offset_days)
    today = today.strftime('%Y/%m/%d')

    if DEBUG:
        print("get_today: '{}'".format(today)) 

    return today


def utc2local(ephem_time, time_zone, offset_minutes = 0):
    """Convert time given by ephem.Date() in UTC to the local timezone.

    @param: utc_time date in format '2016/10/25 10:42:56'
    @param: time_zone tz object (tz.gettz)
    @param: offset_minutes +/- number of minutes

    Returns:
        Time stamp in given timezone '2016-10-25 07:42:55.550244-03:00'

    """
    utc = ephem.Date(ephem_time).datetime().replace(tzinfo=tz.gettz('UTC'))
    local = utc.astimezone(TZ)
    local = local + timedelta(minutes = offset_minutes)
    
    if DEBUG:
        print("utc2local: offset '{}'".format(offset_minutes))
        print("utc2local: utc    '{}'".format(utc))
        print("utc2local: local  '{}'".format(local))
 
    return local


def sleep_until_sunrise():
    """Sleep the process until the next day sunrise. """
    position.date = get_today(+1) # TODO - detect if started after 00:00
    tmrw_sunrise = utc2local(position.next_rising(SUN), TZ, OFFSET_RISE)
    seconds = tmrw_sunrise - datetime.now(TZ) 
    seconds = int(seconds.total_seconds()) + 10
    if DEBUG:
	print("sleep_until_sunrise: date = '{}'".format(position.date))
	print("sleep_until_sunrise: tmrw_sunrise = '{}'".format(tmrw_sunrise))
        print("sleep_until_sunrise: '{}'".format(seconds))
    if seconds < 0 or seconds > 24*60*60:
	print("Invalid waiting time!")
	quit(1)
    sleep(seconds) 


def crop_image(filename, w, h, x, y):
    """ Crop image in file 'filename' and save it with the same name.

        @param  x, y top left corner of cropping box
	@param  w, h width and height of cropping box    
    """
    full_img = Image.open(filename)
    crop = full_img.crop((x, y, x+w, y+h))
    crop.save(filename, 'JPEG', quality = 80)


def timelapse(sunrise, sunset):
    """ Control RaspberryPi Camera, exit function when time
        is out of daylight period. 

        @param sunrise datetime.datetime with start
        @param sunset  datetime.datetime with end
    """
    import picamera
    with picamera.PiCamera() as camera:
        camera.resolution = (2592, 1944)
    #   camera.exposure_mode = 'beach'
        camera.awb_mode = 'auto'
        camera.rotation = 180

        camera.start_preview()
       
        for i, filename in enumerate(camera.capture_continuous(RAM_DISK + '/' + IMG_NAME)):   
            time_now = datetime.now(TZ)
            if DEBUG: 
                print("timelapse: ", time_now, " - ", filename)
            if sunrise <= time_now <= sunset:
		crop_image(filename, 1920, 1080, 512, 384)
	  	# Move file to destination
                system(CP_CMD.format(filename))
                sleep(SLEEP)
            else:
                camera.stop_preview()
		remove(filename)
                return
                
########
# Main #
########

while True:
    # Get today day
    position.date = get_today()

    # Compute sunrise and sunset times
    sunrise = utc2local(position.next_rising(SUN), TZ, OFFSET_RISE)
    sunset  = utc2local(position.next_setting(SUN), TZ, OFFSET_SET)
    
    # Snap pictures between given times, if error restart automatically
    try:
        timelapse(sunrise, sunset)
    except:
        print("Unexpected error: ", sys.exc_info()[0])
        continue

    # Sleep until tomorrow sunrise
    sleep_until_sunrise()

