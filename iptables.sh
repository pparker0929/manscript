#!/bin/sh

apt-get install iptables 
iptables -F
# To Block Incoming traffic from a specific ip address see below
# iptables -A INPUT -s XXX.XXX.XXX.XXX -j DROP
# To Accept Incoming traffic from a specific ip address see below
# Replace the previous command with -j ACCEPT
# To Block Output traffic to a specific ip address see below
# iptables -A OUTPUT -d XXX.XXX.XXX.XXX -j DROP
# To Accept Output traffic to a specific ip address see below
# Replace the previous command with -j ACCEPT
# To Block an IP Range see below
# iptables -A INPUT -s XXX.XXX.XXX.0/24 -j DROP
# To Accept an IP Range see below
# Replace the previous command with -j ACCEPT
# To Disable PING see below
# iptables -I INPUT -i ech0 -p icmp -s 0/0 -d 0/0 -j DROP
# To Enable PING see below
# iptables -I INPUT -i ech0 -p icmp -s 0/0 -d 0/0 -j ACCEPT

# Adjust the following IPs for ADS, Windows, PaloAlto
#iptables -A INPUT -s 172.20.XXX.254 -j ACCEPT
#iptables -A INPUT -s 172.20.XXX.100 -j ACCEPT
#iptables -A INPUT -s 172.20.XXX.200 -j ACCEPT
#iptables -A INPUT -s 172.20.XXX.0/24 -j DROP
iptables -N LOGGING
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j LOGGING
iptables -A INPUT -p tcp ! --syn -m state --state NEW -j LOGGING
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j LOGGING
iptables -A INPUT -p tcp -m tcp --tcp-flags RST RST -m limit --limit 2/second --limit 2/second --limit-burst 2 -j LOGGING
iptables -A INPUT -p tcp --tcp-flags ALL FIN,URG,PSH -j LOGGING
iptables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j LOGGING
iptables -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j LOGGING
iptables -A INPUT -m recent --name portscan --rcheck --seconds 86400 -j LOGGING
iptables -A FORWARD -m recent --name portscan --rcheck --seconds 86400 -j LOGGING
iptables -A INPUT -p tcp -m tcp --dport 139 -m recent --name portscan --set -j LOG --log-prefix "portscan:"
iptables -A INPUT -p tcp -m tcp --dport 139 -m recent --name portscan --set -j LOGGING
iptables -A FORWARD -p tcp -m tcp --dport 139 -m recent --name portscan --set -j LOG --log-prefix "portscan:"
iptables -A FORWARD -p tcp -m tcp --dport 139 -m recent --name portscan --set -j LOGGING
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 80 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 443 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --dport 53 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 53 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -I INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -P OUTPUT ACCEPT
iptables -A INPUT -j LOGGING
iptables -A LOGGING -m limit --limit 2/min -j LOG --log-prefix "IPTables-Dropped: " --log-level 4
iptables -A LOGGING -j DROP
#The following two lines do not work in Ubuntu
#service iptables save
#service iptables restart
#Use these instead
apt-get install iptables-persistent
iptables-save > /home/sysadmin/Conf/iptables.rules

exit 0;
