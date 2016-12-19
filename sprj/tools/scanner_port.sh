#!/bin/bash
file="/home/interface/nmap_open_port/open_""$1"".txt"
count=0

if [ ! -f "$file" ]; then
	touch "$file"
fi

nmap -p $1 $2 | awk '{print NR,$0}' > g
awk '$3=="open" {print $1=$1-3}' g > t

for i in `cat t`
do
	awk '$1=="'$i'" { $1="'$1'";print $0}' g >> $file
	let count+=1
done
echo "$1"" port open number:""$count"
rm g --force
rm t --force


