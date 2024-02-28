#!/bin/bash

# Function to install and configure SELinux for CentOS/RHEL
install_configure_selinux() {
    echo "Installing and configuring SELinux..."
    # Install SELinux if not already installed (this might be redundant as SELinux is usually pre-installed on CentOS/RHEL)
    sudo yum install -y selinux-policy selinux-policy-targeted
    sudo yum install -y setroubleshoot setools

    # Ensure SELinux is enabled and set to enforcing mode
    sudo setenforce 1
    sudo sed -i 's/^SELINUX=.*$/SELINUX=enforcing/' /etc/selinux/config
    echo "SELinux has been configured to enforcing mode."
}

# Function to install and configure AppArmor for Debian/Ubuntu
install_configure_apparmor() {
    echo "Installing and configuring AppArmor..."
    # Install AppArmor if not already installed
    sudo apt-get install -y apparmor apparmor-utils

    # Ensure AppArmor is enabled
    sudo systemctl enable apparmor
    sudo systemctl start apparmor
    echo "AppArmor has been installed and started."
}

# Detect the Linux distribution and version, then configure the appropriate tool
echo "Detecting Linux distribution..."

DISTRO=$(awk -F= '/^NAME/{print $2}' /etc/os-release)

if [[ $DISTRO == *"CentOS"* ]] || [[ $DISTRO == *"Red Hat"* ]]; then
    echo "CentOS/RHEL detected."
    if ! [ -x "$(command -v getenforce)" ]; then
        install_configure_selinux
    else
        echo "SELinux is already installed."
    fi
elif [[ $DISTRO == *"Ubuntu"* ]] || [[ $DISTRO == *"Debian"* ]]; then
    echo "Debian/Ubuntu detected."
    if ! [ -x "$(command -v aa-status)" ]; then
        install_configure_apparmor
    else
        echo "AppArmor is already installed."
    fi
else
    echo "Unsupported Linux distribution. Neither SELinux nor AppArmor will be configured."
fi

# Reminder: The script does not handle advanced SELinux or AppArmor policy configuration.
echo "Basic security module setup completed. Please consider configuring detailed policies based on your specific requirements."
