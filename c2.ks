install
url --url="http://rhel.example.com/rhel/6.6/os/x86_64/"
reboot --eject
text
lang en_US.UTF-8
keyboard us
network --onboot yes --device eth0 --bootproto static --ip 192.168.1.11 --netmask 255.255.255.0 --gateway 192.168.1.1 --noipv6 --nameserver 192.168.1.1 --hostname c2.dude.localdomain --mtu 9000
network --onboot yes --device eth1 --bootproto static --ip 172.16.0.11 --netmask 255.255.255.0 --mtu 9000 --noipv6
network --onboot no --device eth2 --bootproto static --noipv6
rootpw  --iscrypted $putyourstringhere
firewall --service=ssh
authconfig --enableshadow --passalgo=sha512
selinux --enforcing
timezone --utc America/New_York

bootloader --location=mbr --driveorder=sdb,sdc,sdd --append="crashkernel=auto rhgb quiet" --password=$putyourstringhere
ignoredisk --drives=sda
zerombr
clearpart --all --initlabel --drives=sdb,sdc,sdd
part /boot --fstype=ext4 --size=500
part pv.01 --ondisk=sdb --grow --size=1
part pv.02 --ondisk=sdc --grow --size=1
part pv.03 --ondisk=sdd --grow --size=1
volgroup vg_bootdisk --pesize=4096 pv.01
volgroup vg_brick1 --pesize=4096 pv.02
volgroup vg_brick2 --pesize=4096 pv.03
logvol / --fstype=ext4 --name=lv_root --vgname=vg_bootdisk --size=1 --grow
logvol /gluster/brick1 --bytes-per-inode=512 --fstype=xfs --name=lv_brick1 --vgname=vg_brick1 --size=1 --grow
logvol /gluster/brick2 --bytes-per-inode=512 --fstype=xfs --name=lv_brick2 --vgname=vg_brick2 --size=1 --grow
logvol swap --name=lv_swap --vgname=vg_bootdisk --size=2048

repo --name="RHEL" --baseurl="http://rhel.example.com/rhel/6.6/os/x86_64/"

%packages --nobase
@Core
git
openssh-clients
vim
wget

%post
yum -y install yum-plugin-fastestmirror.noarch
wget -O /etc/sysconfig/iptables "https://raw.githubusercontent.com/mikeSGman/Go-Go-Gadget-Lab/master/stuffToAddLater/iptables"
#wget -O /etc/sysconfig/network-scripts/ifcfg-ib0 "http://mobile.dude.localdomain/pub/configfiles/c1-ifcfg-ib0"
wget -O /root/createGlusterVols.sh "https://raw.githubusercontent.com/mikeSGman/Go-Go-Gadget-Lab/master/stuffToAddLater/createGlusterVols.sh"
wget -O /root/.vimrc --no-check-certificate "https://raw.githubusercontent.com/TheDudesAbide/useful-scripts/master/VIM/vimrc"
mkdir -p /var/lib/glusterd/groups/ && wget -O /var/lib/glusterd/groups/virt "https://github.com/mikeSGman/Go-Go-Gadget-Lab/blob/master/stuffToAddLater/virt"
git clone https://github.com/gmarik/Vundle.vim.git /root/.vim/bundle/Vundle.vim
vim +PluginInstall +qall
ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -N ''
echo "put your ssh key here" >> /root/.ssh/authorized_keys
chmod 0600 /root/.ssh/authorized_keys && restorecon /root/.ssh/authorized_keys
/bin/rm -rf /root/install.log* /root/anaconda-ks.cfg
%end
