#!/bin/bash

# Function to install ModSecurity and configure OWASP CRS for Apache
install_modsecurity_apache() {
    echo "Installing ModSecurity for Apache..."
    sudo apt-get install -y libapache2-mod-security2
    sudo a2enmod security2

    # Configure OWASP CRS
    echo "Configuring OWASP CRS for Apache..."
    sudo git clone https://github.com/coreruleset/coreruleset.git /usr/share/modsecurity-crs
    sudo mv /usr/share/modsecurity-crs/crs-setup.conf.example /usr/share/modsecurity-crs/crs-setup.conf
    echo 'IncludeOptional /usr/share/modsecurity-crs/crs-setup.conf' | sudo tee -a /etc/apache2/mods-available/security2.conf
    echo 'IncludeOptional /usr/share/modsecurity-crs/rules/*.conf' | sudo tee -a /etc/apache2/mods-available/security2.conf

    sudo systemctl restart apache2
}

# Function to install ModSecurity and configure OWASP CRS for Nginx
install_modsecurity_nginx() {
    echo "Installing ModSecurity for Nginx..."
    sudo apt-get install -y nginx-modsecurity

    # Configure OWASP CRS
    echo "Configuring OWASP CRS for Nginx..."
    sudo git clone https://github.com/coreruleset/coreruleset.git /usr/share/nginx/modsecurity-crs
    sudo mv /usr/share/nginx/modsecurity-crs/crs-setup.conf.example /usr/share/nginx/modsecurity-crs/crs-setup.conf
    # Include the OWASP CRS in the Nginx configuration (This may need to be adjusted based on your Nginx setup)
    echo 'Include /usr/share/nginx/modsecurity-crs/crs-setup.conf;' | sudo tee -a /etc/nginx/nginx.conf
    echo 'Include /usr/share/nginx/modsecurity-crs/rules/*.conf;' | sudo tee -a /etc/nginx/nginx.conf

    sudo systemctl restart nginx
}

# Function to configure ModSecurity for Lighttpd (Simplified approach, as Lighttpd has limited ModSecurity support)
install_modsecurity_lighttpd() {
    echo "ModSecurity configuration for Lighttpd is not directly supported. Please manually configure or consider using a supported web server."
}

# Function to install and configure Suricata in IPS mode
install_suricata_ips() {
    echo "Installing Suricata..."
    sudo apt-get install -y suricata
    sudo suricata-update
    echo "Configuring iptables for Suricata IPS mode..."
    sudo iptables -I INPUT -j NFQUEUE
    sudo iptables -I OUTPUT -j NFQUEUE
    sudo iptables -I FORWARD -j NFQUEUE
    sudo systemctl enable suricata
    sudo systemctl start suricata
}

# Detect the web server and environment
WEB_SERVER=""
ENVIRONMENT="plain" # default to plain

# Check for Apache, Nginx, or Lighttpd
if systemctl is-active --quiet apache2; then
    WEB_SERVER="apache"
elif systemctl is-active --quiet nginx; then
    WEB_SERVER="nginx"
elif systemctl is-active --quiet lighttpd; then
    WEB_SERVER="lighttpd"
fi

# Check for Docker and Kubernetes environment
if [ -f /.dockerenv ]; then
    ENVIRONMENT="docker"
elif [ -n "$(kubectl get nodes 2>/dev/null)" ]; then
    ENVIRONMENT="kubernetes"
fi

echo "Detected web server: $WEB_SERVER"
echo "Detected environment: $ENVIRONMENT"

# Update system packages
echo "Updating system packages..."
sudo apt-get update && sudo apt-get upgrade -y

# Install Suricata in IPS mode
install_suricata_ips

# Install ModSecurity based on detected web server
case "$WEB_SERVER" in
    apache)
        install_modsecurity_apache
        ;;
    nginx)
        install_modsecurity_nginx
        ;;
    lighttpd)
        install_modsecurity_lighttpd
        ;;
    *)
        echo "No supported web server detected. Skipping ModSecurity installation."
        ;;
esac

# Note: This script does not fully configure ModSecurity for Lighttpd or handle Docker/Kubernetes specifics beyond detection.
# Further customization and manual configuration will be required for production environments.

echo "Installation and basic configuration completed."
