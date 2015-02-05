#!/usr/bin/env bash
#Coding: utf-8
#Filename: forwarding.sh
#Date Created: 12 Apr 2014
#Last Modified: 15 Jan 2015 (15:37:47)
#Summary:
#Author: Michael McConachie <dude@thelinuxgeek.us>
#License: GPLv3

##Vars
volName=$1
host1=10.10.0.3
host2=10.10.0.4

## Create blockFS if non-existant
if [[ ! -d /gluster/brick{1,2}/${volName}/ ]]; then mkdir -p /gluster/brick{1,2}/${volName}/; fi

##This utility is written from the perspective of a FIRST TIME only usefulness.
##It assumes that you want to make use of larger inodes and directory superblocks
##for read optimization on the directories, and writes/reads for the datastores
##themselves.

service glusterd stop
umount /gluster/brick*

mkfs.xfs -f -i size=512 -n size=8192 /dev/mapper/vg_brick1-lv_brick1
mkfs.xfs -f -i size=512 -n size=8192 /dev/mapper/vg_brick2-lv_brick2
mount -a

##Remote work to make c2 match c1's gluster volume and FS states.
##These are INTENTIONALLY spaced over several ssh commands for READABILITY.
##If you don't like it, DIYODW.  (Do it your own damn way).
##Salt and pepper to taste.
ssh root@c2 "service glusterd stop;umount /gluster/brick*"
ssh root@c2 "mkfs.xfs -f -i size=512 -n size=8192 /dev/mapper/vg_brick1-lv_brick1"
ssh root@c2 "mkfs.xfs -f -i size=512 -n size=8192 /dev/mapper/vg_brick2-lv_brick2"
ssh root@c2 'mount -a'

#Discover other GlusterFS Server host
gluster peer probe ${host2}
#I use striping for my lab purposes.  Your mileage may vary.  I also use virt flags
#and try to ensure decent caching due to average actively utilized VM footprint deltas.
gluster volume create ${volName} stripe 4 transport tcp ${host1}:/gluster/brick1/${volName}/ ${host2}:/gluster/brick1/${volName}/ ${host1}:/gluster/brick2/${volName}/ ${host2}:/gluster/brick2/${volName}/
gluster volume start ${volName}
gluster volume reset all
gluster volume set ${volName} group virt
gluster volume set ${volName} storage.owner-uid 36  
gluster volume set ${volName} storage.owner-gid 36  
gluster volume set ${volName} nfs.disable off
gluster volume set ${volName} cluster.stripe-coalesce on
gluster volume set ${volName} cluster.server-quorum-type server
gluster volume set ${volName} quorum-type auto
gluster volume info

echo
echo "That's about it, gluster is up and operational on ${host1} and ${host2}"
echo

exit 0
