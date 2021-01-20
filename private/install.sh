#!/bin/sh
# @jun

VER_NODE_EXPORTER=1.0.1

OS=`uname`;
CDIR=`pwd`

if [ "$(id -u)" != "0" ]; then
    echo "You must be root to execute the script. Exiting."
    exit 1
fi


# Install node-exporter
echo "Installing node-exporter..."

cd /root
/usr/bin/wget https://github.com/prometheus/node_exporter/releases/download/v${VER_NODE_EXPORTER}/node_exporter-${VER_NODE_EXPORTER}.linux-amd64.tar.gz
if [ $? -ne 0 ]; then
    echo "Download ERROR!"
    exit 1
fi

tar -xzf node_exporter-${VER_NODE_EXPORTER}.linux-amd64.tar.gz
systemctl stop node_exporter.service
mv /root/node_exporter-${VER_NODE_EXPORTER}.linux-amd64/node_exporter /usr/local/bin/node_exporter
chmod 755 /usr/local/bin/node_exporter
cd $CDIR
cp node_exporter.service /lib/systemd/system/node_exporter.service 
systemctl daemon-reload
systemctl enable node_exporter.service
systemctl restart node_exporter.service
systemctl status node_exporter.service

