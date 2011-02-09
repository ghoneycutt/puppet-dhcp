#!/bin/bash

while read line
do
  hostname=$(echo $line | awk '{print $1}')
  mac=$(echo $line | awk '{print $3}')
  ip=$(echo $line | awk '{print $4}')

cat << HOSTENTRY
host $hostname {
  option host-name $hostname;
  hardware ethernet $mac;
  fixed-address $ip;
}
HOSTENTRY
done < $1
exit 0
