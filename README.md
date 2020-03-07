# Horizon Linux VM - dev branch
Optimized Ubuntu Template for VMware Horizon 7

### This project is [published as a VMware Fling](https://labs.vmware.com/flings/horizon-ova-for-ubuntu). Please visit the Flings site to get the latest OVA.

Ubuntu Desktop is the perfect Virtual Desktop Infrastructure (VDI) alternative to Windows for VDI Admins who are looking to move away from a Windows-centric desktop delivery. With an infrastructure utilizing VMware Horizon 7, this pre-packaged OVA aims to ease the setup and configuration of a Ubuntu Template VM, especially for Windows Admins that aren’t familiar with a Linux desktop.

<p align="center"><img src="https://user-images.githubusercontent.com/13758243/76128915-f19b4380-5fc2-11ea-8474-1fd8ddb40cdc.png" height="593" width="765"></p>

## Details

### Preconfigured Ubuntu OVA
* Base image is Ubuntu 18.04.4 LTS x64 built from mini.iso for minimal footprint
* VMware HW v14 (requires vSphere 6.7+)
* Configures Master Image for 2D Graphics Settings
* Default username/password is viewadmin/viewadmin
* The VM includes the `optimization.sh` script which configures VM to Best Practices per Horizon 7 Documentation as well as the `linux-agent-install.sh` script to install the Horizon Agent and configure USB 3.0 Redirection
* Additional system tweaks and applications may be necessary for your needs.
* Due to licensing limitations, the Horizon Agent is NOT included in this OVA. It must be downloaded manually after completing the optimization script.

## Instructions

