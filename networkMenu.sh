#!/bin/bash
#This script was made of Håvard Moås , and were made for fun.
#It finds your standard gateway ip, public ip, isp.
#It can also scan the most interesting ports on the network, check internet speed, fast access to traceroute, print out the Wifi network close to you and their channel and check the OS of devices connected to your network.

#Find gateway ip address
b=$(nmcli dev list iface wlan0 | grep IP4.DNS)
gw=$(echo $b | awk -F':' '{print $2}')
#Find public ip address
pubip=$(wget -qO- http://ipecho.net/plain)

#Get working directory
dirString="$(readlink -f $0)"
dir=$(echo $dirString | awk -F'networkMenu.sh' '{print $1}')

#Find out what kind of  internet service provider that provides the internet
ispString=$(timeout -sHUP 4s python $dir/speedtest-cli/speedtest_cli.py  | grep 'Testing from')
ispAndIP=$(echo $ispString | awk -F'Testing from' '{print $2}')
isp=$(echo $ispAndIP | awk -F'(' '{print $1}')

echo '
\033[4m\033[1mN E T W O R K   M E N U:\033[0m

\033[1mS E T T I N G S :\033[0m
Standard Gateway IP-Address: \033[93m'$gw '\033[0m
Public IP-Address: \033[93m' $pubip' \033[0m
Internet Service Provider: \033[93m'$isp' \033[0m

\033[1mO P T I O N S : \033[0m
\033[92m1)\033[0m Print Channel and ESSID of all avaiable networks in range.
\033[92m2)\033[0m Check OS on all devices on the current network. (\033[91mRoot required\033[0m)
\033[92m3)\033[0m Traceroute (Hostname input required)
\033[92m4)\033[0m Scan the 10 most interesting ports on your network.
\033[92m5)\033[0m Check internet download and upload speed.

Please choose a option:'
read n
case $n in
    1) echo 'Avaiable networks ESSID and Channel:';
	GREP_COLORS='mt=01;32'; 
	router=$(sudo iwlist wlan0 scan | egrep --color=always 'Channel:|ESSID:');
       printf "%s \n" "$router";;
    2) sudo nmap -F -O $gw-255 | egrep "Nmap scan report for|Running:";;
    3) echo 'Enter a hostname:';
       read m;
       traceroute $m;;
    4) nmap --top-ports 10 $gw;;
    5) GREP_COLORS='mt=01;32';
	info=$(python $dir/speedtest-cli/speedtest_cli.py | egrep --color=always 'Download:|Upload:');
       echo $info;;
    *) invalid option;;
esac
echo
