#!/bin/bash

# Flush existing rules and set chain policies setting default drop
iptables -F
iptables -X
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# Allow all loopback (lo0) traffic and drop all traffic to 127/8 that doesn't use lo0
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -d 127.0.0.0/8 -j REJECT

# Accept inbound TCP packets on HTTP(80), HTTPS(443), and SSH(22)
iptables -A INPUT -p tcp --dport 80 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

# Allow established and related incoming connections
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow established outgoing connections
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Outbound DNS
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT

# Outbound HTTP and HTTPS
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT

# Outbound SSH (Remove if your server does not need to initiate SSH connections)
iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT

# Log and drop any other outbound traffic not explicitly allowed
iptables -A OUTPUT -j LOG --log-prefix "IPTables-Dropped: "
iptables -A OUTPUT -j DROP

# Save the iptables rules to ensure they persist after reboot
iptables-save > /etc/iptables/rules.v4

echo "IPTABLES rules set and saved successfully."
