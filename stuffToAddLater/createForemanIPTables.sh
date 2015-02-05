#!/usr/bin/env bash
#Coding: utf-8
#Filename: createForemanIPTables.sh
#Date Created: 15 Jan 2015
#Last Modified: 15 Jan 2015 (11:49:14)
#Summary:
#Author: Michael McConachie <dude@thelinuxgeek.us>
#License: GPLv3

##  This file is self explanitory.  It creates the necessary IPT's for
##  a VANILLA Foreman Install, using both UDP and TCP ports to perform
##  the necessary tasks it must while utilizing a firewall.
##  YMMV

for tcpShit in 22 53 80 443 3000 3306 5910-5930 5432 8140 8443
do
	lokkit -p "${tcpShit}":tcp
done


for udpShit in 53 67-69
do
	lokkit -p "${udpShit}":udp
done

service iptables restart
