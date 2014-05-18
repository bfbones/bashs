#!/bin/bash

if [ -n "$1" ]; then
	option=$1
else
	echo "Starting automated Server managing tool.."
	sleep 1 
	echo "##########################################################"
	echo "Please choose an option"
	echo " -- Update -- to update all servers package database"
	echo " -- Upgrade -- to run a package update on all servers"
	echo " -- dnscheck -- check all domains for possible DNS failures"
	echo " -- file -- spread files over all servers"
	echo " -- command -- do something on all servers"
	echo " -- aptitude -- install software on all servers"
	echo " -- pingcheck -- check reachability of all vms both v4 and v6"
	echo " -- dummy -- just a useless option"
	read -p "option: " option
	echo "##########################################################"
echo ""
fi

if [[ "$option" != "dnscheck" && "$option" != "pingcheck" ]]; then
	echo "registering ssh keys.."

	if [ -z $SSH_AGENT_PID ]; then
		eval $(ssh-agent)
		ssh-add .sshkeys/kserver
	else
	        ssh-add .sshkeys/kserver
	fi
fi
echo ""
server[0]='ssh root@server.com -i .sshkeys/key1 -p 22' #THIS FORMAT ONLY! WITH PORT!
server[1]='ssh user@otherserver.com -i .sshkeys/key2 -p 12345'
server[2]='...'

domains=( server.com otherserver.com )

rm=`shuf -i 100-999 -n 1`

if [ "$option" == "update" ]; then
	screen -S update-manage-$rm -t tab0 -A -d -m
	for i in "${server[@]}" 
	do
		echo ""
		servername=`echo $i |  cut -d" " -f2`
		echo ""
		echo "Updating package-database on $servername"
		echo "_____________________________________________________"
			screen -S update-manage-$rm -X screen -t $servername
			screen -S update-manage-$rm -p $servername -X stuff "${i} -t screen -S update aptitude update && exit\n"
	done
	screen -S update-manage-$rm -p tab0 -X stuff $'exit\n'
	screen -x update-manage-$rm
fi

if [ "$option" == "upgrade" ]; then
	screen -S upgrade-manage-$rm -t tab0 -A -d -m
        for i in "${server[@]}"
        do
                echo ""
                servername=`echo $i |  cut -d" " -f2`
		echo ""
                echo "updating packages on $servername"
		echo "_____________________________________________________"
		echo "command: $i -t screen sudo aptitude upgrade"
		read -p '..execute? (y, N): ' update
		if [ "$update" == "y" ]; then
				screen -S upgrade-manage-$rm -X screen -t $servername
				screen -S upgrade-manage-$rm -p $servername -X stuff "${i} -t screen aptitude upgrade && /usr/local/bin/.manage_kupdatehelper.sh ${servername} && exit\n"
			#read -p 'Kernel-update? (y, N)' kupdate
                	#if [ "$kupdate" == "y" ]; then
                	#	echo "Kernel-Update on $servername ." >> kupdate.tmp
                	#fi
		fi
		echo "_____________________________________________________"
        done
	screen -S upgrade-manage-$rm -p tab0 -X stuff $'exit\n'
	screen -x upgrade-manage-$rm
fi

if [ "$option" == "file" ]; then
	read -p "source-file: " sourcefile
	read -p "dest-dir: " destdir
        for i in "${server[@]}"
        do
                echo ""
                servername=`echo $i |  cut -d" " -f2`
		echo ""
                echo "scp-ing file to $servername"
		echo "_____________________________________________________"
		url=`echo $i | cut -d" " -f2`
		key=`echo $i | awk '{print $4}'`
		port=`echo $i | awk '{print $6}'`
		echo "command: scp -P $port -i $key $sourcefile $url:$destdir"
		read -p '..execute? (y, N): ' update
		if [ "$update" == "y" ]; then
			scp -P $port -i $key $sourcefile $url:$destdir
		fi
		echo "_____________________________________________________"
        done
fi

if [ "$option" == "command" ]; then
	read -p "command: " command
        for i in "${server[@]}"
        do
                echo ""
                servername=`echo $i |  cut -d" " -f2`
                echo ""
                echo "running command "$command" on $servername"
                echo "_____________________________________________________"
                echo "command: $i '$command'"
                read -p '..execute? (y, N): ' doit
                if [ "$doit" == "y" ]; then
				$i "${command}"
                fi
                echo "_____________________________________________________"
        done
fi

if [ "$option" == "aptitude" ]; then
	read -p 'package(s): ' packages
        for i in "${server[@]}"
        do
                echo ""
                servername=`echo $i |  cut -d" " -f2`
		echo ""
                echo "installing '$packages' on $servername"
		echo "_____________________________________________________"
		echo "command: $i -t screen aptitude install $packages"
		read -p '..execute? (y, N): ' update
		if [ "$update" == "y" ]; then
				$i -t screen aptitude install $packages
		fi
		echo "_____________________________________________________"
        done
fi

if [ "$option" == "dnscheck" ]; then
	for i in "${domains[@]}" 
	do
		curl -s http://intodns.com/$i | grep "error.gif" > /dev/null
		if [ $? -gt 0 ]; then
			echo $i: OK
		else
			echo '$i: ERROR (http://intodns.com/$i)'
		fi
		sleep 2
	done
	echo ""
	
fi

if [ "$option" == "pingcheck" ]; then
        for i in "${server[@]}"
        do
                server=`echo $i |  cut -d" " -f2 | cut -d"@" -f2`
		echo $server
		ping -c1 $server > /dev/null 2>&1
		if [ "$?" -lt 1 ]; then
			echo ' -- v4: ONLINE'
		else
			echo ' -- v4: OFFLINE'
		fi
		ping6 -c1 $server > /dev/null 2>&1
		if [ "$?" == "0" ]; then
			echo ' -- v6: ONLINE'
		else
			echo ' -- v6: OFFLINE (or not available)'
		fi
		echo ""
        done
	echo ""
fi

echo "##########################################################"
echo ""
echo "done."

if [[ "$option" != "dnscheck" && "$option" != "pingcheck" ]]; then
	echo "removing ssh key from agent.."
	kill `echo $SSH_AGENT_PID`
	unset SSH_AGENT_PID
	if [ -f /tmp/kupdate.tmp ]; then
		echo "Notifying for Kernel-Update"
		cat /tmp/kupdate.tmp | mail -r root@someserver.com -s "there are needed restarts for some servers" example@example.com
		rm /tmp/kupdate.tmp
	fi
	echo "done."
fi
