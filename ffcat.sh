#!/bin/bash
#
#
#
TMP_FILE=/tmp/.ffcat-$$.txt
OVERWRITE='' 

function print_help() {
cat << EOF

Usage:
	$0 [-y] [file1 file2 file3... ] output

	-y ... Overwrite output file without asking
EOF
}

function ifexist() {
	if [ -f "$1" ] 
	then
		printf "$0: overwrite ‘$1’? " >&2
		read input
		[[ $input != 'y' ]] && exit 0
	fi
}

if [ $# -le 1 ] 
then
	print_help
	exit 1
fi

# Check if overwrite is invoked
if [[ $1 == '-y' ]] 
then
	OVERWRITE='-y'
	shift
fi

file_list=( $@ )
last=${file_list[-1]}
[ -z $OVERWRITE ] && ifexist "$last"

# Create a file list, do not include the last file (result)
for i in ${file_list[*]} 
do
	filename="$PWD/$i"
	if [ -f $filename ] && [[ $i != $last ]]  ; then
		echo "file '$filename'"
	else
		[ $i != $last ] && echo "$0: file '$filename' not found!" >&2
	fi
done > $TMP_FILE 

# Concatenate video files
ffmpeg $OVERWRITE -f concat -i $TMP_FILE -codec copy $last

rm -f $TMP_FILE

