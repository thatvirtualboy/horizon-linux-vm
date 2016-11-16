# Horizon Linux VM
Optimized Ubuntu Template for VMware Horizon 7

Ubuntu MATE Desktop is the perfect Virtual Desktop Infrastructure (VDI) alternative to Windows for VDI Admins who are looking to move away from a Windows-centric desktop delivery. With an infrastructure utilizing VMware Horizon 7, this script aims to ease the setup and configuration of a Ubuntu Template VM, especially for Windows Admins that aren’t familiar with a Linux desktop.

## Instructions

### Preconfigured Ubuntu OVA
* Base image is Ubuntu 14.04.5 LTS x64 (final image is < 5GB!)
* VMware HW v11 (requires ESXi 6.0)
* Default username/password is viewadmin/viewadmin
* The VM includes the optimization script which configures VM to Best Practices per Horizon 7 Documentation
* Additional system tweaks and applications may be necessary for your needs. 
* Due to licensing, the Horizon Agent is not included in this OVA. It must be installed manually after booting and running the script. 

### Steps:
1. Download the pre packaged OVA & deploy to your datacenter
2. Boot the VM and ensure you get a valid IP and can reach the internet
3. Open a console to the VM and login as viewadmin/viewadmin
4. Open Terminal and type `sudo apt-get update && sudo apt-get upgrade`
5. Install all available updates and reboot if prompted
6. Open Terminal and type `su root -c ./horizon-optimizer.sh`
7. Enter the root password (viewadmin)
8. Follow the prompts 

Once complete, you can manually install the VMware Horizon Agent following instructions [here](http://pubs.vmware.com/horizon-7-view/topic/com.vmware.horizon-view.linuxdesktops702.doc/GUID-F1CE6329-250C-44BF-9708-7155539275E1.html) then proceed to building your pools.


### Changelog
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
* install Horizon Agent 
* Configure RunOneScript
* Installs Drivers & Media Codecs
* Currently only supports one domain controller
* Support for 2D desktops only

### Key Considerations

* Note your Active Directory may have different encryption type requirements. These can be modified in krb5.conf 
* After rebooting, you can run the command `wbinfo -g` to see your AD groups. This also confirms you are joined to the domain.
* Consider deleting the script from /home/viewadmin prior to creating your clones
* Using Winbind means each clone must re-join the domain after creation. You can create a local script on each clone to perform this, but it would require domain admin credentials in plaintext. In a production environment, it is recommended to remotely join your clones to the domain using PowerCLI or SSH: http://pubs.vmware.com/horizon-7-view/topic/com.vmware.horizon-view.linuxdesktops702.doc/GUID-0C6CE923-3CBB-4006-9081-807B62F474DF.html 


### Troubleshooting Domain Join

Joining the domain can fail for many reasons. You can try the below tests and review against the guide at https://thatvirtualboy.com/2016/09/27/deploying-linux-vdi-pools-with-horizon-7/#::Configure-Ubuntu-to-Integrate-with-Active-Directory 

If the VM failed to join the domain during the script, attempt manually joining again after the reboot.

`kinit username@DOMAIN.COM`
`klist` (to verify you received a ticket)
`net ads join -U username%password`
`net ads testjoin` (should say “Join is OK” if it worked)

Verify your hosts, KRB5 and SMB configuration files reflect the correct addresses and IP addresses.

Verify there is no time drift between the Ubuntu VM and the DCs. You may need to reconfigure NTP or disable it.
