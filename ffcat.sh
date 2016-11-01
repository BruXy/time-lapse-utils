#!/bin/bash
#
#
#
TMP_FILE=/tmp/.ffcat-$$.txt

function print_help() {
cat << EOF

Usage:
	$0 [file1 file2 file3... ] output

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

file_list=( $@ )
last=${file_list[-1]}
ifexist "$last"

# put file list
for ((i = 0; i < $[${#file_list[@]} - 1]; i++))
do
	filename="$PWD/${file_list[$i]}"
	if [ -f $filename ] ; then
		echo "file '$filename'"
	else
		echo "$0: file '$filename' not found!" >&2
	fi
done > $TMP_FILE 

ffmpeg -f concat -i $TMP_FILE -codec copy $last

rm -f $TMP_FILE

