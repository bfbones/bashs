#!/bin/bash
echo $1
read -p 'Kernel-update? (y, N)' kupdate
if [ "$kupdate" == "y" ]; then
	echo "Kernel-Update on $1 ." >> /tmp/kupdate.tmp
fi
