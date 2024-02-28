#consider the ports from last rule are NOT inuse on the system. This will trigger and log the attempts to nmap
iptables -A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN,PSH,URG -m limit --limit 3/min -j LOG --log-prefix "Firewall> XMAS scan "
iptables -A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN,SYN,RST,ACK,URG -m limit --limit 3/min -j LOG --log-prefix "Firewall> XMAS-PSH scan "
iptables -A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN,SYN,RST,PSH,ACK,URG -m limit --limit 3/min -j LOG --log-prefix "Firewall> XMAS-ALL scan "
iptables -A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN -m limit --limit 3/min -j LOG --log-prefix "Firewall> FIN scan "
iptables -A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -m limit --limit 3/min -j LOG --log-prefix "Firewall> Null scan "
iptables -A INPUT -p tcp -m multiport --dports 21,23,88,110,135,139,143,161,443,749,995,3306,3389,4444,8004 -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG SYN -m limit --limit 1/min -j LOG --log-prefix "Firewall> SYN scan "
