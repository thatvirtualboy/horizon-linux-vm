#! /bin/bash
#
# Horizon Optimizer for Ubuntu by Ryan Klumph
# Version: RC2
# Please report any issues to Ryan on Twitter (@thatvirtualboy)
# Changelog and source available at https://github.com/thatvirtualboy/horizon-linux-vm
# www.thatvirtualboy.com

# Check for root
if [ "$(whoami)" != "root" ]; then
   echo
   echo -e "\e[31mOops! You must be root to continue! \n\e[0mPlease type: \e[36msu root -c ./horizon-optimizer.sh\e[0m"
   echo
   exit 1
fi

clear
echo "+--------------------------------------------------------------------+"
echo "| This script will configure your Ubuntu Template for Horizon 7      |"
echo "| It will also do the following:                                     |"
echo "|                                                                    |"
echo "| - Install Open VM Tools                                            |"
echo "| - Optimize a Desktop Environment                                   |"
echo "| - Set new passwords to UNIX (viewadmin)                            |"
echo "| - Install Horizon Agent Dependencies                               |"
echo "| - Join the domain (optional)                                       |"
echo "| - Other optimizations                                              |"
echo "|                                                                    |"
echo "|   For a full list of changes and optimizations,                    |"
echo "|   please visit https://thatvirtualboy.com                          |"
echo "|                                                                    |"
echo "|   ** THIS SCRIPT IS NOT OFFICIALLY SUPPORTED BY VMWARE             |"
echo "|   ** ENSURE YOU HAVE PROPER BACKUPS                                |"
echo "|   ** ENSURE SYSTEM IS FULLY UPDATED BEFORE INVOKING SCRIPT         |"
echo "|                                                                    |"
echo "|                                                                    |"
echo "|                     >>> That Virtual Boy  <<<                      |"
echo "+--------------------------------------------------------------------+"
echo -e "\e[36m"
read -p "Press any key to start..." -n1 -s
echo -e "\e[0m"
clear

# Configure Network Settings
sleep 2s
echo "Checking network..."
sleep 2s
nslookup vmware.com &> /dev/null
if [[ $? > 0 ]]
then
    echo
    echo -e "\e[31mI can't seem to get to the internet. You need a working Network connection to run this script.\e[0m"
    echo
    exit 1
else
    echo
    echo -e "\e[36mNetwork OK!\e[0m"
fi

# Configure Network
sleep 2s
clear
echo -e "\e[36mThe script needs to gather some information before we begin.\e[0m"
sleep 2s
echo 
read -p "Please enter your domain (lowercase please. E.g., vcloud.local): " domainname;
domainrealm=${domainname^^}
echo
sleep 2s
read -p "Please add a domain controller (shortname, lowercase. E.g., dcw2008r2): " domaincontroller;
echo
sleep 2s
read -p "What's your domain controller's IP address? " domaincontrollerip;
echo
sleep 2s
read -p "What's your WINS server IP address? " wins;
echo
sleep 2s
read -p "Enter a domain administrator (E.g., administrator): " domainadmin;
sleep 2s
clear
echo -e "\e[36mWould you like to configure your DNS?\e[0m"
select yn in "Yes" "No"; do
case $yn in
Yes ) read -p "Type your primary DNS server IP and hit [ENTER] " enterdns1; read -p "Type your secondary DNS server IP and hit [ENTER] " enterdns2;
sudo echo "dns-nameservers "$enterdns1 "" $enterdns2 >> /etc/network/interfaces
echo
echo -e "\e[36mDNS update complete\e[0m"
echo
sleep 2s
break;;
No ) echo -e "\e[36mSkipping DNS configuration\e[0m";
echo
sleep 2s
break;;
esac
done
clear

# Install Sudo
aptitude install sudo -y &> /dev/null
adduser viewadmin sudo &> /dev/null

# Change Timezone // Only for OVA
echo "Current Timezone is USA/Denver"
echo -e "\e[36m"
read -p "Press any key to change timezone... " -n1 -s
echo -e "\e[0m"
dpkg-reconfigure tzdata
echo
sleep 3
clear

# Change password
echo "Now would be a good time to change some passwords."
echo "The current password for viewadmin is [viewadmin]"
echo -e "\e[36m"
read -p "Press any key to change viewadmin's password... " -n1 -s
echo -e "\e[0m"
    passwd viewadmin
if [[ $? > 0 ]]
then
    passwd viewadmin
else
    sleep 2
fi
echo
echo -e "\e[0m"
echo "The current password for ROOT is [viewadmin]"
echo -e "\e[36m"
read -p "Press any key to change ROOT's password... " -n1 -s
echo -e "\e[0m"
    passwd root
