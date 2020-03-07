#! /bin/bash
#
# Horizon Optimizer for Linux by Ryan Klumph
# Version: 1.2
# Please report any issues to Ryan on Twitter (@thatvirtualboy) or on VMware Flings
# Changelog and source available at https://github.com/thatvirtualboy/horizon-linux-vm
# www.thatvirtualboy.com
#

# Changelog
# v1.2
#
# Special thanks to Robert Guske for testing & feedback
# Support for Horizon 7.11 and 7.12
# Support for vSphere 6.7+
# Updated OVA base image to Ubuntu 18.04.4 LTS
# Updated Virtual Hardware to v14
# Added option to configure static networking
# Added support for USB 3.0 and USB Redirection (via linux-agent-installer.sh)
# Added KDE Desktop Environment Option
# Added Gnome Desktop Environment Option (recommended)
# Developer Desktop Package option
# Added Keyboard Layout Option
# Added option to enable SSH
# Removed runlevel 5 setting
# Fixed MOTD prompt code
# Disabled auto software updates
# Removed greeter modifications to support SSO
# Numerous improvements to script
# Script renamed to 'optimize.sh'
#
# v1.1.0 released May 17 2017
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
#
# v1.0 GA Release Features
#
# Built from Ubuntu’s mini.iso for a minimal footprint
# Configures your Timezone
# Updates admin (viewadmin) and root passwords
# Configures DNS Servers
# Disables automatic updates (except for security updates)
# Sets default run level to 5
# Sets FQDN in /etc/hosts
# Installs Horizon Agent dependencies
# Installs Winbind
# Configures krb5.conf
# Configures smb.conf
# New user home directory config
# Optimizes login screen for VDI
# Removes guest login
# Installs Drivers & Media codecs
# Domain Join is optional and occurs using Winbind. Other domain-join methods require manual configuration
# Winbind default domain flag is optional (required for SSO)
# Utilizes MATE DE (fork from GNOME 2)
# OVA RAM configured for 2GB per best practice
# OVA CPU configured for 2vCPU per best practice
# OVA vRAM configured to 128 MB per best practice
# SVGA properties configured to best practice
# LTS Upgrade notifications disabled


# Some Variables
TICK="[$\e[92m√\e[0m]"
CROSS="[$\e[91mx\e[0m]"
INFO="[i]"
ASK="[\e[93m?\e[0m]"
green='\e[32m'
cyan='\e[36m'

# Spinner
function spinner {
pid=$!
i=0
sp="/-\|"
while kill -0 $pid 2>/dev/null
	do
	i=$(( (i+1) %4 ))
	printf "\r[${sp:$i:1}]"
	sleep .1
done
echo ""
}

# Header
function printhead {
clear
printf $green"$header"$reset
echo ""
}


# Display Header
header='__     ____  __                        _____ _ _
\ \   / |  \/  __      ____ _ _ __ ___|  ___| (_)_ __   __ _ ___
 \ \ / /| |\/| \ \ /\ / / _` |  __/ _ | |_  | | |  _ \ / _` / __|
  \ V / | |  | |\ V  V | (_| | | |  __|  _| | | | | | | (_| \__ \
   \_/  |_|  |_| \_/\_/ \__,_|_|  \___|_|   |_|_|_| |_|\__, |___/
                                                       |___/'
printhead
echo ""
printf $cyan"Checking system requirements...\n"$reset
sleep 4 & spinner
echo ""
# Check for root
if [ "$(whoami)" != "root" ]; then
   echo
   echo -e "  ${CROSS} \e[31mOops! You must be root to continue! \n\e[0mPlease type: \e[36msu root -c ./optimize.sh\e[0m"
   echo
   exit 1
 else
   printf $green" Running as root. Great!\n"$reset
   echo ""
fi

# Check CPUs
cpus="$(nproc)"
if [[ "${cpus}" -lt 2 ]]; then
	echo ""
	printf $red"Attention: 2 to 4 CPUs recommended for best performance!\n"$reset
	printf $red"Current CPU: ("$((cpus))")\n"$reset
	anykey
else
	printf $green" CPU for Ubuntu on Horizon OK! ("$((cpus))")\n"$reset
	echo
fi

# Check RAM
ram="$(awk '/MemTotal/{print $2}' /proc/meminfo)"
if [ "$ram" -lt "$((1*1002400))" ]; then
	echo
	printf $red"Attention: 2 GB RAM or more recommended for Ubuntu on Horizon!\n"$reset
	printf $red"Current RAM is: ("$((ram/1002400))" GB)\n"$reset
	anykey
else
    printf $green" RAM for Ubuntu on Horizon OK! ("$((ram/1002400))" GB)\n"$reset
echo
fi

# Check Network Settings
if nc -zw1 vmware.com 443;
then
	printf $green" Network Connection OK!\n"$reset
else
	echo -e "  ${CROSS} \e[31mI can't seem to get to the internet. You need a working Network connection to run this script.\e[0m"
	echo
	exit 1
fi
sleep 4

clear
echo "+--------------------------------------------------------------------+"
echo "| This script will configure your Ubuntu Template for Horizon 7.12   |"
echo "| with 2D graphics. It will also do the following:                   |"
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
echo "|   Thanks for using my fling!                                       |"
echo "|                        - @thatvirtualboy                           |"
echo "|                                                                    |"
echo "|                       >>> VMware Flings <<<                        |"
echo "+--------------------------------------------------------------------+"
echo -e "\e[36m"
read -p "   Press any key to start..." -n1 -s
echo -e "\e[0m"
clear

printhead

domainProperties(){
# Configure Domain Properties
echo
read -p "  [?] Please enter your domain (lowercase please. E.g., vcloud.local): " domainname;
domainrealm=${domainname^^}
echo
sleep 2s
read -p "  [?] Please add a domain controller (shortname, lowercase. E.g., dcw2016): " domaincontroller;
echo
sleep 2s
read -p "  [?] What's your domain controller's IP address? " domaincontrollerip;
echo
sleep 2s
read -p "  [?] What's your WINS server IP address? " wins;
echo
sleep 2s
read -p "  [?] Enter a domain administrator (E.g., administrator): " domainadmin;
sleep 2s
#clear
}

# Configure keyboard layout
echo -e "  ${ASK}\e[36mThis template was configurd with a US Keyboard Layout. Would you like to change it? \e[0m"
select yn in "Yes" "No"; do
case $yn in
	Yes ) sudo dpkg-reconfigure keyboard-configuration
	break;;
	No ) echo -e "  ${INFO} \e[36mMoving on...\e[0m";
	sleep 2s
	break;;
