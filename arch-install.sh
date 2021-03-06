#!/bin/bash

if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

clear_screen () {
  printf '\033c'
}

clear_screen
echo -e "\tArch install script"
echo "author: senpai-10 | https://github.com/Senpai-10/"

pacman --noconfirm -Sy archlinux-keyring dialog

partitioning=$(dialog --menu "Select partitioning:" 10 30 4 \
  1 mbr \
  2 gpt --output-fd 1)

drive=$(dialog --output-fd 1 --menu "Select drive:" 20 40 8 \
  $(lsblk -n --output NAME,SIZE))

hostname=$(dialog --output-fd 1 --inputbox "Hostname: " 10 40)

while true; do
  root_password=$(dialog --output-fd 1 --inputbox "Root password: " 10 40)
  retype_root_password=$(dialog --output-fd 1 --inputbox "Root password (retype): " 10 40)
  [ "$root_password" = "$retype_root_password" ] && break
  dialog --msgbox "Please make sure your passwords match" 5 45
done

username=$(dialog --output-fd 1 --inputbox "Username: " 10 40)
while true; do
  user_password=$(dialog --output-fd 1 --inputbox "$username password: " 10 40)
  retype_user_password=$(dialog --output-fd 1 --inputbox "$username password (retype): " 10 40)
  [ "$user_password" = "$retype_user_password" ] && break
  dialog --msgbox "Please make sure your passwords match" 5 45
done

clear_screen
echo "Selecting the fastest mirrors"
reflector --latest 100 --sort rate --save /etc/pacman.d/mirrorlist --protocol https
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf

loadkeys us
timedatectl set-ntp true

if [ "$partitioning" == "1" ]; then
  # bios/mbr
  echo "o
n
p
1

+4GB
t
82
p
n
p
2


w" | fdisk /dev/$drive
elif [ "$partitioning" == "2" ]; then
  # uefi
  echo "This option does not work for now!"
  exit
else
  echo "${partitioning} is not a vaild option! (uefi, mbr)"
  exit
fi

mkswap /dev/${drive}1
swapon /dev/${drive}1

mkfs.ext4 /dev/${drive}2
mount /dev/${drive}2 /mnt

pacstrap /mnt base base-devel linux-lts linux-lts-headers linux linux-headers linux-firmware neovim
genfstab -U /mnt >> /mnt/etc/fstab

echo -e "drive=$drive\n" > /mnt/arch-install-2
echo -e "hostname=$hostname\n" >> /mnt/arch-install-2
echo -e "root_password=$root_password\n" >> /mnt/arch-install-2
echo -e "username=$username\n" >> /mnt/arch-install-2
echo -e "user_password=$user_password\n" >> /mnt/arch-install-2

sed '1,/^#part2$/d' arch-install.sh >> /mnt/arch-install-2
chmod +x /mnt/arch-install-2
arch-chroot /mnt ./arch-install-2
exit

#part2
clear_screen () {
  printf '\033c'
}
clear_screen
pacman -S --noconfirm sed git dialog
sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
ln -sf /usr/share/zoneinfo/Asia/Riyadh /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo $hostname > /etc/hostname
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $hostname.localdomain $hostname" >> /etc/hosts
echo "root:$root_password" | chpasswd
pacman --noconfirm -Sy grub networkmanager network-manager-applet \
  wireless_tools wpa_supplicant os-prober mtools dosfstools