if [[ $? > 0 ]]
then
    passwd root
else
    sleep 2
fi
echo
echo -e "\e[0m"
clear &&

##########################################
# Install packages and perform OS Tweaks #
##########################################

echo -e "\e[36mOptimizing system. This will take several minutes...\e[0m"
echo
sleep 2s

# Install Open VM Tools
wget -r --no-parent --reject "index.html*" http://packages.vmware.com/tools/keys/ -P /home/viewadmin
apt-key add /home/viewadmin/packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-DSA-KEY.pub
apt-key add /home/viewadmin/packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub
echo "deb http://packages.vmware.com/packages/ubuntu precise main" > /etc/apt/sources.list.d/vmware-tools.list
apt-get update 
apt-get install open-vm-tools-deploypkg -y 

# Install figlet for TVB
apt-get install figlet -y

# Install Media Codecs
apt-get install gstreamer0.10-plugins-bad-multiverse -y 
apt-get install libavcodec-extra-54 -y 
apt-get install unrar -y 
apt-get install ubuntu-restricted-addons -y 
clear
echo -e "\e[36m"
echo "Configuring desktop environment..."
echo -e "\e[0m"
sleep 2s

# Change runlevel to 5
sed -i '14 s/2/5/' /etc/init/rc-sysinit.conf

# Disable LTS Upgrade MOTD
sed -i '17 s/.*Prompt.*/Prompt=never/' /etc/update-manager/release-upgrades

# Update nsswitch
sed -i '7 s/.*passwd:.*/passwd:         compat winbind/' /etc/nsswitch.conf
sed -i '9 s/.*shadow:.*/shadow:         compat winbind/' /etc/nsswitch.conf
sed -i '11 s/.*hosts:.*/hosts:          cache db files dns/' /etc/nsswitch.conf

# Enable home directory for new users
echo 'session required pam_mkhomedir.so skel=/etc/skel/ umask=0022' >> /etc/pam.d/common-session

# Install MATE desktop and modify login screen
configureMATE(){
apt-get update
apt-get -f install -y
apt-get install software-properties-common -y
apt-add-repository ppa:ubuntu-mate-dev/ppa -y
apt-add-repository ppa:ubuntu-mate-dev/trusty-mate -y 
apt-get update 
apt-get install ubuntu-mate-core ubuntu-mate-desktop -y 
apt-get install mate-desktop-environment-extra -y 
echo 'greeter-show-manual-login=true' >> /usr/share/lightdm/lightdm.conf.d/50-ubuntu-mate.conf
echo 'greeter-hide-users=true' >> /usr/share/lightdm/lightdm.conf.d/50-ubuntu-mate.conf
echo 'allow-guest=false' >> /usr/share/lightdm/lightdm.conf.d/50-ubuntu-mate.conf
}

# Install GNOME desktop and modify login screen
configureGNOME(){
apt-get update
apt-get -f install -y
apt-get install ubuntu-gnome-desktop gnome-session-flashback ubuntu-wallpapers  -y
clear
echo -e "\e[36m"
read -p "To optimize login screen for Enterprise, lightdm will be configured. In the next screen, please select lightdm. Press [ENTER] to continue." -n1 -s
echo -e "\e[0m"
apt-get install lightdm lightdm-gtk-greeter -y
#sed -i '2 s/.*greeter-session=.*/greeter-session=lightdm-gtk-greeter/' /usr/share/lightdm/lightdm.conf.d/50-unity-greeter.conf
echo '[SeatDefaults]' >> /usr/share/lightdm/lightdm.conf.d/50-unity-greeter.conf
echo 'greeter-show-manual-login=true' >> /usr/share/lightdm/lightdm.conf.d/50-unity-greeter.conf
echo 'greeter-hide-users=true' >> /usr/share/lightdm/lightdm.conf.d/50-unity-greeter.conf
echo 'allow-guest=false' >> /usr/share/lightdm/lightdm.conf.d/50-unity-greeter.conf
echo 'user-session=gnome-fallback' >> /usr/share/lightdm/lightdm.conf.d/50-unity-greeter.conf
mv /usr/share/xsessions/gnome.desktop /usr/share/xsessions/gnome.desktop.disable
mv /usr/share/xsessions/gnome-fallback-compiz.desktop /usr/share/xsessions/gnome-fallback-compiz.desktop.disable
mv /usr/share/xsessions/gnome-classic.desktop /usr/share/xsessions/gnome-classic.desktop.disable
}

