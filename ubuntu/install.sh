#!/bin/bash

# Check if Script is Run as Root
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to run this script, please run sudo ./install.sh" 2>&1
  exit 1
fi

username=$(id -u -n 1000)
builddir=$(pwd)

apt update
apt upgrade -y

apt install nala -y

#Remove snap
snap remove --purge firefox
snap remove --purge snap-store
snap remove --purge gnome-3-38-2004
snap remove --purge gnome-42-2204
snap remove --purge gtk-common-themes
snap remove --purge snapd-desktop-integration
snap remove --purge bare
snap remove --purge core20
snap remove --purge canonical-livepatch
snap remove --purge cups
snap remove --purge core22
snap remove core --revision 16091
snap remove --purge snapd
apt remove --autoremove snapd -y
#File to not resintall snap
echo 'Package: snapd
Pin: release a=*
Pin-Priority: -10
' | sudo tee /etc/apt/preferences.d/nosnap.pref
rm -r snap
nala update
apt install --install-suggests gnome-software -y

#Prepare firefox installation
cd $builddir
sudo add-apt-repository ppa:mozillateam/ppa
echo '
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
' | sudo tee /etc/apt/preferences.d/mozilla-firefox
#Prevents updates to install snap firefox
echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";' | sudo tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox

#Install basic packages
cd $builddir
nala install build-essential vim python3 btop ffmpeg firefox fzf tldr neofetch tree ca-certificates curl gnupg cowsay -y

# Add firefox backup
gpg $builddir/linux-installer/apps-settings/firefox.backup.tar.bz2.gpg
tar -xf $builddir/linux-installer/apps-settings/firefox.backup.bz2
rm -r $builddir/linux-installer/apps-settings/firefox.backup.bz2

#Install and configure nvim
cd $builddir
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
mv nvim.appimage /usr/local/bin/nvim
git clone https://github.com/AstroNvim/AstroNvim ~/.config/nvim
git clone https://github.com/matteo-luraghi/astro-nvimsetup ~/.config/nvim/lua/user

#Change Wallpaper
cd $builddir
gsettings set set org.gnome.desktop.background picture-uri-dark file:///home/$username/linux-installer/wallpaper.jpg
gsettings set set org.gnome.desktop.background picture-uri file:///home/$username/linux-installer/wallpaper.jpg