esac
done
clear
printhead

# Configure hostname
hostn=$(cat /etc/hostname)

# Display existing hostname
echo -e "  ${INFO}\e[36mExisting hostname is $hostn\e[0m"

# Ask for new hostname
echo -e "  ${ASK} \e[36mWould you like to change your hostname? If you select yes you MUST NOT \e[0m"
echo -e "  \e[36mhave 'ubuntu' in the name. It will cause DNS issues. \e[0m"
select cn in "Yes" "No"; do
case $cn in
Yes )
echo "  ${INFO} Enter new hostname (shortname <15 chars, do NOT use 'ubuntu' in the name): "
read newhost
#change hostname in /etc/hosts & /etc/hostname
sudo hostnamectl set-hostname $newhost
sudo sed -i "s/$hostn/$newhost/g" /etc/hosts
sudo sed -i "s/$hostn/$newhost/g" /etc/hostname
#display new hostname
echo -e "  ${INFO} \e[36mYour new hostname is $newhost\e[0m"
sleep 3s
break;;
No ) echo -e "  ${INFO} \e[36mSkipping hostname configuration...\e[0m";
echo
sleep 2s
break;;
esac
done

# Configure Networking
clear
printhead
echo -e "  ${ASK} \e[36mRight now your IP address is from DHCP. Would you like to configure static networking? (If you choose No, you must run 'sudo dhclient' after each reboot)\e[0m"
select yn in "Yes" "No"; do
case $yn in
Yes )
read -p "  ${INFO} Type your preferred IP Address and hit [ENTER] " staticip; read -p "  ${INFO} Type your subnet mask in short form including the slash (e.g., /24) and hit [ENTER] " subnet; read -p "  ${INFO} Type your Gateway IP and hit [ENTER] " gatewayip; read -p "  ${INFO} Type your primary DNS server IP and hit [ENTER] " enterdns1; read -p "  ${INFO} Type your secondary DNS server IP and hit [ENTER] " enterdns2;
#sudo echo "dns-nameservers "$enterdns1 "" $enterdns2 >> /etc/network/interfaces
# add file from github that is edited with deets
nic=`ifconfig | awk 'NR==1{print $1}'`
sudo touch /etc/netplan/01-netcfg.yaml
cat > /etc/netplan/01-netcfg.yaml <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    $nic
      dhcp4: no
      addresses: [$staticip$subnet]
      gateway4: $gatewayip
      nameservers:
          addresses: [$enterdns1,$enterdns2]
EOF
sudo netplan apply
if nc -zw1 vmware.com 443;
then
  echo -e "  ${INFO} Network Connection OK!\e[0m";
else
	echo -e "  ${CROSS} \e[31mI can't seem to get to the internet. Reverting to DHCP. Please configure networking after the script completes.\e[0m"
	echo
	sudo dhclient
fi
sleep 4
echo
echo -e "  ${INFO} \e[36mNetwork update complete\e[0m"
echo
sleep 2s
break;;
No ) echo -e "  ${INFO} \e[36mSkipping network configuration...\e[0m";
echo
sleep 2s
break;;
esac
done
clear
printhead

