#! /bin/bash
#
# Horizon Optimizer for Ubuntu by Ryan Klumph
# Version: 1.1.0
# Please report any issues to Ryan on Twitter (@thatvirtualboy) or on VMware Flings
# Changelog and source available at https://github.com/thatvirtualboy/horizon-linux-vm
# www.thatvirtualboy.com
#

# Changelog // Special thanks to Tiddy, David, and Jack
# v1.1.0
#
# MATE Only Release
# Increased vRAM to 128 MB instead of Automatic
# Removed Audio Device
# Updated default network device to VMXNET3
# Updated repository for open-vm-tools to Ubuntu repo
# Added Horizon 7.1 Agent Dependencies
# Updated Dependency packages for Ubuntu 16.04 on Horizon 7.1
# Agent installer script updated with Horizon 7.1 links
# Updated Media Codec packages for Ubuntu 16.04
# Updated MATE packages to Xenial
# More reliable domain join
# Password update optional
# Timezone update optional
# Option to change hostname
# Desktop addons optional
# Added retry attempts for failed wgets of smb and krb5 configuration files
# Renamed ‘horizon-linux-installer.sh’ to ‘linux-agent-installer.sh

# Check for root
if [ "$(whoami)" != "root" ]; then
   echo
   echo -e "\e[31mOops! You must be root to continue! \n\e[0mPlease type: \e[36msu root -c ./horizon-optimizer.sh\e[0m"
   echo
   exit 1
fi

clear
echo "+--------------------------------------------------------------------+"
echo "| This script will configure your Ubuntu Template for Horizon 7.1    |"
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
echo "|   please visit https://github.com/thatvirtualboy/horizon-linux-vm  |"
echo "|                                                                    |"
echo "|   ** THIS SCRIPT IS NOT OFFICIALLY SUPPORTED BY VMWARE             |"
echo "|   ** ENSURE YOU HAVE PROPER BACKUPS                                |"
echo "|   ** ENSURE SYSTEM IS FULLY UPDATED BEFORE INVOKING SCRIPT         |"
echo "|                                                                    |"
echo "|                                                                    |"
echo "|                       >>> VMware Flings <<<                        |"
echo "+--------------------------------------------------------------------+"
echo -e "\e[36m"
read -p "Press any key to start..." -n1 -s
echo -e "\e[0m"
clear

# Configure Network Settings
sleep 2s
echo -e "\e[36m"
echo "Checking network..."
echo -e "\e[0m"
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
    sleep 2s
    clear
fi

domainProperties(){
# Configure Domain Properties
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
#clear
}

# Configure hostname
hostn=$(cat /etc/hostname)

# Display existing hostname
echo -e "\e[36mExisting hostname is $hostn\e[0m"

# Ask for new hostname
echo -e "\e[36mWould you like to change your hostname?\e[0m"
select cn in "Yes" "No"; do
case $cn in
Yes )
echo "Enter new hostname: "
read newhost
#change hostname in /etc/hosts & /etc/hostname
sudo sed -i "s/$hostn/$newhost/g" /etc/hosts
sudo sed -i "s/$hostn/$newhost/g" /etc/hostname
#display new hostname
echo -e "\e[36mYour new hostname is $newhost\e[0m"
sleep 3s
break;;
No ) echo -e "\e[36mSkipping hostname configuration\e[0m";
echo
sleep 2s
break;;
esac
done

# Configure DNS
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
#echo -e "\e[36m"
#read -p "Press any key to change timezone... " -n1 -s
echo -e "\e[36mWould you like to change your timezone?\e[0m"
select an in "Yes" "No"; do
case $an in
  Yes )
#echo -e "\e[0m"
dpkg-reconfigure tzdata
echo
sleep 3
clear
break;;
No ) echo -e "\e[36mSkipping timezone configuration\e[0m";
echo
sleep 2s
break;;
esac
done
clear

# Change password
echo -e "\e[36mNow would be a good time to change some passwords. Would you like to change your default passwords? (Recommended)\e[0m"
select bn in "Yes" "No"; do
case $bn in
  Yes )
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
break;;
No ) echo -e "\e[36mSkipping password configuration\e[0m";
echo
sleep 2s
break;;
esac
done
clear
##########################################
# Install packages and perform OS Tweaks #
##########################################

echo -e "\e[36mOptimizing system. This will take several minutes...\e[0m"
echo
sleep 2s

# Install Open VM Tools and Kerberos
#wget -r --no-parent --reject "index.html*" http://packages.vmware.com/tools/keys/ -P /home/viewadmin
#apt-key add /home/viewadmin/packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-DSA-KEY.pub
#apt-key add /home/viewadmin/packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub
#echo "deb http://packages.vmware.com/packages/ubuntu precise main" > /etc/apt/sources.list.d/vmware-tools.list
apt-get update 
apt-get install open-vm-tools-desktop -y
apt-get install krb5-locales -y

# Install figlet
apt-get install figlet -y

# Install Media Codecs
clear
echo -e "\e[36mWould you like to install Media Codecs and Desktop Applications? This makes the desktop more user-friendly. (gstreamer, libavcodec, unrar, ubuntu addons)\e[0m"
select dn in "Yes" "No"; do
case $dn in
Yes )
apt-get install gstreamer1.0-plugins-good -y 
apt-get install libavcodec-extra -y 
apt-get install unrar -y 
apt-get install ubuntu-restricted-addons -y 
clear
break;;
No ) echo -e "\e[36mSkipping desktop addons\e[0m";
echo
sleep 2s
break;;
esac
done

