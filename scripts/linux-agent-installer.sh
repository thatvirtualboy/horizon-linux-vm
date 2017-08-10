#! /bin/bash
#
# Script for installing and configuring the VMware Horizon Agent for Linux with default values
#
# Changelog
# v1.1
# Updated links for Horizon 7.1

# Check for root
if [ "$(whoami)" != "root" ]; then
   echo
   echo -e "\e[31mOops! You must be root to continue! \n\e[0mPlease type: \e[36msu root -c ./linux-agent-installer.sh\e[0m"
   echo
   exit 1
fi


# Prompt to download Horizon Agent
clear
echo "+--------------------------------------------------------------------+"
echo "| You must manually download the VMware Horizon 7.1 Agent for Linux  |"
echo "| before running this script. It will install the agent with default |"
echo "| values.                                                            |"
echo "|                                                                    |"
echo "| - Download: http://bit.ly/2pw5LKO                                  |"
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
read -p "System will now verify path and install agent. Press [ENTER] to continue." -n1 -s
echo -e "\e[0m"
clear

# Verify file
if [ -f $agentinstaller ]; then
  echo -e "\e[36mUnpacking VMware Horizon View Agent for Linux...\e[0m"
    sleep 2s

    mkdir /tmp/hagentinstall
    tar -xzvf $agentinstaller -C /tmp/hagentinstall
    cd /tmp/hagentinstall/VMware-horizonagent-linux-x86_64-*
    clear
    ./install_viewagent.sh -A yes
    rc=$?
else
	echo -e "\e[31mFile not found! Please verify your path and re-run the script.\e[0m"
    echo
    exit 1
fi

figlet -f small VMware Flings
echo "              https://labs.vmware.com/flings/"
echo
echo
echo
echo -e "\e[36mHorizon Agent has been installed! See http://bit.ly/2pvWuCg for configuration options.\e[0m"
echo
echo -e "\e[31m"
read -p "Press [ENTER] to reboot the VM..."
echo -e "\e[0m"
reboot
