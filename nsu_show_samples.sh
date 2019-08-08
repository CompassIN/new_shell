

user=`whoami`
if [ "$user" != "root" ]
then
        echo -e "You are not authorized to execute the shell.Please login to root user\n"
        exit
fi

cd /home/netstorm/Controller_NDE/logs/


declare -a rtg_val
declare -a test_val
declare -a sample_val
declare -a rtg
declare -a test
choice=0
time_choice=0

l=0
m=0
temp=0

echo "Enter the TR number : "
read tr
x='TR'
tr_num=$x$tr
if [ ! -d $tr_num ]
then
	echo "Wrong TR Number $tr_num inserted...Aborting..."
	exit
fi
cd $tr_num

case1()
{
		echo -e "Enter the date(dd-mm-yyyy) : "
		read date
		time=$(echo $date | cut -d '-' -f3)$(echo $date | cut -d '-' -f2)$(echo $date | cut -d '-' -f1)
		part_count=$(ls -d $time* | wc -l)

}
case2()
{
		time="2017"
		part_count=$(ls -d 201* | wc -l)
}
case3()
{
		cd /home/netstorm/Controller_NDE/logs/TR60080
		echo -e "Enter start date(DD Mon YYYY) : "
		read start_date
		echo -e "Enter end date(Mon DD YYYY) : "
		read end_date
		
		st_date=$(date --date="$start_date" +%s)
		en_date=$(date --date="$end_date" +%s)

		for i in 2017*
		do
			echo -ne "Wait...\r"
			file_date=$(debugfs -R "stat /home/netstorm/Controller_NDE/logs/TR60080/$i" /dev/sda1 2> /dev/null | grep crtime | awk '{print $5,$6,$8}')
			file_date=$(date --date="$file_date" 2> /dev/null +%s)
			[[ $file_date -le $en_date ]] && [[ $file_date -ge $st_date ]] && echo $i >> /tmp/epoch_file
		done
		echo -e "Done"	
		part_count=$(cat /tmp/epoch_file | wc -l)
		echo
}

echo -e "\nEnter the time period you want to see the data : \n1. Particular date\n2. Whole Scenario\n3. Specified Time\n4. Exit\n"
read time_choice

case $time_choice in
	"1")
		case1
		;;
	"2")
		case2
		;;
	"3")
		case3
		;;	
	"4")
		exit
		;;
esac

