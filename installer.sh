#!/bin/bash
# Easy TeamSpeak 3 installer for Debian based OS
# Tested on Debian 7/8 and Ubuntu 14.04 LTS

# Check for root account
if [[ "$EUID" -ne 0 ]]; then
  echo "Sorry, you need to run this as root"
  exit 1
fi

# Check supported OS
if [ -e '/etc/redhat-release' ] ; then
  echo 'Error: Sorry, this installer works only on Debian or Ubuntu'
  exit 1
fi

# Get latest TS3 server version
echo "-------------------------------------------------------"
echo "Detecting latest TeamSpeak 3 version, please wait..."
echo "-------------------------------------------------------"
wget 'http://dl.4players.de/ts/releases/?C=M;O=D' -q -O - | grep -i dir | grep -Eo '<a href=\".*\/\">.*\/<\/a>' | grep -Eo '[0-9\.?]+' | uniq | sort -V -r > TS3V
while read ts3version; do
  if [[ "${ts3version}" =~ ^[3-9]+\.[0-9]+\.1[2-9]+\.?[0-9]*$ ]]; then
    wget --spider -q http://dl.4players.de/ts/releases/${ts3version}/teamspeak3-server_linux_amd64-${ts3version}.tar.bz2
  else
    wget --spider -q http://dl.4players.de/ts/releases/${ts3version}/teamspeak3-server_linux-amd64-${ts3version}.tar.gz
  fi
  if [[ $? == 0 ]]; then
    break
  fi
done < TS3V
rm -f TS3V

# Get OS Arch and download correct packages
if [ "$(arch)" != 'x86_64' ]; then
    wget "http://dl.4players.de/ts/releases/"$ts3version"/teamspeak3-server_linux_x86-"$ts3version".tar.bz2" -P /opt/ts3/
else
    wget "http://dl.4players.de/ts/releases/"$ts3version"/teamspeak3-server_linux_amd64-"$ts3version".tar.bz2" -P /opt/ts3/
fi

# Get the internal IP of the server
pvtip=$( ifconfig  | grep 'inet addr:'| grep -v '127.0.0*' | cut -d ':' -f2 | awk '{ print $1}' )

# Get the external public IP of the server
pubip=$( wget -qO- http://ipinfo.io/ip )

# Gives user the internal ip for reference and ask for desired ports
echo "Your private internal IP is: $pvtip"
read -p "Enter Voice Server port [9987]: " vport
while true; do
  if [[ "$vport" == "" ]]; then
    vport="9987"
    break
  elif ! [[ "$vport" =~ ^[0-9]+$ ]] || [[ "$vport" -lt "1" ]] || [[ "$vport" -gt "65535" ]]; then
    echo "Voice Server port invalid."
    read -p "Enter Voice Server port [9987]: " vport
  else
    break
  fi
done

read -p "Enter File Transfer port [30033]: " fport
while true; do
  if [[ "$fport" == "" ]]; then
    vport="30033"
    break
  elif ! [[ "$fport" =~ ^[0-9]+$ ]] || [[ "$fport" -lt "1" ]] || [[ "$fport" -gt "65535" ]]; then
    echo "File Transfer port invalid."
    read -p "Enter File Transfer port [30033]: " fport
  else
    break
  fi
done

read -p "Enter Server Query port [10011]: " qport
while true; do
  if [[ "$qport" == "" ]]; then
    vport="10011"
    break
  elif ! [[ "$qport" =~ ^[0-9]+$ ]] || [[ "$qport" -lt "1" ]] || [[ "$qport" -gt "65535" ]]; then
    echo "Server Query port invalid."
    read -p "Enter Server Query port [10011]: " qport
  else
    break
  fi
done

read -p "Enter Server Query Admin password: " apass


# Install required packages
apt-get update
apt-get install -y sudo telnet bzip2

# Create non-privileged user for TS3 server, and moves home directory under /etc
adduser --disabled-login --gecos "ts3server" ts3

# Extract the contents and give correct ownership to the files and folders
echo "------------------------------------------------------"
echo "Extracting TeamSpeak 3 Server Files, please wait..."
echo "------------------------------------------------------"
tar -xjf /opt/ts3/teamspeak3-server_linux*.tar.bz2 --strip 1 -C /opt/ts3/
rm -f /opt/ts3/teamspeak3-server_linux*.tar.bz2
chown -R ts3:ts3 /opt/ts3/

# Create autostart script
cat > /etc/init.d/teamspeak3 <<"EOF"
#!/bin/sh
### BEGIN INIT INFO
# Provides:          TeamSpeak 3 Server
# Required-Start:    networking
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: TeamSpeak 3 Server Daemon
# Description:       Starts/Stops/Restarts the TeamSpeak 3 Server Daemon
### END INIT INFO

set -e

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DESC="TeamSpeak 3 Server"
NAME=ts3
USER=ts3
DIR=/opt/ts3/
DAEMON=$DIR/ts3server_startscript.sh
SCRIPTNAME=/etc/init.d/$NAME

test -x $DAEMON || exit 0

cd $DIR
sudo -u ts3 ./ts3server_startscript.sh $1
EOF
chmod 755 /etc/init.d/teamspeak3

# Assign right ports and password to TS3 server
sed -i "s/{2}/{4} default_voice_port=$vport query_port=$qport filetransfer_port=$fport filetransfer_ip=0.0.0.0 serveradmin_password=$apass/" /opt/ts3/ts3server_startscript.sh

# Set TS3 server to auto start on system boot
update-rc.d teamspeak3 defaults

# Give user all the information
echo ""
echo ""
clear
echo "TeamSpeak 3 has been successfully installed!"
echo "Voice server is available at $pubip:$vport"
echo "The file transfer port is: $fport"
echo "The server query port is: $qport"
echo ""
read -p "Start the server now? [y/n]: " startopt
sleep 1
if [ "$startopt" == "y" ] || [ "$startopt" == "yes" ]; then
  echo "Please keep the following details safe!"
  sleep 2
  /etc/init.d/teamspeak3 start
else
  echo "Run the following command to manually start the server:"
  echo "/etc/init.d/teamspeak3 start"
fi

exit 0
