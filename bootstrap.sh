#!/usr/bin/env bash
set -Eeux
set -o posix
set -o pipefail

declare -r guest_log="/vagrant/guest_logs/vagrant_mmc_bootstrap.log"
declare -r alpha_data_dir="/home/vagrant/.alpha"

echo "$0 will append logs to $guest_log"
echo "Bootstrap starts at "`date`
bootstrap_start=`date +%s`

mkdir -p "$(dirname "$guest_log")"

declare -r exe_name="$0"
echo_log() {
    local log_target="$guest_log"
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] $exe_name: $@" >> $log_target
}

echo_log "start"
echo_log "uname: $(uname -a)"
echo_log "current procs: $(ps -aux)"
echo_log "current df: $(df -h /)"

# add 2G swap to avoid arround annoying ENOMEM problems (does not persist across reboot)
echo_log "create swap"
mkdir -p /var/cache/swap/
dd if=/dev/zero of=/var/cache/swap/swap0 bs=1M count=2048
chmod 0600 /var/cache/swap/swap0
mkswap /var/cache/swap/swap0
swapon /var/cache/swap/swap0

# baseline system prep
echo_log "base system update"
apt-get -y update
apt-get -y install vim

# Git for installing elements alpha, lightning
apt-get -y install git

# Google Protocol buffers - this is how lightning messages are serialized for sending on the wire
apt-get -y install protobuf-c-compiler libprotobuf-dev

# Open SSL dev libraries
apt-get -y install libssl-dev

# Autoreconf
apt-get -y install dh-autoreconf

# libdb_cxx - required for Alpha
apt-get -y install libdb++-dev

# Boostlib - required for Alpha
apt-get -y install libboost-all-dev

# pkg-config - required for Alpha
apt-get -y install pkg-config

# Get and build Alpha
echo_log "Install alpha from source"
git clone https://github.com/ElementsProject/elements
cd elements
git checkout alpha
./autogen.sh && ./configure --with-incompatible-bdb && make && make install

# Make alpha data directory
mkdir "$alpha_data_dir"
chown -R vagrant:vagrant "$alpha_data_dir"
sudo -u vagrant cp /vagrant/conf/bitcoin.conf "$alpha_data_dir"

# Get and build protobuf
echo_log "Install protobuf from source"
cd ~vagrant
wget https://github.com/google/protobuf/releases/download/v2.6.1/protobuf-2.6.1.tar.gz
tar -vxf protobuf-2.6.1.tar.gz
cd protobuf-2.6.1
./autogen.sh && ./configure && make && make install

ldconfig

# Get and build protobuf-c
echo_log "Install protobuf-c from source"
cd ~vagrant
wget https://github.com/protobuf-c/protobuf-c/releases/download/v1.1.1/protobuf-c-1.1.1.tar.gz
tar -vxf protobuf-c-1.1.1.tar.gz
cd protobuf-c-1.1.1
./configure && make && make install

# Get and build lightning
#echo_log "Get and install lightning"
#cd ~vagrant
#sudo -u vagrant -H git clone https://github.com/ElementsProject/lightning.git
#cd lightning
#sudo -u vagrant -H make

# Build lightning
echo_log "Get and install lightning"
sudo -u vagrant -H ln -s ~vagrant/lightning /vagrant_lightning
cd ~vagrant/lightning
sudo -u vagrant -H make clean
sudo -u vagrant -H make

# add blockchain tools to path
#sudo -u vagrant mkdir -p /home/vagrant/tools
#sudo -u vagrant cp /vagrant/tools/* /home/vagrant/tools
#echo '' >> /home/vagrant/.bashrc
#echo '# add blockchain tools to path' >> /home/vagrant/.bashrc
#echo 'PATH=$PATH:/home/vagrant/tools' >> /home/vagrant/.bashrc

echo_log "complete"
echo "Bootstrap ends at "`date`
bootstrap_end=`date +%s`
echo "Bootstrap execution time is "$((bootstrap_end-bootstrap_start))" seconds"
echo "$0 all done!"