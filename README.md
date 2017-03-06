# Horizon Linux VM
Optimized Ubuntu Template for VMware Horizon 7

Ubuntu Desktop is the perfect Virtual Desktop Infrastructure (VDI) alternative to Windows for VDI Admins who are looking to move away from a Windows-centric desktop delivery. With an infrastructure utilizing VMware Horizon 7, this pre-packaged OVA aims to ease the setup and configuration of a Ubuntu Template VM, especially for Windows Admins that aren’t familiar with a Linux desktop. This OVA allows for two configurations:

### GNOME Flashback (Metacity) - Official VMware Supported DE
<p align="center"><img src="https://cloud.githubusercontent.com/assets/13758243/20696129/c0cd753c-b5ae-11e6-8ea6-7c52087fbdaa.png" height="593" width="765"></p>

### MATE - UNofficial DE (No VMware Support)
<p align="center"><img src="https://cloud.githubusercontent.com/assets/13758243/20411504/fef10d34-acde-11e6-8a1f-1a03620fb9fc.png" height="593" width="765"></p>

## Instructions

### Preconfigured Ubuntu OVA
* Base image is Ubuntu 14.04.5 LTS x64 (final image is < 5GB!)
* VMware HW v11 (requires ESXi 6.0)
* Default username/password is viewadmin/viewadmin
* The VM includes the optimization script which configures VM to Best Practices per Horizon 7 Documentation
* Additional system tweaks and applications may be necessary for your needs. 
* Due to licensing limitations, the Horizon Agent is _currently_ not included in this OVA. It must be downloaded manually after booting and running the script. 
* Horizon Linux VM has been tested with Windows 2003 & 2008 Domains and Samba Domains

### Steps:
1. [Download](https://rakdom.asuscomm.com/owncloud/s/77XOOVUiEHoAScs) the pre packaged OVA & deploy to your datacenter // ~~CURRENTLY UNAVAILABLE. A fiber cable was crushed in my neighborhood causing a major outage. Hopefully back up Dec. 6th. Follow my twitter account (@thatvirtualboy) for updates.~~
2. Boot the VM and ensure you get a valid IP and can reach the internet
3. Open a console to the VM and login as viewadmin/viewadmin
4. Open Terminal and type `sudo apt-get update && sudo apt-get upgrade`
5. Install all available updates and reboot if prompted
6. Open Terminal and type `su root -c ./horizon-optimizer.sh`
7. Enter the root password (viewadmin)
8. Follow the prompts

Once complete, you can manually install the VMware Horizon Agent following instructions [here](http://pubs.vmware.com/horizon-7-view/topic/com.vmware.horizon-view.linuxdesktops702.doc/GUID-F1CE6329-250C-44BF-9708-7155539275E1.html) or invoke the _linux-agent-installer.sh_ script by typing `su root -c ./linux-agent-installer.sh` then proceed to building your pools.


### Changelog
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
   
* If you consitently get the error `This operation is only allowed for the PDC of the domain` try

   `realm join -U username@DOMAIN.COM domaincontroller@domain.com`

* Verify your **hosts**, **KRB5** and **SMB** configuration files reflect the correct addresses and IP addresses.

* Verify there is no time drift between the Ubuntu VM and the DCs. You may need to reconfigure NTP or disable it.

* Sometimes adding the DC to /etc/hosts can help nudge the domain join along

### Agent Status

If your Horizon Agent status is _Unreachable_ or _Waiting for Agent,_ review the official troubleshooting guide [here](http://pubs.vmware.com/horizon-7-view/topic/com.vmware.horizon-view.linuxdesktops702.doc/GUID-B8DDB7F4-E448-44D2-8F6C-02407BA4A74E.html).

Additionally, some environments may require you to add the Connection Server IP/FQDN to the **/etc/hosts** file. This is usually an environmental DNS issue.
