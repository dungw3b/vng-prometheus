#!/bin/sh
# @dungvv

VER_EXPORTER_MERGE=0.4.0
VER_NODE_EXPORTER=1.0.1
VER_PROC_EXPORTER=0.6.0

OS=`uname`;
CDIR=`pwd`

if [ "$(id -u)" != "0" ]; then
    echo "You must be root to execute the script. Exiting."
    exit 1
fi

show_usage()
{
    printf "Usage: $0 [options]\n"
    printf "\n"
    printf "Options:\n"
    printf " -a|--all, Install all exporters\n"
    printf " -p|--process, Install process exporter\n"
    printf " -h|--help, Help\n"
    exit 0;
}

install_process()
{
    echo "Installing proccess-exporter..."
    /usr/bin/wget --no-check-certificate -O /root/process-exporter-${VER_PROC_EXPORTER}.linux-amd64.tar.gz https://github.com/ncabatoff/process-exporter/releases/download/v${VER_PROC_EXPORTER}/process-exporter-${VER_PROC_EXPORTER}.linux-amd64.tar.gz
    if [ $? -ne 0 ]; then
        echo "Download ERROR!"
        exit 1
    fi

    cd /root && tar -xzf process-exporter-${VER_PROC_EXPORTER}.linux-amd64.tar.gz
    /etc/init.d/process-exporter stop
    mv /root/process-exporter-${VER_PROC_EXPORTER}.linux-amd64/process-exporter /usr/local/bin/process-exporter
    chmod 755 /usr/local/bin/process-exporter
    cd $CDIR
    cp etc/prometheus/process-exporter.yaml /etc/prometheus/process-exporter.yaml
    cp etc/init.d/process-exporter /etc/init.d/process-exporter
    chmod 755 /etc/init.d/process-exporter
    chkconfig --add process-exporter
    chkconfig process-exporter on
    /etc/init.d/process-exporter start
    /etc/init.d/process-exporter status
}


#=========================================#

if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    show_usage
fi

# Get parameters
while [ ! -z "$1" ]; do
    case "$1" in
        -a|--all)
            shift
            INSTALL="ALL"
            ;;
        -p|--process)
            shift
            INSTALL="PROCESS"
            ;;
    esac
shift
done


#=========================================#

if [ ! -e /usr/bin/wget ]; then
    yum -y install wget
fi

mkdir /etc/prometheus

# Install node-exporter
echo "Installing node-exporter..."

/usr/bin/wget --no-check-certificate -O /root/node_exporter-${VER_NODE_EXPORTER}.linux-amd64.tar.gz  https://github.com/prometheus/node_exporter/releases/download/v${VER_NODE_EXPORTER}/node_exporter-${VER_NODE_EXPORTER}.linux-amd64.tar.gz
if [ $? -ne 0 ]; then
    echo "Download ERROR!"
    exit 1
fi

cd /root && tar -xzf node_exporter-${VER_NODE_EXPORTER}.linux-amd64.tar.gz
/etc/init.d/node-exporter stop
mv /root/node_exporter-${VER_NODE_EXPORTER}.linux-amd64/node_exporter /usr/local/bin/node-exporter
chmod 755 /usr/local/bin/node-exporter
cd $CDIR
cp etc/init.d/node-exporter /etc/init.d/node-exporter
chmod 755 /etc/init.d/node-exporter
chkconfig --add node-exporter
chkconfig node-exporter on
/etc/init.d/node-exporter start
/etc/init.d/node-exporter status

if [ "$INSTALL" = "PROCESS" ] || [ "$INSTALL" = "ALL" ]; then
    install_process
fi


# Install exporter-merge
echo "Installing exporter-merge..."
systemctl stop exporter-merge.service

/usr/bin/wget --no-check-certificate -O /usr/local/bin/exporter-merger  https://github.com/rebuy-de/exporter-merger/releases/download/v${VER_EXPORTER_MERGE}/exporter-merger-v${VER_EXPORTER_MERGE}.dirty-linux-amd64
if [ $? -ne 0 ]; then
    echo "Download ERROR!"
    exit 1
fi

chmod 755 /usr/local/bin/exporter-merger
cd $CDIR
cp etc/prometheus/exporter-merge.yaml /etc/prometheus/exporter-merge.yaml
cp etc/init.d/exporter-merger /etc/init.d/exporter-merger
chmod 755 /etc/init.d/exporter-merger
chkconfig --add exporter-merger
chkconfig exporter-merger on
/etc/init.d/exporter-merger start
/etc/init.d/exporter-merger status