clear
echo -e "\e[36m"
echo "Optimizing desktop environment..."
echo -e "\e[0m"
sleep 2s

# Change runlevel to 5
sed -i '14 s/2/5/' /etc/init/rc-sysinit.conf

# Disable LTS Upgrade MOTD
sed -i '17 s/.*Prompt.*/Prompt=never/' /etc/update-manager/release-upgrades

# Update nsswitch
sed -i '7 s/.*passwd:.*/passwd:         compat winbind/' /etc/nsswitch.conf
sed -i '9 s/.*shadow:.*/shadow:         compat winbind/' /etc/nsswitch.conf
#sed -i '11 s/.*hosts:.*/hosts:          cache db files dns/' /etc/nsswitch.conf
sed -i '12 s/.*hosts:.*/hosts:          cache db files dns/' /etc/nsswitch.conf

# Enable home directory for new users
echo 'session required pam_mkhomedir.so skel=/etc/skel/ umask=0022' >> /etc/pam.d/common-session

# Install MATE desktop and modify login screen
configureMATE(){
apt-get update
apt-get -f install -y
apt-get install software-properties-common -y
apt-add-repository ppa:ubuntu-mate-dev/ppa -y
#apt-add-repository ppa:ubuntu-mate-dev/trusty-mate -y 
apt-add-repository ppa:ubuntu-mate-dev/xenial-mate -y
apt-get update 
apt-get install ubuntu-mate-core ubuntu-mate-desktop -y 
apt-get install mate-desktop-environment-extra -y 
echo 'greeter-show-manual-login=true' >> /usr/share/lightdm/lightdm.conf.d/50-ubuntu-mate.conf
echo 'greeter-hide-users=true' >> /usr/share/lightdm/lightdm.conf.d/50-ubuntu-mate.conf
echo 'allow-guest=false' >> /usr/share/lightdm/lightdm.conf.d/50-ubuntu-mate.conf
}

# Install GNOME desktop and modify login screen // Removed in 1.1.0 Release
configureGNOME(){
apt-get update
apt-get -f install -y
apt-get install ubuntu-gnome-desktop gnome-session-flashback ubuntu-wallpapers  -y
clear
echo -e "\e[36m"
read -p "To optimize login screen for Enterprise, lightdm will be configured. In the next screen, please select lightdm. Press [ENTER] to continue." -n1 -s
echo -e "\e[0m"
apt-get install lightdm lightdm-gtk-greeter -y
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
apt-get install winbind libnss-winbind libpam-winbind -y 
wget --tries=3 https://raw.githubusercontent.com/thatvirtualboy/horizon-linux-vm/master/files/krb5.conf -O /etc/krb5.conf 
wget --tries=3 https://raw.githubusercontent.com/thatvirtualboy/horizon-linux-vm/master/files/smb.conf -O /etc/samba/smb.conf 


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

# Update Hosts file
echo $domaincontrollerip $domaincontroller'.'$domainname $domaincontroller >> /etc/hosts 

# Update resolv
echo 'nameserver ' $domaincontroller'.'$domainname >> /etc/resolv.conf

clear
echo -e "\e[36mWould you like Winbind to use default domain? More info here: http://bit.ly/2eYWFl7\e[0m"
select wn in "Yes" "No"; do
  case $wn in
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


figlet -f small VMware Flings
echo "              https://labs.vmware.com/flings/"
echo
echo
echo
echo -e "\e[36mYour Ubuntu VM has been optimized for Horizon 7.1!\e[0m"
echo -e "\e[36mVisit https://github.com/thatvirtualboy/ if there were any domain join errors.\e[0m"
echo
echo -e "\e[36mNext Steps: install apps, apply required customizations, and install the Horizon Agent.\e[0m"
echo -e "\e[36mAfter reboot, viewadmin can invoke the 'linux-agent-installer.sh' script if desired."
echo
echo -e "\e[31m"
read -p "Press [ENTER] to reboot the VM..."
echo -e "\e[0m"
reboot
}

# Install Horizon Agent Dependencies
apt-get install python-dbus -y
apt-get install python-gobject -y


# Choose DE // Removed in 1.1.0 Release - defaults to MATE DE
  #clear
   #echo -e "\e[36mChoose a desktop session. GNOME Flashback is officially supported by VMware. MATE currently is not supported, but has been known to work.\e[0m"
   #select knn in "GNOME" "MATE"; do
   #case $knn in
   #GNOME )
   #echo
   #echo -e "\e[36mConfiguring GNOME Flashback (Metacity) Desktop Environment...\e[0m"
   #echo
   #configureGNOME
   #break;;
   #MATE ) 
   #echo
   #echo -e "\e[36mConfiguring MATE Desktop Environment...\e[0m"
   #echo
configureMATE
   #break;; 
   #esac
   #done

# Choose to join domain
clear
echo -e "\e[36mConfiguring Active Directory Integration...\e[0m"
echo
echo -e "\e[36mDo you want to install Winbind and join the domain? If you choose No, you will need to manually configure Active Directory Integration later.\e[0m"
select kn in "Yes" "No"; do
case $kn in
Yes )
domainProperties
winbind
break;;
No )
finish
break;; 
esac
done
sleep 2s
