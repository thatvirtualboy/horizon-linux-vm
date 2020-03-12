#! /bin/bash
#
# Script for installing and configuring the VMware Horizon Agent for Linux + USB 3.0 with default values
#
# Please report any issues to Ryan on Twitter (@thatvirtualboy) or on VMware Flings
# Changelog and source available at https://github.com/thatvirtualboy/horizon-linux-vm
# www.thatvirtualboy.com
#
#
# Changelog
# v1.2
# Updated links for Horizon 7.12
# Added USB 3.0 and USB Redirection support

# Check for root
if [ "$(whoami)" != "root" ]; then
   echo
   echo -e "\e[31mOops! You must be root to continue! \n\e[0mPlease type: \e[36msu root -c ./linux-agent-installer.sh\e[0m"
   echo
   exit 1
fi

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


# Prompt to download Horizon Agent
clear
echo "+--------------------------------------------------------------------+"
echo "| You must first download the VMware Horizon 7.12 Agent for Linux    |"
echo "| before running this script. It will install the agent with default |"
echo "| values.                                                            |"
echo "|                                                                    |"
echo "| This script can also enable USB 3.0 support and USB Redirection.   |"
echo "|                                                                    |"
echo "| - Download: http://bit.ly/2T6fZQ0                                 |"
echo "| - Place the downloaded file anywhere on this system                |"
echo "| - Invoke this script as root                                       |"
echo "| - Follow the prompts                                               |"
echo "|                                                                    |"
echo "|                       >>> VMware Flings  <<<                       |"
echo "+--------------------------------------------------------------------+"
echo -e "\e[36m"
read -p "Press any key to start..." -n1 -s
echo -e "\e[0m"
clear

echo -e "\e[36m"
read -e -p "Full path to downloaded VMware Horizon Agent file: " agentinstaller;
echo -e "\e[0m"
echo
echo -e "\e[36m"
read -p "System will now verify agent. Press [ENTER] to continue." -n1 -s
echo -e "\e[0m"
clear

# Verify file
if [ -f $agentinstaller ]; then
  echo -e "\e[36mUnpacking VMware Horizon View Agent for Linux...\e[0m"
sleep 4 & spinner

    mkdir /tmp/hagentinstall
    tar -xzvf $agentinstaller -C /tmp/hagentinstall
    clear

    # Configure USB 3.0 and USB Redirection
    echo -e "  ${ASK} \e[36mWould you like to enable USB 3.0 Support and USB Redirection?\e[0m"
    select yn in "Yes" "No"; do
    case $yn in
    Yes ) wget https://sourceforge.net/projects/usb-vhci/files/linux%20kernel%20module/vhci-hcd-1.15.tar.bz2
    sudo apt-get install make -y
    sudo apt-get install gcc -y
    sudo apt-get install libelf-dev -y
    tar -xzvf vhci-hcd-1.15.tar.gz
    cd vhci-hcd-1.15
    patch -p1 < /tmp/hagentinstall/VMware-horizonagent-linux-x86_64-*/resources/ vhci/patch/vhci.patch
    make clean && make && make install
    echo
    echo -e "  ${INFO} \e[36mUSB 3.0 & Redirection enabled\e[0m"
    echo
    sleep 4 & spinner
    break;;
    No ) echo -e "  ${INFO} \e[36mSkipping USB 3.0 & Redirection configuration\e[0m";
    echo
    sleep 4 & spinner
    break;;
    esac
    done
    clear

  # Install Agent
      echo -e "  ${INFO} \e[36mInovking agent installer...\e[0m"
      sleep 4 & spinner
  cd /tmp/hagentinstall/VMware-horizonagent-linux-x86_64-*
    ./install_viewagent.sh -A yes
    rc=$?
else
	echo -e "\e[31mFile not found! Please verify your path and re-run this script.\e[0m"
    echo
    exit 1
fi

#figlet -f small VMware Flings
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
echo "             https://labs.vmware.com/flings/"
echo
echo
echo
echo -e "\e[36mHorizon Agent has been installed! See Horizon documentation for configuration options.\e[0m"
echo
echo -e "\e[31m"
read -p "Press [ENTER] to reboot the VM..."
echo -e "\e[0m"
reboot
