#! /bin/bash
#
# Script for installing VMware Horizon Agent for Linux with default values
#

# Check for root
if [ "$(whoami)" != "root" ]; then
   echo
   echo -e "\e[31mOops! You must be root to continue! \n\e[0mPlease type: \e[36msu root -c ./horizon-optimizer.sh\e[0m"
   echo
   exit 1
fi


# Prompt to download Horizon Agent
clear
echo "+--------------------------------------------------------------------+"
echo "| You must manually download the VMware Horizon Agent for Linux      |"
echo "| before running this script.                                        |"
echo "|                                                                    |"
echo "| - Download: http://bit.ly/2emSkDI                                  |"
echo "| - Place the downloaded file anywhere on this system                |"
echo "| - Invoke this script as root                                       |"
echo "| - Follow the prompts                                               |"
echo "|                                                                    |"
echo "|                     >>> That Virtual Boy  <<<                      |"
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
read -p "System will now verify path and install agent. Press [ENTER] to continue." -n1 -s
echo -e "\e[0m"
clear

# Verify file
if [ -f $agentinstaller ]; then
	echo -e "\e[36mInstalling VMware Horizon View Agent for Linux...\e[0m"
    sleep 2s

    mkdir /tmp/hagentinstall
    tar -xzvf $agentinstaller -C /tmp/hagentinstall
    cd /tmp/hagentinstall/VMware-horizonagent-linux-x86_64-*
    ./install_viewagent.sh -A yes
    rc=$?
else
	echo -e "\e[31mFile not found! Please verify your path and re-run the script.\e[0m"
    echo
    exit 1
fi

figlet -f small That Virtual Boy
echo "                   https://thatvirtualboy.com"
echo
echo
echo
echo -e "\e[36mHorizon Agent has been installed!\e[0m"
echo
echo -e "\e[31m"
read -p "Press [ENTER] to reboot the VM..."
echo -e "\e[0m"
reboot