# Install Winbind and configure Active Directory Integration
winbind(){
apt-get install winbind -y 
wget https://raw.githubusercontent.com/thatvirtualboy/horizon-optimizer/master/files/krb5.conf -O /etc/krb5.conf 
wget https://raw.githubusercontent.com/thatvirtualboy/horizon-optimizer/master/files/smb.conf -O /etc/samba/smb.conf 


# Configure KRB5
sed -i "3 s/.*default_realm.*/default_realm = ${domainname^^}/" /etc/krb5.conf
sed -i "7 s/.*YOURDOMAIN.*/${domainname^^} = {/" /etc/krb5.conf 
sed -i "8 s/.*kdc.*/kdc = ${domaincontrollerip}/" /etc/krb5.conf
sed -i "9 s/.*default_domain.*/default_domain = ${domainname^^}/" /etc/krb5.conf
sed -i "12 s/.*.yourdomain.*/.${domainname,,} = ${domainname^^}/" /etc/krb5.conf
sed -i "13 s/.*yourdomain.*/${domainname,,} = ${domainname^^}/" /etc/krb5.conf

# Configure SMB
sed -i "2 s/.*workgroup.*/workgroup = ${domainrealm%.*}/" /etc/samba/smb.conf
sed -i "3 s/.*password.*/password server = ${domaincontroller,,}.${domainname,,}/" /etc/samba/smb.conf 
sed -i "4 s/.*wins.*/wins server = $wins/" /etc/samba/smb.conf 
sed -i "5 s/.*realm.*/realm = ${domainname^^}/" /etc/samba/smb.conf
clear
echo -e "\e[36mWould you like Winbind to use default domain? More info here: http://bit.ly/2eYWFl7\e[0m"
select kn in "Yes" "No"; do
  case $kn in
    Yes ) 
sed -i "10 s/.*winbind.*/winbind use default domain = true/" /etc/samba/smb.conf
break;;
No ) break;;
esac
done

service smbd restart 
service winbind restart 

# Install Kerberos & domain join
apt-get install krb5-user -y 
clear
echo
echo -e "\e[36mJoining the domain...\e[0m"
echo
sleep 1s
kinit $domainadmin'@'${domainname^^}
net ads join -U $domainadmin'@'${domainname^^}
net ads testjoin
finish
}

# Perform cleanup
finish(){
apt-get autoclean
cat /dev/null > ~/.bash_history
cat /dev/null > /var/log/horizon-optimizer.log


figlet -f small That Virtual Boy
echo "                   https://thatvirtualboy.com"
echo
echo
echo
echo -e "\e[36mYour Ubuntu Template has been optimized for Horizon 7!\e[0m"
echo -e "\e[36mVisit https://github.com/thatvirtualboy/ if there were any domain join errors.\e[0m"
echo
echo -e "\e[36mNext Steps: install apps, apply required customizations, and install the Horizon Agent.\e[0m"
echo -e "\e[36mAfter reboot, viewadmin can invoke the 'horizon-linux-installer.sh' script if desired."
echo
echo -e "\e[31m"
read -p "Press [ENTER] to reboot the VM..."
echo -e "\e[0m"
reboot
}

# Update Hosts file
echo $domaincontrollerip $domaincontroller'.'$domainname $domaincontroller >> /etc/hosts 

# Update resolv
echo 'nameserver ' $domaincontroller'.'$domainname >> /etc/resolv.conf

# Install Horizon Agent Dependencies
wget http://launchpadlibrarian.net/201393830/indicator-session_12.10.5+15.04.20150327-0ubuntu1_amd64.deb 
dpkg -i ./indicator-session_12.10.5+15.04.20150327-0ubuntu1_amd64.deb 


# Choose DE
clear
echo -e "\e[36mChoose a desktop session. GNOME Flashback is officially supported by VMware. MATE currently is not supported, but has been known to work.\e[0m"
select knn in "GNOME" "MATE"; do
case $knn in
GNOME )
echo
echo -e "\e[36mConfiguring GNOME Flashback (Metacity) Desktop Environment...\e[0m"
echo
configureGNOME
break;;
MATE ) 
echo
echo -e "\e[36mConfiguring MATE Desktop Environment (UNSUPPORTED)...\e[0m"
echo
configureMATE
break;; 
esac
done

# Choose to join domain
clear
echo -e "\e[36mConfiguring Active Directory Integration...\e[0m"
echo
echo -e "\e[36mDo you want to install Winbind and join the domain? If you choose No, you will need to manually configure Active Directory Integration later.\e[0m"
select kn in "Yes" "No"; do
case $kn in
Yes ) winbind
break;;
No ) finish
break;; 
esac
done
sleep 2s
