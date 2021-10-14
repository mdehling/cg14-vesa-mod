#!/bin/ksh

command -v tokenize >/dev/null || { echo "tokenize not found"; exit 1; }
command -v awk >/dev/null || { echo "awk not found"; exit 1; }

tokenize -n -8 ss20-cg14-vesa.fth || { echo "tokenize error"; exit 1; }

MAX_SIZE=`ls -l ss20-cg14.fcode | awk '{print $5}'` || { echo "awk error"; exit 1; }
SIZE=`ls -l ss20-cg14-vesa.fcode | awk '{print $5}'` || { echo "awk error"; exit 1; }


echo "fcode size is ${SIZE}b, original was ${MAX_SIZE}b."

if [ "$MAX_SIZE" -ne "50108" ]; then
	echo "unexpected value for size of original ss20-cg14.fcode, aborting."
	exit 1
elif [ "$SIZE" -gt "$MAX_SIZE" ]; then
	echo "\nfcode too large, aborting."
	exit 1
else
	echo "\npatching 'ss20-2.25-vesa.bin'..."
	cp ss20-2.25.bin ss20-2.25-vesa.bin
	dd if=ss20-cg14-vesa.fcode bs=1 seek=190080 conv=notrunc \
		of=ss20-2.25-vesa.bin

	echo "\npatching 'ss20-2.25r-vesa.bin'..."
	cp ss20-2.25r.bin ss20-2.25r-vesa.bin
	dd if=ss20-cg14-vesa.fcode bs=1 seek=202824 conv=notrunc \
		of=ss20-2.25r-vesa.bin
fi
