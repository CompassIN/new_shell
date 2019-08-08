#!/bin/sh

if [ -e /tmp/file.txt ] || [ -e /tmp/env_file.txt ]
then
	rm /tmp/file.txt
	rm /tmp/env_file.txt
fi
for i in `cat list`
do
	echo -e "\n\nResult for $i machine"
	echo  "--------------------"
	nsu_server_admin -s $i -S  > /tmp/file.txt 
	if grep -q running file.txt
	then
		echo "Cmon is running"
	else
		echo "Cmon is not running"
	
	fi
nsu_server_admin -s $i -i -c 'cat /opt/cavisson/monitors/sys/cmon.env' > /tmp/env_file.txt
#if grep -q -x "JAVA_HOME=/apps/java/jdk1.8.0_121" /tmp/env_file.txt
if grep -q -x "JAVA_HOME=/apps/java/jdk1.7.0_71" /tmp/env_file.txt
then	
	echo "correct cmon.env entries "
else
	echo "wrong entries for cmon.env file"
fi
done
echo -e "\n"
