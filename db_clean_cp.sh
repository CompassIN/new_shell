#!/bin/sh
usage()
{
tput bold
echo -e "Usage: \033[31m nsi_clean_database  -s <Start Test Run Number>  -e <End Test Run Number> OR -n <Test Run Number> OR -m\033[0m"
tput sgr0
echo "case 1 : nsi_clean_database -s <Start Test Run Number> -e <End Test Run Number> : To delete TR between the start range to end range provided by user from database"
echo "case 2 : nsi_clean_database -n <Test Run Number> : To delete a single TR provided by user from database"
echo "case 3 : nsi_clean_database -m :To delete TR from database which is not present in the system" 
exit 1
}
one_tr()
{		
if ! [[ "$TR" =~ ^[0-9]+$ ]]
    then
        echo "Sorry integers only"
	exit 1
fi
psql test cavisson <<+ >> /tmp/delete_one_tr.$$
select tablename from pg_tables WHERE tableowner = 'cavisson' and tablename similar  to '%_$TR';
+

num=`grep -c _$TR  /tmp/delete_one_tr.$$`
if [  $num -eq 0 ]
then
	echo "TR not found"
	exit 1
fi
for  j in `grep -v "tablename" /tmp/delete_one_tr.$$| grep -v "row" | grep -v "\\----" `
do
psql test cavisson <<+ >>/tmp/del_one_tr.$$
drop table $j CASCADE;
+
done
rm /tmp/delete_one_tr.$$
}


range()
{
if ! [[ "$START_TR" =~ ^[0-9]+$ ]]
    then
        echo "Sorry integers only"
	exit 1
fi
if ! [[ "$END_TR" =~ ^[0-9]+$ ]]
    then
        echo "Sorry integers only"
	exit 1
fi
if [ $START_TR -gt $END_TR ]
then
        echo "Start TR should always be smaller than End TR"
        exit 1
fi
psql test cavisson <<+ >> /tmp/START_TR.$$
select tablename from pg_tables WHERE tableowner = 'cavisson' and tablename similar  to '%_$START_TR';
+
num=`grep -c  "_$START_TR" /tmp/START_TR.$$`
if [  $num -eq 0 ]
then
        echo "START TR not found"
        exit 1
fi
psql test cavisson <<+ >> /tmp/END_TR.$$
select tablename from pg_tables WHERE tableowner = 'cavisson' and tablename similar  to '%_$END_TR';
+
num=`grep -c  "_$END_TR" /tmp/END_TR.$$`
if [ $num -eq 0 ]
then
        echo "END TR not found"
        exit 1
fi
for((test_run=$START_TR;test_run<=$END_TR;test_run++))
do
psql test cavisson <<+ >> /tmp/delete_range.$$
select tablename from pg_tables WHERE tableowner = 'cavisson' and tablename similar  to '%_$test_run';
+
done
for  j in `grep -v "tablename" /tmp/delete_range.$$| grep -v "row" | grep -v "\\----" `
do
psql test cavisson <<+ >>/tmp/drop_start_end.$$
drop table $j CASCADE;
+
done
rm /tmp/START_TR.$$ /tmp/END_TR.$$ /tmp/delete_range.$$ /tmp/END_TR.$$ /tmp/END_TR.$$ /tmp/drop_start_end.$$
}

match()
{
psql test cavisson <<+ >>/tmp/tables.$$
select tablename from pg_tables where tableowner = 'cavisson' and tablename similar to  '%_[0-999999]';
+
grep -v "tablename" /tmp/tables.$$ | grep -v "(" | cut -d'_' -f2 | grep -v "\\--"| sort | uniq | tail  -n +2 > /tmp/trnum_db.$$
#echo  "list of TR's in Database is stored on file /tmp/trnum_db.$$"
for k in `nsi_get_controller_name`
do
ls -ltr /home/cavisson/$k/webapps/logs | awk '{print $9}' | egrep -v "scheduler|WEB-INF" | tail -n +2 | cut -d 'R' -f2 >> /tmp/trnum_webapps.$$
done
for i in `cat /tmp/trnum_db.$$`
do        
if ! grep -w -q $i /tmp/trnum_webapps.$$
then      
 echo $i >> /tmp/exTR.$$
 psql test cavisson <<+ >> /tmp/delete_tab.$$
select tablename from pg_tables WHERE tableowner = 'cavisson' and tablename similar  to '%_$i';
+

for  j in `grep -v "tablename" /tmp/delete_tab.$$| grep -v "row" | grep -v "\\----" `
do
psql test cavisson <<+ >>/tmp/drop_start_end.$$
drop table $j CASCADE;
+
done

fi

done
if  [ ! -f  /tmp/exTR.$$  ]
then
        echo "Extra TR not found"
        exit 1
fi
rm /tmp/tables.$$ /tmp/delete_tab.$$ /tmp/exTR.$$ /tmp/trnum_webapps.$$  
}

if [ $# -eq 0 ]
then
	usage
	exit 1
fi

while getopts n:s:e:m args
do
	case $args in 
	n) TR=$OPTARG;;
	s) START_TR=$OPTARG;;
	e) END_TR=$OPTARG;;
	m) flag=0 ;;
	*) usage ;;
#	?) usage;;
	esac
done
if [ ! -z $START_TR ] && [ ! -z $END_TR ] && [ -z $TR ] && [ -z $flag ] 
#if [ ! -z $START_TR ] && [ ! -z $END_TR ] && [ $# -eq 2 ] 
then
range
elif [ ! -z $TR ] && [ -z $flag ] && [ -z $START_TR ] && [ -z $END_TR ] 
#elif [ ! -z $TR ] && [ -z $flag ] && [ -z $START_TR ] && [ -z $END_TR ] && [ $# -eq 1 ]
#elif [ ! -z $TR ] && [ $flag -eq 1 ] && [ -z $START_TR ] && [ -z $END_TR ] &&
then
one_tr
#elif [ $flag -eq 0 ] && [ -z $START_TR ] && [ -z $END_TR ] && [ -z  $TR ] 
elif [ $flag -eq 0 ] && [ -z $START_TR ] && [ -z $END_TR ] 
then
match
else
echo -e "\033[0;31mnsi_clean_database:mandatory fields are missing\e[0m"
usage
fi


