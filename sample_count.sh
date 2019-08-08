#!/bin/sh

#########################################################
#							#
#							#
###  Script to Calculate the total number of samples  ###
#							#
#							#
#########################################################


echo -e "\nenter the controller name:-"
read cont_name
echo "Enter the TR number:-"
read TRNum
echo "enter the Partition year:-"
read year
if [ -e /home/netstorm/$cont_name ]
then 
	echo "Existing Controller $cont_name !!!"
	if [ -e /home/netstorm/$cont_name/logs/TR$TRNum ]
	then    
        	echo "Existing TR $TRNum !!!"
		ty=`ls /home/netstorm/$cont_name/logs/TR$TRNum | head -1`
		if [[ $ty == "$year"* ]]
		then
			echo "Existing Partition year $year!!!"
			echo -n "Checking Data";inc=0;while [ $inc != 6 ]; do echo -n '.'; sleep 0.5; inc=`expr $inc + 1`;done; echo -e "\nAll good....";sleep 1
		else
                        echo -e "Partition year $year not exist Hence Exiting.. :( :(\n"
                        exit
		fi
	
	else 
		echo "TR $TRNum not exist Hence Exiting. :( :("
		exit
	fi
else 
	echo "Controller $cont_name not exist Hence Exiting.. :( :("
	exit
fi

cd /home/netstorm/$cont_name/logs/TR$TRNum
echo -e "\n"
echo -n Calculating;inc=0;while [ $inc != 4 ]; do echo -n '.'; sleep 1; inc=`expr $inc + 1`;done; echo -e "\nprinting Results..";sleep 1
for i in $year*
do
	cd /home/netstorm/$cont_name/logs/TR$TRNum
	echo -e "===================================\n"
	echo "Partition is -->$i" 
	cd $i;
	te_gd=`ls -ltr testrun.gdf* | sort | awk '{print $9}'`
	echo -e "===================================\n"
	count=0
	total=0
	sum=0
	for j in $te_gd
	do 
		te_ou=`head -1 $j |cut -d '|' -f 6`
		echo -e "$j >>>>>$te_ou\n" 
		if [ $count == 0 ]
		then
			rtg=rtgMessage.dat
		else
			rtg=rtgMessage.dat.$count
		fi
		count=`expr $count + 1`

		rtms=`ls -l $rtg | awk '{print $5}'`
		echo -e "$rtg file size ---->>$rtms\n"
		res=`expr $rtms / $te_ou`
		total=`expr $res + $sum`
		sum=$total
		echo "total value ::::>>>$total"
		echo -e "-----------------------------------\n"
	done	
	echo -e " ++++++++ for Partition $i the total number of sample is $total +++++++++\n"	
	echo -e " ++++++++ for Partition $i the total number of sample is $total +++++++++\n" >> /tmp/output.txt
sleep 2	
done
echo -e "********printing the result********\n"
sleep 2
cat /tmp/output.txt
echo "Removing the file...."
rm /tmp/output.txt
echo -e "File removed Successfully\n"
