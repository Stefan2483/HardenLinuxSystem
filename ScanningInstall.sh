# Scripts for scanning linux systems

#Download Lynis
 git clone https://github.com/CISOfy/lynis
 #Run Lynis
  cd lynis && ./lynis audit system

#Download and install chkrootkit
# https://github.com/installation/chkrootkit/tree/master
wget https://raw.githubusercontent.com/installation/chkrootkit/master/install.sh
# Run with install.sh YOUR@EMAIL.COM

#Download and install rkhunter:
sudo apt install rkhunter   # [On Debian systems]
sudo yum install rkhunter   # [On RHEL systems] 

#Run rkhunter:
sudo rkhunter -c
 
