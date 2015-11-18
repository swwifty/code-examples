#!/bin/bash
#
#  Use this script to grab the primary IP address of multiple machines at once from fleet
#  This is handy for when doing maintenance on a VM host, and you need to determine the primary IP of the VMs on the host.
#  At that point you can take the IPs, and determine if they are in a LB, or hosting a database, etc.
#

# Set the path to your home directory here (This must contain the servers.txt file, and the fleetutil repo)
HOME=/Users/davidgottschalk

# Input file of servers to lookup primary IPs (seperated by new line)
hosts="$HOME/scripts/servers.txt"

# Read the file into an array named servers
index=0
while read line ; do
        servers[$index]="$line"
        index=$(($index+1))
done < $hosts

# Loop through each server in the array and find the primary ip, and print it out with the server name.
# Note if a IP address is not display for a particular host, it likely means that the server name does not match up in fleet
for i in "${servers[@]}"
do
   output=$($HOME/fleetutil/fleet info $i 2>&1 | grep Primary: | awk '{ print $2 }')
   echo "$i:$output"
done
