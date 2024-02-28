#!/bin/bash

# Create a new chain for scan detection
iptables -N SCAN_LOG_DROP

# Log the packet
iptables -A SCAN_LOG_DROP -j LOG --log-prefix "Nmap-Scan-Detected: "

# Drop the packet
iptables -A SCAN_LOG_DROP -j DROP

# Detects a SYN scan (half-open scan)
iptables -A INPUT -p tcp --tcp-flags ALL SYN,ACK -m state --state NEW -j SCAN_LOG_DROP

# Detects a FIN scan
iptables -A INPUT -p tcp --tcp-flags ALL FIN -j SCAN_LOG_DROP

# Detects a Xmas scan
iptables -A INPUT -p tcp --tcp-flags ALL FIN,PSH,URG -j SCAN_LOG_DROP

# Detects a NULL scan
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j SCAN_LOG_DROP

# Detects unusual packets (no SYN flag for a new connection)
iptables -A INPUT -p tcp ! --syn -m state --state NEW -j SCAN_LOG_DROP

echo "Nmap scan detection rules have been added."
