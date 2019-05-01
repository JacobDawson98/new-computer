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
chess
eiciel
evolution
lagno
lftp
mahjongg
mines
mutt
pidgin
polari
quadrapassel
libreoffice
sudoku
)

for trash in ${bloat[*]}; do
    echo $trash
    zypper rm -y $trash
done

##############################
# Install Packages           #
##############################
zypper update -y

# Version: Leap 15.0 All of Packman
zypper ar -cfp 90 http://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Leap_15.0/ packman
# Switch system package to those in packman as a mix of both can cause a variety of issues.
zypper dup --from packman --allow-vendor-change
zypper refresh

codecs=(
ffmpeg
)

packages=(
git
spotify-installer
vim
python3-pip
discord
MozillaFirefox-devel
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

script_dir = pwd

# Install neofetch
git clone https://github.com/dylanaraps/neofetch ~/neofetch
cd ~/neofetch
make install
cd script_dir

echo ""
cecho "Would you like to install Nvidia drivers? (y/n)" $red
read -r response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
    # Add Nvidia repo
    zypper addrepo --refresh http://http.download.nvidia.com/opensuse/leap/15.0/ NVIDIA
    # Install Nvidia driver
    zypper install-new-recommends -y
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
