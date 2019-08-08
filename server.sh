#!/bin/sh

cat /etc/cav_controller.conf | cut -d '|' -f 1 | tail -n +2 > /tmp/con.txt
cat /etc/cav_controller.conf | cut -d '|' -f 5 | tail -n +2 > /tmp/dir.txt
j=1
for i in `cat con.txt`
do
	port=443$j
	echo "----------------------------"
	dir=`sed -n "$j"p dir.txt`
        l_num=`grep -n -m 1 "redirectPort=" $dir/conf/server.xml.bak | cut -d ':' -f 1`
        sed -i "$l_num s/.*./redirectPort=$port\/>/" $dir/conf/server.xml.bak

        cl_num=`grep -n -m 1 "Connector port=" list.txt | cut -d '"' -f 2`
        sed -i "1 s/$cl_num/$port/" list.txt

        sed -i -e '/redirectPort=/r list.txt' $dir/conf/server.xml.bak
	j=`expr $j + 1 `
	echo $j
done