# Configure NTP
clear
printhead
echo -e "  ${ASK} \e[36mWould you like to configure NTP to connect to a time server?\e[0m"
select an in "Yes" "No"; do
case $an in
  Yes )read -p "  ${INFO} Type your NTP-server-host and hit [ENTER] " ntpserver; read -p "  ${INFO} Type your NTP Server's IP Address and hit [ENTER] " ntpip;
echo
	echo -e "  ${INFO} \e[36mConfiguring NTP...\e[0m";
	sleep 2s
	apt-get install ntpdate -y
  echo $ntpip $nspserver >> /etc/hosts
	sudo timedatectl set-ntp off
	sudo apt-get install ntp -y
	echo 'server' $ntpserver 'prefer iburst' >> /etc/ntp.conf
	sudo service ntp restart
	break;;
	No ) echo -e "  ${INFO} \e[36mSkipping NTP configuration...\e[0m";
	echo
	sleep 2s
	break;;
	esac
	done
	clear
	printhead



# Install Sudo
aptitude install sudo -y &> /dev/null
adduser viewadmin sudo &> /dev/null

# Change Timezone // Only for OVA
echo "  ${INFO} Current Timezone is USA/Denver"
echo -e "  ${ASK} \e[36mWould you like to change your timezone?\e[0m"
select an in "Yes" "No"; do
case $an in
  Yes )
dpkg-reconfigure tzdata
echo
sleep 3
clear
printhead
break;;
No ) echo -e "  ${INFO} \e[36mSkipping timezone configuration\e[0m";
echo
sleep 2s
break;;
esac
done
clear
printhead

# Change password
echo -e "  ${ASK} \e[36mNow would be a good time to change some passwords. Would you like to change your default passwords? (Recommended)\e[0m"
select bn in "Yes" "No"; do
case $bn in
  Yes )
echo "  ${INFO} The current password for viewadmin is [viewadmin]"
echo -e "\e[36m"
read -p "  ${INFO} Press any key to change viewadmin's password... " -n1 -s
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
echo "  ${INFO} The current password for ROOT is [viewadmin]"
echo -e "\e[36m"
read -p "  ${INFO} Press any key to change ROOT's password... " -n1 -s
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
clear && printhead
break;;
No ) echo -e "  ${INFO} \e[36mSkipping password configuration\e[0m";
echo
sleep 2s
break;;
esac
done
clear
printhead

##########################################
# Install packages and perform OS Tweaks #
##########################################

echo -e "   \e[36mInitiating sublight thrusters sequence...\e[0m"
echo
sleep 2s

# Install Open VM Tools and Kerberos
apt-get update
apt-get install open-vm-tools-desktop -y
apt-get install krb5-locales -y

# Install Media Codecs
clear
printhead
echo -e "  ${ASK} \e[36mWould you like to install Media Codecs and Desktop Applications? This makes the desktop more user-friendly. (gstreamer, libavcodec, unrar, ubuntu addons)\e[0m"
select dn in "Yes" "No"; do
case $dn in
Yes )
apt-get install gstreamer1.0-plugins-good -y
apt-get install libavcodec-extra -y
apt-get install unrar -y
apt-get install ubuntu-restricted-extras -y
clear
printhead
break;;
No ) echo -e "  ${INFO} \e[36mSkipping desktop addons\e[0m";
echo
sleep 2s
break;;
esac
done

clear
printhead
echo -e "\e[36m"
echo "   Dropping out of light speed in 3...2..."
echo -e "\e[0m"
sleep 2s

# Disable LTS Upgrade MOTD
sed -i '16 s/.*Prompt.*/Prompt=never/' /etc/update-manager/release-upgrades

# Disable auto-updates
sudo sed -i 's/APT::Periodic::Update-Package-Lists "1"/APT::Periodic::Update-Package-Lists "0"/' /etc/apt/apt.conf.d/20auto-upgrades


# Update nsswitch
sed -i '7 s/.*passwd:.*/passwd:         compat winbind/' /etc/nsswitch.conf
sed -i '9 s/.*shadow:.*/shadow:         compat winbind/' /etc/nsswitch.conf
sed -i '12 s/.*hosts:.*/hosts:          cache db files dns/' /etc/nsswitch.conf

# Enable home directory for new users
echo 'session required pam_mkhomedir.so skel=/etc/skel/ umask=0022' >> /etc/pam.d/common-session

# Install MATE desktop
configureMATE(){
apt-get install ubuntu-mate-desktop -y
apt-get install gdm3 -y

}

# Install GNOME desktop
configureGNOME(){
apt-get install ubuntu-desktop -y
}

