###################################################
###################################################
###						###
###						###
###		Sample Count Shell		###
###						###
###						###
###################################################
###################################################
		
cd /home/netstorm/Controller_NDE/logs
declare -a test_val
declare -a rtg_val
declare -a sample_val
flag=0
echo "Enter the TR number : "
read tr
x='TR'
tr_num=$x$tr
cd $tr_num
echo "Enter the date(dd-mm-yyyy) : "
read date
time=$(echo $date | cut -d '-' -f3)$(echo $date | cut -d '-' -f2)$(echo $date | cut -d '-' -f1)
part_count=$(ls -d $time* | wc -l)

#Checks for partitions within the tr number
if [ $part_count != 0 ]
then
	#echo -e "\n\e[1;31m $tr_num [0m\e"
	echo -e "\n$tr_num"
	echo -e "---------------------------------------------------------------------------------------------------------------------------------"
	echo "Number of partitions : $part_count"
	for i in `ls -d $time*`
	do
		cd /home/netstorm/Controller_NDE/logs/$tr_num/$i
		for k in `ls testrun.g*`
                do
                        test_val[$flag]=$(cat $k | head -1 | cut -d '|' -f6)
			flag=`expr $flag + 1`
		done
		flag=0
                for l in `ls rtgMessage.d*`
                do
                        rtg_val[$flag]=$(ls -ltr | grep $l | awk '{print $5}')
			flag=`expr $flag + 1`
                done
                for (( m=0 ; m<flag ; m++ ))
                do
                	sample_val[$m]=`expr ${rtg_val[$m]} / ${test_val[$m]}`
                        echo -e "Partition number : $i \t rtgMessage.dat value : ${rtg_val[$m]} \t testrun.gdf value : ${test_val[$m]} \t Samples : ${sample_val[$m]}"
                done
	done
	echo -e ""
fi
flag=0

#Checks for partitions within the aggregate directory within the tr number
cd /home/netstorm/Controller_NDE/logs/$tr_num/
for i in `ls -d aggr*`
do
	cd /home/netstorm/Controller_NDE/logs/$tr_num/$i
	part_count=$(ls -d $time* | wc -l)
	if [ $part_count != 0 ]
	then
		echo -e "$tr_num > $i"
		echo -e "---------------------------------------------------------------------------------------------------------------------------------"
		echo "Number of partitions : $part_count"
       		for j in `ls -d $time*`
      		do
        		cd /home/netstorm/Controller_NDE/logs/$tr_num/$i/$j
                	for x in `ls testrun.g*`
               		do
               			test_val[$flag]=$(cat $x | head -1 | cut -d '|' -f6)
				flag=`expr $flag + 1`
         		done
			flag=0
			for y in `ls rtgMessage.d*`
			do
				rtg_val[$flag]=$(ls -ltr | grep $y | awk '{print $5}' | head -1)
				flag=`expr $flag + 1`
        		done
			for (( m=0 ; m<flag ; m++ ))
			do
             		   	sample_val[$m]=`expr ${rtg_val[$m]} / ${test_val[$m]}`
				echo -e "Partition number : $j \t rtgMessage.dat value : ${rtg_val[$m]} \t testrun.gdf value : ${test_val[$m]} \t Samples : ${sample_val[$m]}"
			done
#Checks for partitions within the transposed directory within the partition present within aggregate directory within TR Number
			if [ $(ls -d | grep transposed | wc -l) != 0 ]
                	then
                        	cd /home/netstorm/Controller_NDE/logs/$tr_num/$i/$j/transposed
				echo -e "\n$tr_num > $j > transposed"
				echo -e "---------------------------------------------------------------------------------------------------------------------------------"
				part_count=$(ls -d $time* | wc -l)
                        	if [ $part_count != 0 ]
                        	then
                                	for k in `ls -d $time*`
                                	do
                                        	cd /home/netstorm/Controller_NDE/logs/$tr_num/$i/transposed/$k
                                        	echo -e "transposed"
                                        	for x in `ls testrun.g*`
                                        	do
                                                	test_val[$flag]=$(cat $x | head -1 | cut -d '|' -f6)
                                                	flag=`expr $flag + 1`
                                        	done
                                        	flag=0
                                        	for y in `ls rtgMessage.d*`
                                        	do
                                                	rtg_val[$flag]=$(ls -ltr | grep $y | awk '{print $5}' | head -1)
                                                	flag=`expr $flag + 1`
                                        	done
                                        	for (( m=0 ; m<flag ; m++ ))
                                        	do
                                                	sample_val[$m]=`expr ${rtg_val[$m]} / ${test_val[$m]}`
                                                	echo -e "Partition number : $k \t rtgMessage.dat value : ${rtg_val[$m]} \t testrun.gdf value : ${test_val[$m]} \t Samples : ${sample_val[$m]}"
                                        	done
                                	done
                        	elif [ $part_count == 0 ]
                        	then
                                	echo -e "\nNo such partitions in this directory "
                        	fi
                	elif [ $(ls -d | grep transposed | wc -l) == 0 ]
                	then
				echo -e "\n$tr_num > $j > $i > transposed"
	                     	echo -e "---------------------------------------------------------------------------------------------------------------------------------"
				echo -e "No partitions within this directory..."
                	fi
		done
		echo -e ""
#Checks for partitions within the aggregate directory within the TR Number
		if [ $(ls -d | grep transposed | wc -l) != 0 ]
		then
			cd /home/netstorm/Controller_NDE/logs/$tr_num/$i/transposed
			part_count=$(ls -d $time* | wc -l)
                        if [ $part_count != 0 ]
                        then
				for k in `ls -d $time*`
                		do
                        		cd /home/netstorm/Controller_NDE/logs/$tr_num/$i/transposed
					echo -e "\n$tr_num > $i > transposed "
					echo -e "---------------------------------------------------------------------------------------------------------------------------------"
                        		for x in `ls testrun.g*`
                        		do
                                		test_val[$flag]=$(cat $x | head -1 | cut -d '|' -f6)
                                		flag=`expr $flag + 1`
                        		done
                        		flag=0
                        		for y in `ls rtgMessage.d*`
                        		do
                                		rtg_val[$flag]=$(ls -ltr | grep $y | awk '{print $5}' | head -1)
                                		flag=`expr $flag + 1`
                        		done
                        		for (( m=0 ; m<flag ; m++ ))
                        		do
                                		sample_val[$m]=`expr ${rtg_val[$m]} / ${test_val[$m]}`
                                		echo -e "Partition number : $k \t rtgMessage.dat value : ${rtg_val[$m]} \t testrun.gdf value : ${test_val[$m]} \t Samples : ${sample_val[$m]}"
                        		done
				done
			elif [ $part_count == 0 ]
			then
				echo -e "\nNo such partitions in this directory "
			fi
		elif [ $(ls -d | grep transposed | wc -l) == 0 ]
		then
			echo -e "\n$i > transposed"
			echo -e "---------------------------------------------------------------------------------------------------------------------------------"
			echo -e "No partitions within this directory..."
		fi
		echo -e "\n"
		elif [ $part_count == 0 ]
		then
			echo -e "\n$i"
			echo -e "---------------------------------------------------------------------------------------------------------------------------------"
			echo -e "No such prtition within this aggregate...\n"
		fi
done
