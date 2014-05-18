#!/bin/bash

HDIR=`pwd`
if [[ $HDIR != "/root" ]]; then
#ENDPROC=`cat /etc/security/limits.conf | grep "@irc" | grep nproc | awk {'print $4'}`
#ENDSESSION=`cat /etc/security/limits.conf | grep "@irc" | grep maxlogins | awk {'print $4'}`
PRIVLAGED="Regular User"
else
#ENDPROC=`cat /etc/security/limits.conf | grep "*" | grep nproc | awk {'print $4'}`
#ENDSESSION="Unlimited"
PRIVLAGED="Administrative User"
fi 

# Konvertieren der Uptime und Ausgabe Variable definieren
let upSeconds="$(/usr/bin/cut -d. -f1 /proc/uptime)"
let secs=$((${upSeconds}%60))
let mins=$((${upSeconds}/60%60))
let hours=$((${upSeconds}/3600%24))
let days=$((${upSeconds}/86400))
UPTIME=`printf "%d days, %02dh%02dm%02ds" "$days" "$hours" "$mins" "$secs"`

# Get Load Average
read one five fifteen rest < /proc/loadavg

# Get Memory Amount and Free Memory
MEMTOTAL=`cat /proc/meminfo | grep MemTotal | awk {'print $2'}`
MEMTOTAL=$(( $MEMTOTAL/1024 ))
MEMFREE=`cat /proc/meminfo | grep MemFree | awk {'print $2'}`
MEMFREE=$(( $MEMFREE/1024 ))
MEMMORY="$MEMFREE MB (Free) / $MEMTOTAL MB (Total)"

# Get the first IP Address
IP1="`/sbin/ifconfig eth0 | grep "inet addr" | cut -d ":" -f 2 | cut -d " " -f 1`"
 

# Getting the IPv6 Address
V6="`ip addr show dev eth0 | grep 2a01 | sed -e's/^.*inet6 \([^ ]*\)\/.*$/\1/;t;d'`"


# Getting the Kernel Name
KERNEL="`uname -r`"


# Getting the Username
USER="`whoami`"


# Getting the amount of running processes
PROCESSES="`ps ax | wc -l | tr -d " "`"


# Generating the Date + Time 
DATETIME="`date +"%A, %e %B %Y, %r"`"


# Getting Disk Space Usage
DISCHDD="`df -h | grep rootfs | awk '{print $5 }'`"


# Getting Login Sessions
USERS="`users | wc -w`"


# Getting CPU Usage
CPU="`top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}'`"

# Get CPU Info
CPUMHZ=`cat /proc/cpuinfo | grep "cpu MHz" | awk {'print $4'} | cut -d"." -f1`
CPUGHZ=$(($CPUMHZ / 100))
CPUGHZ=`echo $CPUGHZ | sed -e :a -e 's/\(.*[0-9]\)\([0-9]\{1\}\)/\1.\2/;ta'`
CPUINFO=`cat /proc/cpuinfo | grep processor | wc -l`x`cat /proc/cpuinfo | grep "model name" | cut -d":" -f2`

echo -e "\e[0m"
echo -e "\e[1;34m$DATETIME"
echo -e ""
echo -e "\e[1;32m +++++++++++++++++: System Data :+++++++++++++++++++"
echo -e ""
echo -e "\e[0;93m+ Hostname                   = `hostname`"
echo -e "+ IPv4-Adresse               = $IP1"
echo -e "+ IPv6-Adresse               = $V6"
echo -e "+ Kernel                     = $KERNEL"
echo -e "+ Uptime                     = ${UPTIME}"
echo -e "+ CPU                        = $CPUINFO @ $CPUGHZ GHz"
echo -e "+ Memory                     = $MEMMORY"
echo -e "+ Load Average               = ${one}, ${five}, ${fifteen} (1, 5, 15 min)"
echo -e "+ Running Processes          = $PROCESSES"
echo -e "+ Disc Usage HDD             = $DISCHDD"
echo -e "+ CPU Usage                  = $CPU%"
echo -e "+ Currently Logged in Users  = $USERS "
echo -e "+ Username                   = $USER"
echo -e "+ Privilages                  = $PRIVLAGED"
echo -e "\e[0m"
echo -e "\e[1;32m +++++++++++: Maintenance Information :+++++++++++++"
echo -e "\e[0m"
echo -e "\e[0;93m+ `cat /etc/motd-maint`"
echo -e "\e[1;32m"
echo -e " +++++++++++++++++++++++++++++++++++++++++++++++++++"
echo -e "\e[0m"