# Install K Desktop environment
configureKDE(){
  apt-get install kubuntu-desktop -y
  apt-get install gdm3 -y
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
printhead
echo -e "  ${ASK} \e[36mWould you like Winbind to use default domain? More info here: http://bit.ly/2eYWFl7\e[0m"
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
printhead
echo
echo -e "  ${INFO} \e[36mAttempting to join the domain...\e[0m"
echo
sleep 1s
kinit $domainadmin'@'${domainname^^}
net ads join -U $domainadmin'@'${domainname^^}
net ads testjoin
sleep 3s
finish
}

# Perform cleanup
finish(){
apt-get autoclean
cat /dev/null > ~/.bash_history
cat /dev/null > /var/log/horizon-optimizer.log
clear
printhead

echo "                https://labs.vmware.com/flings/"
echo
echo
echo
echo -e "\e[36m   Your image has been optimized for Horizon 7!\e[0m"
echo -e "\e[36m   Additional configuration may be needed for AD and/or SSO.\e[0m"
echo
echo -e "\e[36m   Next Steps: install apps, apply required customizations, and install the Horizon Agent.\e[0m"
echo -e "\e[36m   NOTE: The included 'linux-agent-installer.sh' script can assist in the agent install.\e[0m"

echo
echo -e "\e[31m"
read -p "Press [ENTER] to reboot the VM..."
echo -e "\e[0m"
reboot
}

# Install Horizon Agent Dependencies
apt-get install python -y
apt-get install python-dbus -y
apt-get install python-gobject -y


# Choose DE
clear
printhead

echo -e "\e[36m   Choose a supported desktop session. Ubuntu Gnome is recommended and is the only DE\e[0m"
echo -e "\e[36m   that supports Session Collaboration (http://bit.ly/3927NWe).\e[0m"
echo
echo -e "   ${INFO}\e[36m NOTE: MATE and KDE will prompt you for a default greeter.\e[0m"
echo -e "      \e[36m Select gdm3 (it's the only supported greeter for Ubuntu on Horizon).\e[0m"
echo

select knn in "GNOME" "MATE" "KDE" "None"; do
case $knn in
GNOME )
echo
echo -e "\e[36mConfiguring GNOME Desktop Environment...\e[0m"
echo
sleep 2s
configureGNOME
break;;
MATE )
echo
echo -e "\e[36mConfiguring MATE Desktop Environment...\e[0m"
echo
sleep 2s
configureMATE
break;;
KDE  )
echo
echo -e "\e[36mConfiguring Plasma Desktop Environment (KDE)...\e[0m"
echo
sleep 2s
configureKDE
break;;
None )
echo
echo -e "\e[36mSkipping installation of desktop environment...\e[0m"
echo
sleep 2s
break;;
esac
done

# Developer Desktop options
clear
printhead

echo -e "  ${INFO} \e[36mDo you want to install the Developer Desktop Package? See http://bit.ly/2VDsZhD for details.\e[0m"
select dn in "Yes" "No"; do
	case $dn in
		Yes )
    echo
		echo -e "\e[36mConfiguring Developer Desktop Package...\e[0m"
		apt-get install snapd -y
		snap install code --classic -y
		sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
		curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
		sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
		sudo apt update
		apt-cache policy docker-ce
		sudo apt install docker-ce -y
		sudo usermod -aG docker viewadmin
		curl -Lo ./kind "https://github.com/kubernetes-sigs/kind/releases/download/v0.7.0/kind-$(uname)-amd64"
		chmod +x ./kind
		mv ./kind /some-dir-in-your-PATH/kind
    wget https://github.com/vmware-tanzu/octant/releases/download/v0.10.2/octant_0.10.2_Linux-64bit.deb
		dpkg -i octant_0.*.deb
		apt-get install zsh -y
		sh -c "$(curl -fsSL https://raw.githubusercontent.com/thatvirtualboy/ohmyzsh/master/tools/install.sh)"
		break;;
		No )
		echo -e "  ${INFO} \e[36mSkipping Developer Desktop configuration...\e[0m";
		sleep 2s
		break;;
	esac
done

# Prompt for SSH
clear
printhead
echo -e "  ${INFO} \e[36mWould you like to enable SSH? (This will not permit root login!)\e[0m"
select dn in "Yes" "No"; do
	case $dn in
		Yes )
		echo
		echo -e "   \e[36mEnabling...\e[0m"
		echo
		apt-get install openssh-server -y
		sudo ufw allow ssh
		break;;
		No ) echo -e "  ${INFO} \e[36mLeaving SSH disabled...\e[0m";
		sleep 2s
		break;;
	esac
done

# Choose to join domain
clear
printhead

echo -e "  ${INFO} \e[36mConfiguring Active Directory Integration...\e[0m"
echo
echo -e "  ${ASK} \e[36mDo you want to install Winbind and join the domain? If you choose No, you will need to manually configure Active Directory Integration later.\e[0m"
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
