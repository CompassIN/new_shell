#!/bin/sh

#################################################################
#                                                               #
#                                                               #       
###      	  --script to upgrade the build ---    	      ###       
#                                                               #
#                                                               #
#                                                               #
#################################################################

echo -e "Enter the build version\n"
read bv
echo -e "Enter the controller where you want to upgrade the build\n"
read con
build=`echo $bv | cut -d '#' -f 1`
ver=`echo $bv | cut -d '#' -f 2`
ob=$(echo ${build:0:1}.${build:1:1}.${build:2:2})
bv=$(echo $ob.$ver)
for i in `tail -n +2 /etc/cav_controller.conf | cut -d '|' -f 3`
do 
	find $i/.rel -iname "netstorm*$bv*.bin" >> /tmp/netstorm_build
	find $i/.rel -iname "thirdparty*$bv*.bin" >> /tmp/thirdparty_build
done
if  grep  -q $con /etc/cav_controller.conf
then
	NS_WDIR=/home/netstorm/$con
	HPD_ROOT=/var/$con/hpd
	LPS_ROOT=/home/netstorm/$con/lps
else 
	echo -e "Controller name not exist hence exiting\n"
	exit
fi

nsb_size=`stat -c %s /tmp/netstorm_build`
th_size=`stat -c %s /tmp/thirdparty_build`
netstorm () {
if  grep  -q $con /tmp/netstorm_build
then
	echo -n "Found netstorm build,Wait for upgradation";inc=0;while [ $inc != 4 ]; do echo -n '.'; sleep 0.5; inc=`expr $inc + 1`;done;echo -e "\n";sleep 1	
	cd $NS_WDIR/upgrade/
        upg_nsb=`head -1 /tmp/netstorm_build | cut -d '/' -f 6`
	cp /home/netstorm/$con/.rel/$upg_nsb /home/netstorm/$con/upgrade/
        sh $upg_nsb
else
	cpb=`head -1 /tmp/netstorm_build | cut -d '/' -f 4`
	echo -e "Not found the netstorm Build in given Controller,So copying from $cpb\n"
	copy_nsb=`head -1 /tmp/netstorm_build`
	cp $copy_nsb /home/netstorm/$con/upgrade 
	echo -n "Copied netstorm build successfully...Wait for upgradation";inc=0;while [ $inc != 4 ]; do echo -n '.'; sleep 0.5; inc=`expr $inc + 1`;done;echo -e "\n";sleep 1	
	cd $NS_WDIR/upgrade/
	upg_nsb=`head -1 /tmp/netstorm_build | cut -d '/' -f 6`
	sh $upg_nsb
fi
}

thirdparty () {

if  grep  -q $con /tmp/thirdparty_build
then
	echo -n "Found thirdparty build,Wait for upgradation";inc=0;while [ $inc != 4 ]; do echo -n '.'; sleep 0.5; inc=`expr $inc + 1`;done;echo -e "\n";sleep 1
	cd $NS_WDIR/upgrade/
        upg_tpb=`head -1 /tmp/thirdparty_build | cut -d '/' -f 6`
	cp /home/netstorm/$con/.rel/$upg_tpb /home/netstorm/$con/upgrade/
        sh $upg_tpb
else
        cpb=`head -1 /tmp/thirdparty_build | cut -d '/' -f 4`
        echo -e "Not found the thirdparty Build in given Controller,So copying from $cpb\n"
        copy_nsb=`head -1 /tmp/thirdparty_build`
        cp $copy_nsb /home/netstorm/$con/upgrade 
	echo -n "Copied thirdparty build successfully...Wait for upgradation";inc=0;while [ $inc != 4 ]; do echo -n '.'; sleep 0.5; inc=`expr $inc + 1`;done;echo -e "\n";sleep 1	
	cd $NS_WDIR/upgrade/
        upg_tpb=`head -1 /tmp/thirdparty_build | cut -d '/' -f 6`
        sh $upg_tpb
fi
}
build_hub_upg () {
	cd $NS_WDIR/upgrade/
	echo -e "Upgrading Thirdparty Build..\n"
	sh thirdparty.$bv\_Ubuntu1204_64.bin
	echo -e "\n\n"
	echo -e "Upgrading Netstorm Build..\n"
	sh netstorm_all.$bv.Ubuntu1204_64.bin
}
if [ $nsb_size -eq 0 ] || [ $th_size -eq 0 ]
then
        echo -e "Build not found in this machine.Downloading form build Hub..\n"
        wget -o out_tp.log http://10.10.30.16:8000/$ob/thirdparty.$bv\_Ubuntu1204_64.bin -P /home/netstorm/$con/upgrade
        wget -o out_ns.log http://10.10.30.16:8000/$ob/netstorm_all.$bv.Ubuntu1204_64.bin -P /home/netstorm/$con/upgrade
	err_log=`grep -m 1 -i -o error out_tp.log`
	if [ "$err_log" == "ERROR" ]
	then
		echo -e "Build not found in Build Hub,Check Input Build\n" 
	else
        	build_hub_upg
	fi
	rm out_tp.log out_ns.log
else 
	thirdparty
	echo -e "\n\n"
	netstorm
fi
rm /tmp/netstorm_build /tmp/thirdparty_build
