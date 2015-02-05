#!/usr/bin/env bash
#Coding: utf-8
#Filename: rhevm-offline-install-3.4.sh
#Date Created: 02 Feb 2015
#Last Modified: 02 Feb 2015 (09:23:03)
#Summary:
#License: GPLv3
#Usage: #script name RHN-Username RHN-Password

if [ $# -ne 2 ];
then
         echo "Usage: " $0 " RHN-Username RHN-Password "
         exit 0
fi
USER=$1
PASS=$2

#Edit channel list here, in case it changes
CHANLIST="rhel-x86_64-rhev-agent-6-server
rhel-x86_64-rhev-mgmt-agent-6
rhel-x86_64-server-6-rhevh
rhel-x86_64-server-6-rhevm-3.4
jbappplatform-6-x86_64-server-6-rpm
rhel-x86_64-server-supplementary-6
rhel-x86_64-server-v2vwin-6"
echo "Registering to RHN channels..."
for i in $CHANLIST; do
          echo "Registering for $i "
          rhn-channel --user=$USER --password=$PASS -a -c $i
          if [ $? -ne 0 ]; then
          echo "RHN registration error occured, please check your RHN entitlements and credentials.";
                   echo "Verify you have access to the correct channels by running rhn-channel -L"
                    exit 1
          fi
done
echo "Setting up local download directory..."
#mkdir ./local_repo
#cd ./local_repo
echo "Starting package download... This may take a while"
yum clean all

#Edit package list here in case it changes.
#To get only RHEV-M, leave only "rhevm" in the list
dlList="rhevm
rhev-agent
rhev-guest-tools-iso
rhev-hypervisor6
rhev-hypervisor6-tools
fence-agents
vdsm-bootstrap
vdsm-cli
vdsm-hook-vhostmd
vdsm-reg
vdsm
libguestfs-java
libguestfs-mount
libguestfs-winsupport
perl-libguestfs
python-libguestfs
libguestfs
libguestfs-tools
libguestfs-tools-c
perl-Net-Telnet
python-suds
qemu-kvm-tools"

for i in $dlList; do
        echo "Downloading $i"
        yumdownloader $i
        for j in `ls $i*`; do
                echo "Resolving dependencies for package $j"
                rpm -qpR $j | \
                xargs yum whatprovides | \
                grep ' : ' | \
                grep -E '(noarch|x86_64)' | \
                awk '{print $1}' | \
                sed -e 's,^[0-9]*:,,g' -e 's,-[0-9].*,,g' | \
                grep -v ^Repo | \
                sort -u | \
                xargs yumdownloader --resolve
        done

done

echo "Setting up repo..."
yum -y install createrepo
createrepo .
echo "RHEV-Manager offline repository created in " $PWD
cd ..
echo "Generating repo file..."
echo "[rhevm-offline]" > rhevm-offline.repo
echo "name=RHEVM-Offline" >> rhevm-offline.repo
echo "baseurl=file:///rhevm_repo/" >> rhevm-offline.repo
echo "enabled=1" >> rhevm-offline.repo
echo "gpgcheck=1" >> rhevm-offline.repo
echo "rhevm-offline.repo generated."
echo
echo "To set up RHEV-Manager locally, copy the local_repo directory to /rhevm_repo/ on the RHEV-Manager server"
echo "Then copy rhevm-offline.repo to /etc/yum.repos.d/"
echo "Run yum install rhevm and afterwards run rhevm-setup"
echo
exit 0

