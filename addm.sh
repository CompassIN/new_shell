

user=`whoami`
if [ "$user" != "root" ]
then
        echo -e "You are not authorized to execute the shell.Please login to root user\n"
        exit
fi

if cut -d ':' -f 1 /etc/passwd | grep -q discadm 
then 
	echo "discadm user already exist hence exiting"
	exit
fi
user=discadm
useradd $user -m -s /bin/bash

if [ -e /home/$user/.ssh ]
then 
	echo -e "ssh directory present"
else
	mkdir /home/$user/.ssh
fi

touch /home/$user/.ssh/authorized_keys
echo -n "Wait for Changing the file permission & verifing";inc=0;while [ $inc != 6 ]; do echo -n '.'; sleep 0.5; inc=`expr $inc + 1`;done;echo -e "\n";sleep 1
chown discadm:staff /home/$user
chmod 0755 /home/$user
chown discadm:staff /home/$user/.ssh
chmod 0700 /home/$user/.ssh
chmod 0644 /home/$user/.ssh/authorized_keys
echo -e "permisson changed..All Good!!\n"


echo "from=\"10.2.224.65,10.2.224.66,10.2.224.67,10.2.224.68,10.2.224.69,10.2.224.7?,10.2.224.8?,10.2.224.9?,10.2.224.10?,10.2.224.11?,10.2.224.120,10.2.224.121,10.2.224.122,10.2.224.123,10.2.224.124,10.2.224.125,10.2.224.126,10.7.224.65,10.7.224.66,10.7.224.67,10.7.224.68,10.7.224.69,10.7.224.7?,10.7.224.8?,10.7.224.9?,10.7.224.10?,10.7.224.11?,10.7.224.120,10.7.224.121,10.7.224.122,10.7.224.123,10.7.224.124,10.7.224.125,10.7.224.126\" ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAzkQhQR1O5auVgo19jRRCQw0RpAwzBIGhXURe9Jn1ShxtgtMt43fPyz9gprdby+Q11IiyYXQ4eSiR7/LysDU19jk2nGaJp/Ph5wPaZwMj56caqMOxtCtWKjX633kkKTeDWdVNkQERmV2G/8M2dYqElnAXnTAsBah7D/vfrf5W6u7Zhv/V7ZrOup+k5h0E3s8uON+z0aiAzhxggeYlIxKJHguEI39lLAmBtgQkh9EQnk9hrTnvnpU60KUO0pr+a31dluR5N8R3vW09ZIUYU6qylAJiZg1iVjDR71PQnvEWtk0a1cHDfY4XYWRKOPzvApKHhB5HnndAvUqleJShNhkFQQ== tideway@tsms900" > /home/$user/.ssh/authorized_keys
echo -e "\n\n\nAAAAB3NzaC1yc2EAAAABIwAAAQEAzkQhQR1O5auVgo19jRRCQw0RpAwzBIGhXURe9Jn1ShxtgtMt43fPyz9gprdby+Q11IiyYXQ4eSiR7/LysDU19jk2nGaJp/Ph5wPaZwMj56caqMOxtCtWKjX633kkKTeDWdVNkQERmV2G/8M2dYqElnAXnTAsBah7D/vfrf5W6u7Zhv/V7ZrOup+k5h0E3s8uON+z0aiAzhxggeYlIxKJHguEI39lLAmBtgQkh9EQnk9hrTnvnpU60KUO0pr+a31dluR5N8R3vW09ZIUYU6qylAJiZg1iVjDR71PQnvEWtk0a1cHDfY4XYWRKOPzvApKHhB5HnndAvUqleJShNhkFQQ== tideway@tsms900" >> /home/$user/.ssh/authorized_keys

echo -e "Match User discadm\n\tPubkeyAuthentication yes \n\tAuthorizedKeysFile /home/$user/.ssh/authorized_keys\n\tPasswordAuthentication no" >> /etc/ssh/sshd_config

service ssh restart

if ! grep -q "/usr/sbin/dmidecode" /etc/sudoers
then
	sed -i '/Cmnd alias/a Cmnd_Alias CLIENT_CMDS = /bin/netstat,  /usr/sbin/dmidecode,  /sbin/ethtool,  /usr/bin/lsof, /usr/sbin/hwinfo' /etc/sudoers
	echo "discadm   ALL=(ALL) CLIENT_CMDS" >> /etc/sudoers
fi


touch /etc/sudoers.d/01-ei-discadm-sudoers

cat sudo_file > /etc/sudoers.d/01-ei-discadm-sudoers
chmod 0440 /etc/sudoers.d/01-ei-discadm-sudoers
echo -e "Restarting ssh service again\n"
service ssh restart

