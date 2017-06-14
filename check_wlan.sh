#!/bin/bash
# 
# Check if Power Managment on given network interface is enabled,
# and disable it eventually.
#

# Interface
IFACE=wlan0

function disable_pm() {
	echo "Disabling $IFACE power management."
	sudo iwconfig $IFACE power off
}

function get_pm_state() {
	state=$(iwconfig $IFACE | sed -ne '/Power Management/s/.*:\(.*\)/\1/p')
	echo "Current Power Managment state is: $state."			
	if [[ "$state" != "off" ]]
	then
		return 1
	else
		return 0
	fi
}

#####################
# Check and disable #
#####################

get_pm_state && exit || disable_pm
get_pm_state