### Steps:
1. [Download](https://labs.vmware.com/flings/horizon-ova-for-ubuntu) the pre packaged OVA & deploy to your datacenter
2. Boot the VM and ensure you get a valid IP and can reach the internet (you can use `sudo dhclient` to use DHCP)
3. Open a console to the VM and login as viewadmin/viewadmin
4. Open Terminal and type `sudo apt-get update && sudo apt-get upgrade`
5. Install all available updates and reboot if prompted
6. Open Terminal and type `su root -c ./optimize.sh`
7. Enter the root password (viewadmin)
8. Follow the prompts

Once complete, you'll want to finish customizing your template to your needs before installing the Horizon Agent (e.g., SSO, 3D/NVIDIA GRID requirements, etc). See the VMware Linux Desktop instructions [here](https://docs.vmware.com/en/VMware-Horizon-7/7.11/linux-desktops-setup.pdf).

After completing your customizations, you can manually install the Horizon Agent, or you can invoke the _linux-agent-installer.sh_ script by typing `su root -c ./linux-agent-installer.sh` then proceed with building your pools.

### Developer Desktop Package
Choosing to install the Developer Desktop Package when prompted will install the following packages:

* snapd
* VSCode
* Docker
* Kind
* Octant
* zsh + ohmyzsh

NOTE: this option requires you add your subnet to _/etc/vmware/viewagent-custom.conf_ following the Horizon Agent install (e.g., `Subnet=10.1.1.11/24`)

> For additional Developer-specific tweaks, see my colleague [Robert Guske's](https://twitter.com/vmw_rguske) excellent Horizon Linux Blog series [here](https://rguske.github.io/post/a-linux-development-desktop-with-vmware-horizon-part-i-horizon/)


### Changelog
Version: 1.2

* Special thanks to Robert Guske for testing & feedback
* Support for Horizon 7.11 and 7.12
* Support for vSphere 6.7+
* Updated OVA base image to Ubuntu 18.04.4 LTS
* Updated Virtual Hardware to v14
* Added option to configure static networking
* Added support for USB 3.0 and USB Redirection (via linux-agent-installer.sh)
* Added KDE Desktop Environment Option
* Added Gnome Desktop Environment Option (recommended)
* Developer Desktop Package option
* Added Keyboard Layout Option
* Added option to enable SSH
* Removed runlevel 5 setting
* Fixed MOTD prompt code
* Disabled auto software updates
* Removed greeter modifications to support SSO
* Numerous improvements to script
* Script renamed to 'optimize.sh'

Version: 1.1.0

* MATE Only Release
* Increased vRAM to 128 MB instead of Automatic
* Removed Audio Device
* Updated default network device to VMXNET3
* Updated repository for open-vm-tools to Ubuntu repo
* Added Horizon 7.1 Agent Dependencies
* Updated Dependency packages for Ubuntu 16.04 on Horizon 7.1
* Agent installer script updated with Horizon 7.1 links
* Updated Media Codec packages for Ubuntu 16.04
* Updated MATE packages to Xenial
* More reliable domain join
* Password update optional
* Timezone update optional
* Option to change hostname
* Desktop addons optional
* Added retry attempts for failed wgets of smb and krb5 configuration files
* Renamed ‘horizon-linux-installer.sh’ to ‘linux-agent-installer.sh

Version: 1.0.0

* Published as _Ubuntu OVA for Horizon_ on VMware Flings
* Base updated to Ubuntu 16.04 LTS
* Requires Horizon 7.0.3 or later

Version: RC2

* Horizon Agent installer script now available
* Domain Join via Winbind is now optional to allow domain flexibility
* Winbind default domain flag optional (previously set to false)
* GNOME Flashback or MATE Desktop Environment option
* OVA RAM increased to 2GB per best practice
* OVA CPU increased to 2 vCPU per best practice
* SVGA properties added to VMX per best practice
* Disable LTS Upgrade Notification
* Some script optimizations

Version: RC1

* Built from Ubuntu’s mini.iso for a minimal footprint
* Installs the MATE desktop environment
* Configures your Timezone
* Updates admin (viewadmin) and root passwords
* Configures DNS servers
* Disables automatic Updates
* Downloads and installs the latest Open VM Tools packages
* Sets default run level to 5
* Sets FQDN in /etc/hosts
* Installs Horizon Agent dependencies
* Installs Winbind
* Configures krb5.conf
* Configures smb.conf
* Joins the domain
* New user home directory config
* Optimizes login screen for VDI
* Remove guest login
* Installs Drivers & Media Codecs
* Currently only supports one domain controller
* Support for 2D desktops only

### Key Considerations

* Note your Active Directory may have different encryption type requirements. These can be modified in krb5.conf
* After rebooting, you can run the command `wbinfo -g` to see your AD groups. This also confirms you are joined to the domain.
* This script defaults the Winbind Separator to "+" in **smb.conf.** You can change it depending on your needs. More info [here](https://communities.vmware.com/docs/DOC-30246).
* Using Winbind means each clone must re-join the domain after creation. You can create a local script on each clone to perform this, but it would require domain admin credentials in plaintext. In a production environment, it is recommended to remotely join your clones to the domain [using PowerCLI or SSH](http://pubs.vmware.com/horizon-7-view/topic/com.vmware.horizon-view.linuxdesktops702.doc/GUID-0C6CE923-3CBB-4006-9081-807B62F474DF.html).
* Consider deleting the scripts from /home/viewadmin prior to creating your clones


## Troubleshooting

### Domain Join

Joining the domain can fail for many reasons. You can try the below tests and review against the guide [here](https://thatvirtualboy.com/2016/09/27/deploying-linux-vdi-pools-with-horizon-7/#::Configure-Ubuntu-to-Integrate-with-Active-Directory).

* If the VM failed to join the domain during the script, attempt manually joining again after the reboot.

   `kinit username@DOMAIN.COM`

   `klist` (to verify you received a ticket)

   `net ads join -U username%password`

   `net ads testjoin` (should say “Join is OK” if it worked)

* If you consistently get the error `This operation is only allowed for the PDC of the domain` try

   `realm join -U username@DOMAIN.COM domaincontroller@domain.com`

* Verify your **hosts**, **KRB5** and **SMB** configuration files reflect the correct addresses and IP addresses.

* Verify there is no time drift between the Ubuntu VM and the DCs. You may need to reconfigure NTP or disable it.

* Sometimes adding the DC to /etc/hosts can help nudge the domain join along

### Agent Status

* If your Horizon Agent status is _Unreachable_ or _Waiting for Agent,_ review the official troubleshooting guide [here](http://pubs.vmware.com/horizon-7-view/topic/com.vmware.horizon-view.linuxdesktops702.doc/GUID-B8DDB7F4-E448-44D2-8F6C-02407BA4A74E.html).

* Some environments may require you to add the Connection Server IP/FQDN to the **/etc/hosts** file. This is usually an environmental DNS issue.

* Some environments may require you to add a search domain to _/etc/netplan/01-netcfg.yaml_ (e.g.,  `search: [corp.local]`)
