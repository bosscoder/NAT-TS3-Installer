## NAT TS3 Installer
This installer will automatically install TeamSpeak 3 onto your NAT VPS, and automatically configure the ports to the ones you specify.

### How do I install?
To install TeamSpeak 3 automatically, run this command and follow the prompt.

``` wget http://git.io/nat_ts3 --no-check-certificate -O /tmp/nat_ts3.sh && bash /tmp/nat_ts3.sh```

### Requirements
This script will only work on OpenVZ container based VPS due to the fact it only checks for venet ethernet adapter. You can modify the code of this script before you run it if you want to install on a KVM/Xen VPS.

### Will this script work with VPS with dedicated IPs (all ports available)?
Yes, everything will work! Just use 9987 (default port) as your voice server port and 30033 as your file transfer port. Of course if you want custom ports, you can set them to whatever you want as long as you have access to those ports and are opened in your firewall rules.

### I can't remember the port number, help!
You can also set up SVR records with your dns provider so you can use your hostname instead and do not have to remember your port number. For instructions on how to have this set up, please visit the <a href="https://support.teamspeakusa.com/index.php?/Knowledgebase/Article/View/293/12/does-teamspeak-3-support-dns-srv-records" target="_blank">TeamSpeak3 support page</a>.

### Does my server have a license?
No. Only the barebone server will be installed, no license will be included. You can, however, use the server as is for personal usage, up to 32 concurrent clients.<br />
If you need to upload your own license, you can upload your "licensekey.dat" to ```/opt/ts3/``` and enter command ```/etc/init.d/teamspeak3 restart``` for the new license key to take effect.

### Where do I get a server?
This script will run on any vps server as long as it has root and ipv4 access. VPS with NAT'd IPv4 works just as well.<br />
Get a cheap yearly VPS from one of these awesome providers, starting from $2 annually.
##### <a href="https://my.virtwire.com/cart.php?gid=37" target="_blank">VirtWire - as low as $2/year</a>
* Lenoir, US
* Los Angeles, US
* Kansas City, US
* Düsseldorf, DE
* Falkenstein, DE
* Strasbourg, FR
* Stockholm, SE
* St. Peterburg, RU
* Auckland, NZ

##### <a href="https://clients.inceptionhosting.com/cart.php?gid=13&currency=3" target="_blank">Inception Hosting - as low as $2.25/year</a>
* Dallas, US
* Milan, IT
* Tokyo, JP
* Rotterdam, NL
* Phoenix, US
* Singapore, SG
* Maidenhead, UK

##### <a href="https://clients.gestiondbi.com/index.php?/cart/lowendspirit-nat-vps/&step=0&currency=1" target="_blank">Deepnet Solutions - as low as $2.50/year</a>
* Montreal, CA
* New Jersey, US
* Hong Kong, CN
* Johannesburg, ZA

##### <a href="https://quadhost.net/account/cart.php?gid=19" target="_blank">i-38 - as low as £2.50/year</a>
* London, UK
* Roubaix, FR
* Varna, BG
* Falkenstein, DE
* North Carolina, US
* Singapore, SG
* New Delhi, IN

##### <a href="https://secure.ransomit.com.au/console/cart.php?a=add&pid=104" target="_blank">RansomIT - as low as $4.50/year</a>
* Sydney, AU

### More info please.
This script uses init.d, no support for systemd, yet.<br />
Tested on Debian 7 and Ubuntu 14.04 LTS<br />
And don't laugh at my code.
