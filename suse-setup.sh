#!/bin/sh

echo "OpenSUSE Install Setup Script"

# Set the colours you can use
black=$(tput setaf 0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
white=$(tput setaf 7)

# Resets the style
reset=`tput sgr0`

# Color-echo. Improved. [Thanks @joaocunha]
# arg $1 = message
# arg $2 = Color
cecho() {
  echo "${2}${1}${reset}"
  return
}

# Some configs reused from:
# https://github.com/startcode/autosetup/blob/master/ubuntu_install_common_packages.sh

echo ""
cecho "###############################################" $red
cecho "#        DO NOT RUN THIS SCRIPT BLINDLY       #" $red
cecho "#         YOU'LL PROBABLY REGRET IT...        #" $red
cecho "#                                             #" $red
cecho "#              READ IT THOROUGHLY             #" $red
cecho "#         AND EDIT TO SUIT YOUR NEEDS         #" $red
cecho "###############################################" $red
echo ""

# Set continue to false by default.
CONTINUE=false

echo ""
cecho "Have you read through the script you're about to run and " $red
cecho "understood that it will make changes to your computer? (y/n)" $red
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
  CONTINUE=true
fi

if ! $CONTINUE; then
  # Check if we're continuing and output a message if not
  cecho "Please go read the script, it only takes a few minutes" $red
  exit
fi

# Here we go.. ask for the administrator password upfront and run a
# keep-alive to update existing `sudo` time stamp until script has finished
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

##############################
# Remove bloat               #
##############################
bloat=(
cheese
gnome-chess
gnome-clocks
gnome-contacts
gnome-dictionary
gnome-documents
eiciel
evolution
gnote
iagno
lftp
libreoffice
lightsoff
gnome-logs
gnome-mahjongg
gnome-maps
gnome-mines
gnome-music
mutt
bijiben
gnome-packagekit
gnome-power-manager
gnome-photos
pidgin
polari
quadrapassel
simple-scan
gnome-software
gnome-sudoku
swell-foop
gedit
transmission-gtk
patterns-gnome-gnome
patterns-gnome-gnome_basis
patterns-gnome-gnome_internet
patterns-gnome-gnome_utilities
patterns-gnome-gnome_x11
patterns-desktop-multimedia
patterns-desktop-multimedia_opt
patterns-gnome-gnome_multimedia
patterns-gnome-gnome_office
patterns-office-office
patterns-desktop-imaging
patterns-desktop-imaging_opt
patterns-gnome-gnome_imaging
patterns-gnome-gnome_games
patterns-games-games
)

for trash in ${bloat[*]}; do
    echo $trash
    zypper rm -y $trash
done

# Version: Leap 15.0 All of Packman
zypper ar -cfp 90 http://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Leap_15.0/ packman
# Switch system package to those in packman as a mix of both can cause a variety of issues.
zypper dup --from packman --allow-vendor-change
zypper refresh

##############################
# Install Packages           #
##############################
zypper update -y

codecs=(
ffmpeg
)

packages=(
git
vim
python3-pip
discord
steam
)

for codec in ${codecs[*]}; do
    echo $codec
    zypper install -y $codec
done

for package in ${packages[*]}; do
    echo $package
    zypper install -y $package
done

# Install neofetch
script_dir = pwd
git clone https://github.com/dylanaraps/neofetch ~/neofetch
cd ~/neofetch
make install
cd script_dir

echo ""
cecho "Would you like to automatically mount sdb1 on startup? (y/n)" $red
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo /dev/sdb1    /mnt/exhd    ext4    defaults    0 0 | tee -a /etc/fstab
    mkdir /mnt/exhd
    mount -a
fi

echo ""
cecho "Would you like to install Nvidia drivers? (y/n)" $red
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
    # Add Nvidia repo
    zypper addrepo --refresh http://http.download.nvidia.com/opensuse/leap/15.0/ NVIDIA
    # Install Nvidia driver
    zypper install-new-recommends -auto-agree-with-licenses
fi

cecho "Done!" $cyan
echo ""
echo ""
cecho "################################################################################" $white
echo ""
echo ""
cecho "Note that some of these changes require a logout/restart to take effect." $red
echo ""
echo ""
echo -n "Restart?  (y/n)? "
read response
if [ "$response" != "${response#[Yy]}" ] ;then
    reboot
fi
