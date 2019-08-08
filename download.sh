#!/bin/sh



if [ -f index.html ]

then
	rm -f index*
fi
#echo -e "\nPlease enter the URL:-\n"
#read web
wget -O index.html  -q $1

#FOR Macys
#out=`grep -m 1 "release" index.html | cut -c 10-12`
#FOR Cavisson
out=`grep -m 1 performance index.html | cut -d '=' -f 1`

if [ -z "$out" ]
then
	echo "OOPS!!String not found.."
else 
	echo -e "$out\n"
fi
exit $?