#Function to count the number of samples in rtgMessage.dat file and testrun.gdf file.
rtgCount()
{
	echo -e "\n"
	echo -e "##########################################"
	echo -e "##########################################"
        echo -e "###                                    ###"
        echo -e "###                                    ###"
        echo -e "###            RTG Data Count          ###"
        echo -e "###                                    ###"
        echo -e "###                                    ###"
        echo -e "##########################################"
	echo -e "##########################################"
	#Checks for partitions within the tr number
	if [ $part_count != 0 ]
	then
        	echo -e "\n$tr_num"
        	echo -e "---------------------------------------------------------------------------------------------------------------------------------"
	        echo "Number of partitions : $part_count"
		if [ $time_choice == 1 ]
		then
			for i in `ls -d $time* | sort`
			do
				echo -e "\nPartition Number : $i"
	        		echo -e "---------------------------------------------------------------------------------------------------------------------------------"
				cd /home/netstorm/Controller_NDE/logs/$tr_num/$i
				for j in `ls testrun.gdf* | grep -v diff | sort`
				do
					test_val[$l]=$(cat $j | head -1 | cut -d '|' -f6)
					test[$l]=$j
					let "l++"
				done
				for j in `ls rtgMessage.dat* | sort`
				do
					rtg_val[$m]=$(ls -ltr $j | awk '{print $5}')
					rtg[$m]=$j
					let "m++"
				done
				for (( k=0 ; k<l ; k++ ))
				do
					sample_val[$k]=`expr ${rtg_val[$k]} / ${test_val[$k]}`
					echo -e "Partition number : $i \t ${test[$k]} value : ${test_val[$k]} \t ${rtg[$k]} value : ${rtg_val[$k]} \t Number of Samples in ${rtg[$k]} is : ${sample_val[$k]}"
				done
				l=0
				m=0
				if [ -d transposed ]
				then
					temp=1
					cd /home/netstorm/Controller_NDE/logs/$tr_num/$i/transposed
					for j in `ls testrun.gdf* | grep -v diff | sort`
                			do
	                        		test_val[$l]=$(cat $j | head -1 | cut -d '|' -f6)
			                        test[$l]=$j
        			                let "l++"
		                	done
			                for j in `ls rtgMessage.dat* | sort`
	        		        do
        	        		        rtg_val[$m]=$(ls -ltr $j | awk '{print $5}')
	                        		rtg[$m]=$j
		                        	let "m++"
	        		        done
			                for (( k=0 ; k<l ; k++ ))
        			        do
                			        sample_val[$k]=`expr ${rtg_val[$k]} / ${test_val[$k]}`
						echo -e "Partition number : $i \t ${test[$k]} value : ${test_val[$k]} \t ${rtg[$k]} value : ${rtg_val[$k]} \t Number of Samples in ${rtg[$k]} is : ${sample_val[$k]}" >> /tmp/.a
	        	        	done
				fi
				l=0
				m=0
			done
			if [ $temp == 1 ]
			then	
				echo -e "\nPartition > transposed"
		       		echo -e "---------------------------------------------------------------------------------------------------------------------------------"
				cat /tmp/.a
				rm /tmp/.a
			fi
	
		elif [ $time_choice == 2 ]
		then
			for i in `ls -d $time* | sort`
			do
				echo -e "\nPartition Number : $i"
        			echo -e "---------------------------------------------------------------------------------------------------------------------------------"
				cd /home/netstorm/Controller_NDE/logs/$tr_num/$i
				for j in `ls testrun.gdf* | grep -v diff | sort`
				do
					test_val[$l]=$(cat $j | head -1 | cut -d '|' -f6)
					test[$l]=$j
					let "l++"
				done
				for j in `ls rtgMessage.dat* | sort`
				do
					rtg_val[$m]=$(ls -ltr $j | awk '{print $5}')
					rtg[$m]=$j
					let "m++"
				done
				for (( k=0 ; k<l ; k++ ))
				do
					sample_val[$k]=`expr ${rtg_val[$k]} / ${test_val[$k]}`
					echo -e "Partition number : $i \t ${test[$k]} value : ${test_val[$k]} \t ${rtg[$k]} value : ${rtg_val[$k]} \t Number of Samples in ${rtg[$k]} is : ${sample_val[$k]}"
				done
				l=0
				m=0
				if [ -d transposed ]
				then
					temp=1
					cd /home/netstorm/Controller_NDE/logs/$tr_num/$i/transposed
					for j in `ls testrun.gdf* | grep -v diff | sort`
        	        		do
                	        		test_val[$l]=$(cat $j | head -1 | cut -d '|' -f6)
		        	                test[$l]=$j
	        		                let "l++"
		                	done
			                for j in `ls rtgMessage.dat* | sort`
		        	        do
        		        	        rtg_val[$m]=$(ls -ltr $j | awk '{print $5}')
	                	        	rtg[$m]=$j
			                        let "m++"
        			        done
			                for (( k=0 ; k<l ; k++ ))
        			        do
                			        sample_val[$k]=`expr ${rtg_val[$k]} / ${test_val[$k]}`
						echo -e "Partition number : $i \t ${test[$k]} value : ${test_val[$k]} \t ${rtg[$k]} value : ${rtg_val[$k]} \t Number of Samples in ${rtg[$k]} is : ${sample_val[$k]}" >> /tmp/.a
        	        		done
				fi
				l=0
				m=0
			done
			if [ $temp == 1 ]
			then	
				echo -e "\nPartition > transposed"
	       			echo -e "---------------------------------------------------------------------------------------------------------------------------------"
				cat /tmp/.a
				rm /tmp/.a
			fi

		elif [ $time_choice == 3 ]
		then
			for i in `cat /tmp/epoch_file`
			do
				echo -e "\nPartition Number : $i"
	        		echo -e "---------------------------------------------------------------------------------------------------------------------------------"
				cd /home/netstorm/Controller_NDE/logs/$tr_num/$i
				for j in `ls testrun.gdf* | grep -v diff | sort`
				do
					test_val[$l]=$(cat $j | head -1 | cut -d '|' -f6)
					test[$l]=$j
					let "l++"
				done
				for j in `ls rtgMessage.dat* | sort`
				do
					rtg_val[$m]=$(ls -ltr $j | awk '{print $5}')
					rtg[$m]=$j
					let "m++"
				done
				for (( k=0 ; k<l ; k++ ))
				do
					sample_val[$k]=`expr ${rtg_val[$k]} / ${test_val[$k]}`
					echo -e "Partition number : $i \t ${test[$k]} value : ${test_val[$k]} \t ${rtg[$k]} value : ${rtg_val[$k]} \t Number of Samples in ${rtg[$k]} is : ${sample_val[$k]}"
				done
				l=0
				m=0
				if [ -d transposed ]
				then
					temp=1
					cd /home/netstorm/Controller_NDE/logs/$tr_num/$i/transposed
					for j in `ls testrun.gdf* | grep -v diff | sort`
                			do
	                        		test_val[$l]=$(cat $j | head -1 | cut -d '|' -f6)
			                        test[$l]=$j
        			                let "l++"
	                		done
			                for j in `ls rtgMessage.dat* | sort`
		        	        do
        		        	        rtg_val[$m]=$(ls -ltr $j | awk '{print $5}')
		                        	rtg[$m]=$j
			                        let "m++"
        			        done
		        	        for (( k=0 ; k<l ; k++ ))
	        		        do
        	        		        sample_val[$k]=`expr ${rtg_val[$k]} / ${test_val[$k]}`
						echo -e "Partition number : $i \t ${test[$k]} value : ${test_val[$k]} \t ${rtg[$k]} value : ${rtg_val[$k]} \t Number of Samples in ${rtg[$k]} is : ${sample_val[$k]}" >> /tmp/.a
	        	        	done
				fi
				l=0
				m=0
			done
			if [ $temp == 1 ]
			then	
				echo -e "\nPartition > transposed"
	       			echo -e "---------------------------------------------------------------------------------------------------------------------------------"
				cat /tmp/.a
				rm /tmp/.a
			fi
			#rm /tmp/epoch_test
		fi
	fi

	cd /home/netstorm/Controller_NDE/logs/$tr_num/
	for i in `ls -d aggr_*h`
	do
	        temp=0
        	cd /home/netstorm/Controller_NDE/logs/$tr_num/$i
	        part_count=$(ls -d $time* | wc -l)
        	if [ $part_count != 0 ]
	        then
			if [ $time_choice == 1 ]
			then
		                echo -e "\n$tr_num > $i"
		                echo -e "---------------------------------------------------------------------------------------------------------------------------------"
	        	        echo "Number of partitions : $part_count"
				for x in `ls -d $time* | sort`
		        	do
			                echo -e "\nPartition Number : $x"
        			        echo -e "---------------------------------------------------------------------------------------------------------------------------------"
		                	cd /home/netstorm/Controller_NDE/logs/$tr_num/$i/$x
			                for j in `ls testrun.gdf* | grep -v diff | sort`
        			        do
	                		        test_val[$l]=$(cat $j | head -1 | cut -d '|' -f6)
		                        	test[$l]=$j
	        		                let "l++"
        	        		done            
		        	        for j in `ls rtgMessage.dat* | sort`
        		        	do      
	        	        	        rtg_val[$m]=$(ls -ltr $j | awk '{print $5}')
		        	                rtg[$m]=$j
	        		                let "m++"
        	        		done            
			                for (( k=0 ; k<l ; k++ ))
        			        do      
                			        sample_val[$k]=`expr ${rtg_val[$k]} / ${test_val[$k]}`
	                        		echo -e "Partition number : $x \t ${test[$k]} value : ${test_val[$k]} \t ${rtg[$k]} value : ${rtg_val[$k]} \t Number of Samples in ${rtg[$k]} is : ${sample_val[$k]}"
			                done            
        			        l=0             
                			m=0     
		                	if [ -d transposed ]
		        	        then    
			                        temp=1
        			                cd /home/netstorm/Controller_NDE/logs/$tr_num/$i/$x/transposed
		                	        for j in `ls testrun.gdf* | grep -v diff | sort`
	        		                do      
		                	                test_val[$l]=$(cat $j | head -1 | cut -d '|' -f6)
        		                	        test[$l]=$j
                		                	let "l++"
		                	        done    
        			                for j in `ls rtgMessage.dat* | sort`
	                		        do      
                	        		        rtg_val[$m]=$(ls -ltr $j | awk '{print $5}')
	                	        	        rtg[$m]=$j
	        	        	                let "m++"
	        	        	        done
		        	                for (( k=0 ; k<l ; k++ ))
        		        	        do
                		        	        sample_val[$k]=`expr ${rtg_val[$k]} / ${test_val[$k]}`
                        		        	echo -e "Partition number : $x \t ${test[$k]} value : ${test_val[$k]} \t ${rtg[$k]} value : ${rtg_val[$k]} \t Number of Samples in ${rtg[$k]} is : ${sample_val[$k]}" >> /tmp/.b
		                        	done
	        		        fi
        	        		l=0
                			m=0
		        	done
			fi
		elif [ $time_choice == 2 ]
		then
	                echo -e "\n$tr_num > $i"
	                echo -e "---------------------------------------------------------------------------------------------------------------------------------"
	                echo "Number of partitions : $part_count"
			for x in `ls -d $time* | sort`
	        	do
		                echo -e "\nPartition Number : $x"
        		        echo -e "---------------------------------------------------------------------------------------------------------------------------------"
	                	cd /home/netstorm/Controller_NDE/logs/$tr_num/$i/$x
		                for j in `ls testrun.gdf* | grep -v diff | sort`
        		        do
                		        test_val[$l]=$(cat $j | head -1 | cut -d '|' -f6)
	                        	test[$l]=$j
	        	                let "l++"
        	        	done            
	        	        for j in `ls rtgMessage.dat* | sort`
        	        	do      
	                	        rtg_val[$m]=$(ls -ltr $j | awk '{print $5}')
		                        rtg[$m]=$j
        		                let "m++"
                		done            
		                for (( k=0 ; k<l ; k++ ))
        		        do      
                		        sample_val[$k]=`expr ${rtg_val[$k]} / ${test_val[$k]}`
                        		echo -e "Partition number : $x \t ${test[$k]} value : ${test_val[$k]} \t ${rtg[$k]} value : ${rtg_val[$k]} \t Number of Samples in ${rtg[$k]} is : ${sample_val[$k]}"
		                done            
        		        l=0             
                		m=0     
	                	if [ -d transposed ]
	        	        then    
		                        temp=1
        		                cd /home/netstorm/Controller_NDE/logs/$tr_num/$i/$x/transposed
		                        for j in `ls testrun.gdf* | grep -v diff | sort`
        		                do      
	                	                test_val[$l]=$(cat $j | head -1 | cut -d '|' -f6)
        	                	        test[$l]=$j
                	                	let "l++"
		                        done    
        		                for j in `ls rtgMessage.dat* | sort`
                		        do      
                        		        rtg_val[$m]=$(ls -ltr $j | awk '{print $5}')
	                        	        rtg[$m]=$j
	        	                        let "m++"
        	        	        done
	        	                for (( k=0 ; k<l ; k++ ))
        	        	        do
                	        	        sample_val[$k]=`expr ${rtg_val[$k]} / ${test_val[$k]}`
                        	        	echo -e "Partition number : $x \t ${test[$k]} value : ${test_val[$k]} \t ${rtg[$k]} value : ${rtg_val[$k]} \t Number of Samples in ${rtg[$k]} is : ${sample_val[$k]}" >> /tmp/.b
		                        done
        		        fi
                		l=0
                		m=0
	        	done
		elif [ $time_choice == 3 ]
		then
	                echo -e "\n$tr_num > $i"
	                echo -e "---------------------------------------------------------------------------------------------------------------------------------"
	                echo "Number of partitions : $part_count"
			for x in `cat /tmp/epoch_file`
	        	do
		                echo -e "\nPartition Number : $x"
        		        echo -e "---------------------------------------------------------------------------------------------------------------------------------"
	                	cd /home/netstorm/Controller_NDE/logs/$tr_num/$i/$x
		                for j in `ls testrun.gdf* | grep -v diff | sort`
        		        do
                		        test_val[$l]=$(cat $j | head -1 | cut -d '|' -f6)
	                        	test[$l]=$j
	        	                let "l++"
        	        	done            
	        	        for j in `ls rtgMessage.dat* | sort`
        	        	do      
	                	        rtg_val[$m]=$(ls -ltr $j | awk '{print $5}')
		                        rtg[$m]=$j
        		                let "m++"
                		done            
		                for (( k=0 ; k<l ; k++ ))
        		        do      
                		        sample_val[$k]=`expr ${rtg_val[$k]} / ${test_val[$k]}`
                        		echo -e "Partition number : $x \t ${test[$k]} value : ${test_val[$k]} \t ${rtg[$k]} value : ${rtg_val[$k]} \t Number of Samples in ${rtg[$k]} is : ${sample_val[$k]}"
		                done            
        		        l=0             
                		m=0     
	                	if [ -d transposed ]
	        	        then    
		                        temp=1
        		                cd /home/netstorm/Controller_NDE/logs/$tr_num/$i/$x/transposed
		                        for j in `ls testrun.gdf* | grep -v diff | sort`
        		                do      
	                	                test_val[$l]=$(cat $j | head -1 | cut -d '|' -f6)
        	                	        test[$l]=$j
                	                	let "l++"
		                        done    
        		                for j in `ls rtgMessage.dat* | sort`
                		        do      
                        		        rtg_val[$m]=$(ls -ltr $j | awk '{print $5}')
	                        	        rtg[$m]=$j
	        	                        let "m++"
        	        	        done
	        	                for (( k=0 ; k<l ; k++ ))
        	        	        do
                	        	        sample_val[$k]=`expr ${rtg_val[$k]} / ${test_val[$k]}`
                        	        	echo -e "Partition number : $x \t ${test[$k]} value : ${test_val[$k]} \t ${rtg[$k]} value : ${rtg_val[$k]} \t Number of Samples in ${rtg[$k]} is : ${sample_val[$k]}" >> /tmp/.b
		                        done
        		        fi
                		l=0
                		m=0
	        	done
		fi
		if [ $temp == 1 ]
        	then
                	echo -e "\nPartition > aggregate > transposed"
	                echo -e "---------------------------------------------------------------------------------------------------------------------------------"
        	        cat /tmp/.b
	                rm /tmp/.b
        	fi
	done
	echo -e "\n"
}

