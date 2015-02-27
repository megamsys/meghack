#!/bin/bash

#MASTER SERVER
sudo apt-get -y update

sudo apt-get -y --force-yes install build-essential openssl libreadline6 libreadline6-dev zlib1g zlib1g-dev libssl1.0.0 libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion

sudo apt-get -y install  git-core curl bundler rake zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libxslt1-dev libcurl4-openssl-dev python-software-properties ruby2.0 ruby2.0-dev wbritish wamerican

sudo apt-get -y install build-essential autoconf libtool make lvm2 ssh iproute iputils-arping 

wget -q -O- http://downloads.opennebula.org/repo/Ubuntu/repo.key | apt-key add -

echo "deb http://downloads.opennebula.org/repo/4.10/Ubuntu/14.04 stable opennebula" > /etc/apt/sources.list.d/opennebula.list

sudo apt-get -y update
sudo apt-get -y install opennebula opennebula-sunstone

sudo apt-get -y install ntp


#To Remove prompt
sudo rm /usr/share/one/install_gems
wget -O /usr/share/one/install_gems https://raw.githubusercontent.com/megamsys/cloudinabox/master/conf/trusty/opennebula/install_gems

sudo chmod 755 /usr/share/one/install_gems

sudo /usr/share/one/install_gems sunstone

ip() {
while read Iface Destination Gateway Flags RefCnt Use Metric Mask MTU Window IRTT; do
		[ "$Mask" = "00000000" ] && \
		interface="$Iface" && \
		ipaddr=$(LC_ALL=C /sbin/ip -4 addr list dev "$interface" scope global) && \
		ipaddr=${ipaddr#* inet } && \
		ipaddr=${ipaddr%%/*} && \
		break
	done < /proc/net/route
}



ip
#Add ip and port of sunstone-server in conf
sed -i "s/^[ \t]*:host:.*/:host: $ipaddr/" /etc/one/sunstone-server.conf

#Edit clone file for scp problem
#sed -i '/SRC=$1/a SRC=${SRC#*:}' /var/lib/one/remotes/tm/ssh/clone


service_restart() {
sunstone-server restart
econe-server restart
occi-server restart
onegate-server restart
sudo -H -u oneadmin bash -c "one restart"
sudo service opennebula restart
}

service_restart

#ONE_HOST SERVER

sudo apt-get -y install qemu-system-x86 qemu-kvm cpu-checker

sudo -H -u oneadmin bash -c "cat > //var/lib/one/.ssh/ssh_config <<EOF
ConnectTimeout 5
Host *
StrictHostKeyChecking no
EOF"

sudo -H -u oneadmin bash -c 'cp /var/lib/one/.ssh/id_rsa.pub /var/lib/one/.ssh/authorized_keys'

sudo apt-get -y install build-essential genromfs autoconf libtool qemu-utils libvirt0 bridge-utils lvm2 ssh iproute iputils-arping make

sudo apt-get -y install opennebula-node

sudo -H -u oneadmin bash -c 'onehost create $ipaddr -i kvm -v kvm -n dummy'





