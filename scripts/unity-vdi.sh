#! /bin/bash
#
# Unity Tweaks for using the Unity Desktop in a VDI environment
#

#################################################
#                                               #
# >>> THIS SCRIPT IS INCOMPLETE. DO NOT USE <<< #
#                                               #
#################################################


# Disable screensaver blackout
gsettings set org.gnome.desktop.session idle-delay 0

# Show username in panel
gsettings set com.canonical.indicator.session show-real-name-on-panel true

# Disable online search results
gsettings set com.canonical.Unity.Lenses remote-content-search none

# Fix Ubuntu scrollbar
gsettings set com.canonical.desktop.interface scrollbar-mode normal
