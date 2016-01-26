#!/bin/bash
# Easy TeamSpeak 3 installer for Debian based OS
# TeamSpeak 3 server version 3.0.11.4
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

# Get the internal IP of the server
ifconfig | grep venet0:0 -A 1 | grep inet | awk '{print $2}' | sed -e 's/addr://g' > private_ip
pvtipfile=private_ip
read -d $'\x04' pvtip < "$pvtipfile"
rm -f private_ip

# Get the external public IP of the server
wget http://ipinfo.io/ip -qO public_ip
pubipfile=public_ip
read -d $'\x04' pubip < "$pubipfile"
rm -f public_ip

# Gives user the internal ip for reference and ask for desired ports
echo "Your private internal IP is: $pvtip"
read -p "Enter desired Voice Server port: " vport
read -p "Enter desired File Transfer port: " fport
read -p "Enter desired Server Query Admin password: " apass

# Install required packages
apt-get update
apt-get install sudo telnet -y

# Create non-privileged user for TS3 server, and moves home directory under /etc
adduser --disabled-login --gecos "" ts3
usermod -md /etc/ts3/ ts3

# Get OS Arch and download correct packages
if [ "$(arch)" != 'x86_64' ]; then
    wget http://dl.4players.de/ts/releases/3.0.11.4/teamspeak3-server_linux-x86-3.0.11.4.tar.gz -P /etc/ts3/
else
    wget http://dl.4players.de/ts/releases/3.0.11.4/teamspeak3-server_linux-amd64-3.0.11.4.tar.gz -P /etc/ts3/
fi

# Extract the contents and give correct ownership to the files and folders
tar -xvzf /etc/ts3/teamspeak3-server_linux*.tar.gz --strip 1 -C /etc/ts3/
rm -f /etc/ts3/teamspeak3-server_linux*.tar.gz
chown -R ts3:ts3 /etc/ts3/

# Create autostart script
touch /etc/init.d/teamspeak3
echo '#!/bin/sh' > /etc/init.d/teamspeak3
echo '### BEGIN INIT INFO' >> /etc/init.d/teamspeak3
echo '# Provides:          teamspeak' >> /etc/init.d/teamspeak3
echo '# Required-Start:    networking' >> /etc/init.d/teamspeak3
echo '# Required-Stop:' >> /etc/init.d/teamspeak3
echo '# Default-Start:     2 3 4 5' >> /etc/init.d/teamspeak3
echo '# Default-Stop:      S 0 1 6' >> /etc/init.d/teamspeak3
echo '# Short-Description: TeamSpeak 3 Server Daemon' >> /etc/init.d/teamspeak3
echo '# Description:       Starts/Stops/Restarts the TeamSpeak 3 Server Daemon' >> /etc/init.d/teamspeak3
echo '### END INIT INFO' >> /etc/init.d/teamspeak3
echo '' >> /etc/init.d/teamspeak3
echo 'set -e' >> /etc/init.d/teamspeak3
echo '' >> /etc/init.d/teamspeak3
echo 'PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin' >> /etc/init.d/teamspeak3
echo 'DESC="TeamSpeak 3 Server"' >> /etc/init.d/teamspeak3
echo 'NAME=ts3' >> /etc/init.d/teamspeak3
echo 'USER=ts3' >> /etc/init.d/teamspeak3
echo 'DIR=/etc/ts3/' >> /etc/init.d/teamspeak3
echo 'DAEMON=$DIR/ts3server_startscript.sh' >> /etc/init.d/teamspeak3
echo 'SCRIPTNAME=/etc/init.d/$NAME' >> /etc/init.d/teamspeak3
echo '' >> /etc/init.d/teamspeak3
echo 'test -x $DAEMON || exit 0' >> /etc/init.d/teamspeak3
echo '' >> /etc/init.d/teamspeak3
echo 'cd $DIR' >> /etc/init.d/teamspeak3
echo 'sudo -u ts3 ./ts3server_startscript.sh $1' >> /etc/init.d/teamspeak3
chmod 755 /etc/init.d/teamspeak3

# Assign right ports and password to TS3 server
sed -i "s/{2}/{4} default_voice_port=$vport filetransfer_port=$fport filetransfer_ip=0.0.0.0 serveradmin_password=$apass/" /etc/ts3/ts3server_startscript.sh

# Set TS3 server to auto start on system boot
update-rc.d teamspeak3 defaults

# Give user all the information
echo ""
echo ""
clear
echo "TeamSpeak 3 has been successfully installed!"
echo "Voice server is available at $pubip:$vport"
echo "Your file transfer port is: $fport"
echo ""
read -p "Start the server now? [y/n]: " startopt
sleep 1
if [ "$startopt" == "y" ] || [ "$startopt" == "yes" ]; then
  echo "Please keep the following details safe!"
  /etc/init.d/teamspeak3 start
else
  echo "Run the following command to manually start the server:"
  echo "/etc/init.d/teamspeak3 start"
fi

exit 0
