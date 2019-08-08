#!/bin/sh

#################################################################
#                                                               #
#                                                               #       
###        --script to change the server.xml for https---     ###       
#                                                               #
#                                                               #
#                                                               #
#################################################################

usage () {
echo -e "To make changes in the server.xml and web.xml for https redirection\n"
echo -e "To run this shell you need to be a root user\n"
echo -e "Run the shell from the /tmp directory.& You should have the list.txt file and list_web.txt file\n"
echo -e "list.txt file contains the changes to be made in server.xml\n"
echo -e "list_web.txt file contains the changes to be made in web.xml\n"
echo -e "It also starts the tomcat from the user specified controller\n"
}

cat /etc/cav_controller.conf | cut -d '|' -f 1 | tail -n +2 > /tmp/con.txt
cat /etc/cav_controller.conf | cut -d '|' -f 5 | tail -n +2 > /tmp/dir.txt
j=1
n=1

#To start tomcat
tomcat () {
echo -e "Please specify the Controller name from below list for which the tomcat will be restarted:\n\n"
cat /tmp/con.txt
echo -e "\n"
read tom_name
if [ $tom_name == "work" ]
then
	service tomcat restart
else
	service tomcat_$tom_name restart
fi
pid=`ps -ef | grep tomcat | grep -w "$tom_name" | awk '/root/ {print $2}'`
echo -e "\nTomcat PID is:-->> $pid\n"

}

#To get the GUI port
gui_port () {

file=`grep "$tom_name" /etc/cav_controller.conf | cut -d '|' -f 5`
port=`grep -n -m 1 "Connector port=" $file/conf/server.xml | cut -d '"' -f 2`
echo -e "GUI port is:-->> $port\n"

}
#To remove the con.txt and dir.txt file...
rmv_file () {
echo "Removing the created files...."
rm /tmp/con.txt
rm /tmp/dir.txt
echo "Removing files done..!!!"
}

#To verify the server.xml entries
check_server () {
echo -e "Please Verify the server.xml entries by comparing with previous..\n\n"
diff $dir/conf/server.xml $dir/conf/server.xml.cp
echo -e -n "\nDo you want to make the changes or want to revert the previous entries..\nType[Y/n]:"
read inp
if [ $inp == "n" ]
then
	mv $dir/conf/server.xml.cp $dir/conf/server.xml
	echo -e "File reverted successfuly..!!\n"
fi

}

#To verify the web.xml entries
check_web () {

echo -e "Please Verify the web.xml entries by comparing with previous..\n"
diff $dir/conf/web.xml $dir/conf/web.xml.cp
echo -e -n "Do you want to make the changes or want to revert the previous entries..\nType[Y/n]:"
read inp
if [ $inp == "n" ]
then
        mv $dir/conf/web.xml.cp $dir/conf/web.xml
        echo -e "File reverted successfuly..!!\n"
fi

}

for i in `cat con.txt`
do
	echo "----------------------------"
	dir=`sed -n "$n"p dir.txt`
	if [ $i == "work" ]
	then
		port=443
		j=0
		
	else
		port=443$j
	fi
	echo -e "$i controller directory is $dir\n"
	if  grep  -q "cavissonwc.ks" $dir/conf/server.xml && grep -q "CONFIDENTIAL" $dir/conf/web.xml 
	then
		echo -e "Controller $i already has the entries..Hence Ignoring...\nMoving to next Controller...\n";sleep 1
		j=`expr $j + 1 `
		n=`expr $n + 1 `
	else
		
		cp $dir/conf/server.xml $dir/conf/server.xml.cp
		cp $dir/conf/web.xml $dir/conf/web.xml.cp
		echo -n "Making Changes for $i controller";inc=0;while [ $inc != 6 ]; do echo -n '.'; sleep 0.5; inc=`expr $inc + 1`;done;echo -e "\n";sleep 1
                l_num=`grep -n -m 1 "redirectPort=" $dir/conf/server.xml | cut -d ':' -f 1`
                sed -i "$l_num s/.*./               redirectPort=\"$port\"\/>/" $dir/conf/server.xml
                cl_num=`grep -n -m 1 "Connector port=" list.txt | cut -d '"' -f 2`
                sed -i "1 s/$cl_num/$port/" list.txt

                sed -i -e '/the shared thread pool/r list.txt' $dir/conf/server.xml
                j=`expr $j + 1 `
		n=`expr $n + 1 `
                sed -i -e '/to use within your application/r list_web.txt' $dir/conf/web.xml
                echo -e "Changes Made Successfully for $i controller\n";sleep 0.5;
		check_server
		check_web
	fi

done
echo -e -n "Do you want to restart the tomcat \nplease type [Y,n]:-"
read usr_in
if [ $usr_in == "n" ]
then 
	rmv_file
else
	echo "Please specify the no of controller where you want to restart the tomcat"
	read num
	for (( k=1; $k<=$num; k++ ))
	do
        	tomcat
		gui_port
	done
	rmv_file
fi