grub-install --target=i386-pc /dev/$drive
grub-mkconfig -o /boot/grub/grub.cfg
pacman -S --noconfirm xorg-xwud \
    xorg-xwininfo xorg-xwd xorg-xvinfo xorg-xset \
    xorg-xrefresh xorg-xrdb ttf-fantasque-sans-mono \
    ttf-fira-code ttf-liberation virt-manager virt-viewer wget \
    xbindkeys xorg-bdftopcf xorg-docs xorg-font-util \
    xorg-fonts-100dpi xorg-fonts-75dpi \
    xorg-fonts-encodings xorg-iceauth xorg-mkfontscale \
    xorg-server xorg-server-common xorg-server-devel \
    xorg-server-xephyr xorg-server-xnest xorg-server-xvfb \
    xorg-sessreg xorg-setxkbmap xorg-smproxy xorg-x11perf \
    xorg-xauth xorg-xbacklight xorg-xcmsdb xorg-xcursorgen \
    xorg-xdpyinfo xorg-xdriinfo xorg-xev xorg-xgamma \
    xorg-xhost xorg-xinput xorg-xkbcomp \
    xorg-xpr xorg-xrandr alacritty alsa-tools alsa-utils atom \
    bashtop bat bc bitwarden \
    bitwarden-cli bspwm cmus code discord \
    dmenu dnsmasq docker easytag emacs \
    fd feh fff ffmpegthumbnailer ffmpegthumbs \
    flameshot gimp gnome-calculator \
    highlight htop imwheel jgmenu kitty \
    lib32-libpulse libguestfs libpng12 libvirt \
    lxappearance lxappearance-obconf menumaker nautilus nemo neofetch \
    nitrogen nnn nodejs npm obconf onboard openbox \
    pavucontrol pulseaudio pulseaudio-alsa \
    pulseaudio-equalizer pulseaudio-jack \
    python-setuptools qemu qemu-arch-extra redis \
    reflector rofi rxvt-unicode scrot sdl_image steam \
    terminus-font tree ttf-dejavu ttf-droid \
    xorg-xkbevd xorg-xkbutils xorg-xlsatoms \
    xorg-xlsclients xorg-xmodmap xorg-xinit xorg-xkill \
    xorg-xsetroot xorg-xprop noto-fonts noto-fonts-emoji \
    noto-fonts-cjk ttf-jetbrains-mono ttf-joypixels ttf-font-awesome \
    sxiv mpv zathura zathura-pdf-mupdf ffmpeg imagemagick  \
    fzf man-db python-pywal youtube-dl xclip maim \
    zip unzip unrar p7zip xdotool papirus-icon-theme  \
    ntfs-3g sxhkd zsh \
    arc-gtk-theme rsync firefox dash \
    slock jq dhcpcd pamixer which yarn yad \
    kdenlive kate gparted \
	gtk4 gtop hwinfo tint2 dbeaver awesome picom libwacom eog github-cli
systemctl enable NetworkManager.service
chsh -s $(which zsh)
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
useradd -m -G wheel $username
echo "$username:$user_password" | chpasswd
echo "pre-Installation Finish Reboot now"
arch_install_3_path=/home/$username/arch-install-3
sed '1,/^#part3$/d' arch-install-2 > $arch_install_3_path
chown $username:$username $arch_install_3_path
chmod +x $arch_install_3_path
echo "source $arch_install_3_path" >> /home/$username/.bash_profile
echo "source $arch_install_3_path" >> /home/$username/.zsh_profile
clear_screen
printf "\033[0;31mREMOVE INSTALLATION MEDIUM AND REBOOT\033[0m"
# su -c $arch_install_3_path -s /bin/sh $username
exit

#part3
clear_screen () {
  printf '\033c'
}
clear_screen
cd $HOME
# clone dotfiles and rename to .dotfiles
# remove old arch script and use it just for backups and copying dotfiles
sed -i '/arch/d' .bash_profile
sed -i '/arch/d' .zsh_profile
chsh -s $(which zsh)
git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si && cd ..
yay -S --noconfirm alacritty-themes
yay -S --noconfirm brave-bin
yay -S --noconfirm btops-git
yay -S --noconfirm cava-git
yay -S --noconfirm code-marketplace
yay -S --noconfirm colorpicker
yay -S --noconfirm compton-conf-git
yay -S --noconfirm consolas-font
yay -S --noconfirm deadd-notification-center-bin
yay -S --noconfirm discord-qt-appimage
yay -S --noconfirm dxhd-bin
yay -S --noconfirm figma-linux
yay -S --noconfirm fontpreview-ueberzug-git
yay -S --noconfirm google-chrome
yay -S --noconfirm lf-bin
yay -S --noconfirm ls-icons
yay -S --noconfirm mongodb-bin
yay -S --noconfirm mongodb-tools-bin
yay -S --noconfirm mongosh-bin
yay -S --noconfirm nerd-fonts-complete
yay -S --noconfirm noto-fonts-sc
yay -S --noconfirm otf-symbola
yay -S --noconfirm polybar
yay -S --noconfirm selectdefaultapplication-git
yay -S --noconfirm spacefm
yay -S --noconfirm spaceship-prompt-git
yay -S --noconfirm spotify
yay -S --noconfirm ttf-icomoon-feather
yay -S --noconfirm ttf-material-icons-git
yay -S --noconfirm ttf-ms-fonts
yay -S --noconfirm pnpm-bin
yay -S --noconfirm betterdiscord-installer-bin
yay -S --noconfirm snapd
yay -S --noconfirm pamac-all
yay -S --noconfirm icons-in-terminal
yay -S --noconfirm inxi
yay -S --noconfirm epson-inkjet-printer-escpr
yay -S --noconfirm gromit-mpx
yay -S --noconfirm tlauncher
yay -S --noconfirm vtop
yay -S --noconfirm xsetwacom
yay -S --noconfirm pyinstaller
yay -S --noconfirm smenu
yay -S --noconfirm notion-app
yay -S --noconfirm discover-overlay

curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

git clone https://github.com/senpai-10/dotfiles ~/.dotfiles &&
cd ~/.dotfiles

mkdir -pv ~/Documents
mkdir -pv ~/Pictures
mkdir -pv ~/Downloads
mkdir -pv ~/Music
mkdir -pv ~/Videos
mkdir -pv ~/Screenshots
mkdir -pv ~/mpv_screenshots
mkdir -pv ~/AppImages
mkdir -pv ~/clone
mkdir -pv ~/suckless
sudo mkdir -pv /usr/share/cmus/
sudo mkdir -pv /usr/local/share/fonts

cp -rfv dotfiles/.config ~/
cp -av dotfiles/home/. ~/
cp fonts/* ~/.local/share/fonts/
sudo cp themes/cmus/*.theme /usr/share/cmus/

sudo systemctl enable libvirtd --now
sudo usermod -a -G libvirt $USER

sudo curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
sudo chmod a+rx /usr/local/bin/yt-dlp

flameshot config --showhelp false
jgmenu_run init --theme=archlabs_1803
sh -c "$(curl -fsSL https://starship.rs/install.sh)"

git clone https://github.com/powerline/fonts.git &&
cd fonts && ./install.sh && cd ..

wget https://support.steampowered.com/downloads/1974-YFKL-4947/SteamFonts.zip &&
unzip SteamFonts.zip -d SteamFonts/ && rm SteamFonts.zip &&
sudo mv SteamFonts/* /usr/local/share/fonts &&
rm -rf SteamFonts/

git clone https://github.com/thameera/vimv.git &&
sudo cp vimv/vimv /usr/local/bin/ &&
sudo chmod +x /usr/local/bin/vimv

wget https://github.com/Superjo149/auryo/releases/download/v2.5.4/Auryo-2.5.4.AppImage &&
chmod +x Auryo-2.5.4.AppImage &&
mv Auryo-2.5.4.AppImage ~/AppImages/auryo

wget https://download.kde.org/stable/krita/4.4.8/krita-4.4.8-x86_64.appimage &&
chmod +x krita-4.4.8-x86_64.appimage &&
mv krita-4.4.8-x86_64.appimage ~/AppImages/krita

wget https://github.com/ppy/osu/releases/download/2021.907.0/osu.AppImage &&
chmod +x osu.AppImage &&
mv osu.AppImage ~/AppImages/osu

wget https://hyperbeam.com/download/linux &&
chmod +x linux &&
mv linux ~/AppImages/hyperbeam

wget https://github.com/notable/notable/releases/download/v1.8.4/Notable-1.8.4.AppImage &&
chmod +x Notable-1.8.4.AppImage &&
mv Notable-1.8.4.AppImage ~/AppImages/notable

cd /tmp

git clone https://github.com/Senpai-10/cmus-rpc.git && cd cmus-rpc && make install; cd ~/

cd ~/suckless

git clone https://github.com/siduck/st.git && cd st && sudo make install ; cd ..
# install dwm, dmenu, dwmblocks
git clone https://github.com/Senpai-10/dwm.git && cd dwm && sudo make install ; cd ..
git clone https://github.com/Senpai-10/dmenu.git && cd dmenu && sudo make install ; cd ..
git clone https://github.com/Senpai-10/dwmblocks.git && cd dwmblocks && sudo make install ; cd ..
git clone https://github.com/Senpai-10/tabbed.git && cd tabbed && sudo make install ; cd ~/

sudo sed -i '$ d' /etc/sudoers
sudo echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

echo "Remove all installation files!"
sudo rm /arch-install-2
rm -- "$0" # remove arch-install-3
exit
