#!/usr/bin/env bash
#Coding: utf-8
#Filename: foo.sh
#Date Created: 02 Feb 2015
#Last Modified: 02 Feb 2015 (14:38:43)
#Summary:
#Author: Jeff Weatherford <frosty@thelinuxgeek.us>
#License: GPLv3

if [ $# -ne 3 ];
then
         echo "Usage: " $0 " RHN-Username RHN-Password URL-to-RHEVm-answers-file"
         exit 0
fi
USER=$1
PASSWORD=$2
CONFIG=$3

#yes, I know I need to do better error handling...I'll get to it (eventually)

subscription-manager register --username=$USER --password=$PASSWORD

# TO-DO
# intelegently pull valid pool ids.

for i $pool1 $pool2; do subscription-manager attach --pool=$i; done


yum -y install yum-utils vim bind-utils openssh-clients

yum-config-manager --enable rhel-6-server-rpms
yum-config-manager --enable rhel-6-server-supplementary-rpms
yum-config-manager --enable rhel-6-server-rhevm-3.4-rpms
yum-config-manager --enable jb-eap-6-for-rhel-6-server-rpms

yum -y update

yum install rhevm



wget --no-check-certificate $CONFIG 
engine-setup --config-append=rhevm-answers.cfg

