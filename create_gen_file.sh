#!/bin/sh

#################################################################
#								#
#								#	
###        ---script to create the generator file---	      ###	
#								#
#								#
#								#
#################################################################


file_check () {

echo -n "Checking files";inc=0;while [ $inc != 6 ]; do echo -n '.'; sleep 0.5; inc=`expr $inc + 1`;done;sleep 1
if [ -e /etc/.netcloud ]
then
	if [ -e /etc/.netcloud/generators.dat ]
	then
		echo -e "\nAll files exists\nAll OK.."
	else 
		echo -e "generators.dat file not exists inside .netcloud dir \n Creating generator file "
		touch /etc/.netcloud/generators.dat
	fi
else 
echo -e "\n.netcloud Directory not exists..\n Creating .netcloud Directory & generator file...\n";sleep 1;
mkdir /etc/.netcloud
touch /etc/.netcloud/generators.dat
	
echo  " Directory created successfully";
fi

}

file_check

echo "Enter the number of generators"
read n

echo "enter the controller IP"
read con_ip
echo "enter the controller Blade"
read con_blade

for (( i=1; $i<=$n; i++ ))
do
	if [ $i == 1 ]
	then
		echo -e -n "Do you want to keep the Previous entries in  the Generator file or want to overwrite it...\n Type [Y/n]"
		read usr_in
		if [ $usr_in == "n" ]
		then
			echo "#GeneratorName|IP|CaMonAgentPort|Location|Work|Type|ControllerIp|ControllerName|ControllerWork|Team|NameServer|DataCenter|Future1|Future2|Future3|Future4|Future5|Future6|Future7|Comments" > /etc/.netcloud/generators.dat
		fi
	fi
	echo "Enter generator $i name"
        read gen_name
        echo "enter the generator $i IP"
        read gen_ip
        echo "Enter the $gen_name blade"
        read gen_blade	

	echo "$gen_name|$gen_ip|7891|Loc1|/home/netstorm/$gen_blade|Internal|$con_ip|$con_blade|/home/netstorm/$con_blade|NETCLOUD|NA|NA|NA|NA|NA|NA|NA|NA|NA|NA" >> /etc/.netcloud/generators.dat

done

echo -e "\nplease check the entries as follows:-\n"
tail -$n /etc/.netcloud/generators.dat
echo -e "\nGenerator file entry Done.......!!!!!"