pctCount()
{
	echo -e "###########################################"
	echo -e "###########################################"
	echo -e "###					###"
	echo -e "###					###"
	echo -e "###		PCT Data Count		###"
	echo -e "###					###"
	echo -e "###					###"
	echo -e "###########################################"
	echo -e "###########################################"
	
	cd /home/netstorm/Controller_NDE/logs/$tr_num
	test_pdf=0
	pct_dat=0
	sample_count=0
	echo -e "\n$tr_num"
        echo -e "---------------------------------------------------------------------------------------------------------------------------------"
        echo "Number of partitions : $part_count"
        if [ $time_choice == 1 ]
	then
		for i in `ls -d $time* | sort`
        	do
	                cd /home/netstorm/Controller_NDE/logs/$tr_num/$i
			test_pdf=`cat testrun.pdf | head -1 | cut -d '|' -f4`
			pct_dat=`ls -ltr pctMessage.dat | awk '{print $5}'`
			sample_count=`expr $pct_dat / $test_pdf`
			echo -e "Partition Number : $i \t testrun.pdf value : $test_pdf \t pctmessage.dat value : $pct_dat \t Number of Samples in pctMessage.dat is : $sample_count"
		done	
		echo -e "\n"
	elif [ $time_choice == 2 ]
	then
		for i in `ls -d $time* | sort`
        	do
	                cd /home/netstorm/Controller_NDE/logs/$tr_num/$i
			test_pdf=`cat testrun.pdf | head -1 | cut -d '|' -f4`
			pct_dat=`ls -ltr pctMessage.dat | awk '{print $5}'`
			sample_count=`expr $pct_dat / $test_pdf`
			echo -e "Partition Number : $i \t testrun.pdf value : $test_pdf \t pctmessage.dat value : $pct_dat \t Number of Samples in pctMessage.dat is : $sample_count"
		done	
		echo -e "\n"
	
	elif [ $time_choice == 3 ]
	then	
		for i in `cat /tmp/epoch_file`
        	do
	                cd /home/netstorm/Controller_NDE/logs/$tr_num/$i
			test_pdf=`cat testrun.pdf | head -1 | cut -d '|' -f4`
			pct_dat=`ls -ltr pctMessage.dat | awk '{print $5}'`
			sample_count=`expr $pct_dat / $test_pdf`
			echo -e "Partition Number : $i \t testrun.pdf value : $test_pdf \t pctmessage.dat value : $pct_dat \t Number of Samples in pctMessage.dat is : $sample_count"
		done	
		echo -e "\n"	
	fi
}

echo -e "\nEnter your choice :\n1. RTG data \n2. PCT data\n3. Both PCT and RTG data\n4. Exit"
read choice

case $choice in 
	"1")
		rtgCount
		if [ $time_choice == 3 ]
		then
			rm /tmp/epoch_file
		fi
		;;
	"2")
		pctCount
		if [ $time_choice == 3 ]
		then
			rm /tmp/epoch_file
		fi
		;;
	"3")	
		rtgCount
		pctCount
		if [ $time_choice == 3 ]
		then
			rm /tmp/epoch_file
		fi
		;;
	"4")	
		exit
		;;
esac		
