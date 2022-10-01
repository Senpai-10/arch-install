#!/usr/bin/env bash

VERSION="0.1.0"

#########################
#   Config
#
#   EDIT THIS PART

#   !!!!!!!!!!!!!!!! READ THIS !!!!!!!!!!!!!!!!
#
#   Set this to true if you don't want to install my (senpai-10) dotfiles
#   and packages, and Just do a minimal installation.
#
ONLY_DO_BASE_INSTALLATION=false

# Computer name
# example: "my-desktop"
HOSTNAME=""

# root user password
ROOT_PASSWORD=""

# your username
USERNAME=""

# your user password
USER_PASSWORD=""

KEYMAP="us"

# drive partitioning table scheme
# Values:
#       gpt
#       mbr
# if you are using an old computer select mbr
PARTITIONING_SCHEME=""

# System installation drive
# use lsblk command to know what drive to use
# be carefull your drive will be formatted and you will lose all data
# example: "/dev/sda"
DRIVE=""

# select if you want a swap file or a swap partition
# Values:
#       file
#       partition
SWAP_TYPE=""

# The size of your swap partition/file
# Values:
#       {size{G,M}}
# example: 8G
# this example will create a 8 gigabytes swap partition/file
SWAP_SIZE=""

#########################

if [[ $PARTITIONING_SCHEME = "gpt" ]] && [[ $SWAP_TYPE = "partition" ]]; then
    EFI_SYSTEM_PARTITION="${DRIVE}1"
    SWAP_PARTITION="${DRIVE}2"
    ROOT_PARTITION="${DRIVE}3"
fi

if [[ $PARTITIONING_SCHEME = "gpt" ]] && [[ $SWAP_TYPE = "file" ]]; then
    EFI_SYSTEM_PARTITION="${DRIVE}1"
    ROOT_PARTITION="${DRIVE}2"
fi

if [[ $PARTITIONING_SCHEME = "mbr" ]] && [[ $SWAP_TYPE = "partition" ]]; then
    SWAP_PARTITION="${DRIVE}1"
    ROOT_PARTITION="${DRIVE}2"
fi

if [[ $PARTITIONING_SCHEME = "mbr" ]] && [[ $SWAP_TYPE = "file" ]]; then
    ROOT_PARTITION="${DRIVE}1"
fi

#########################
#   colors

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

# Underline
UBlack='\033[4;30m'       # Black
URed='\033[4;31m'         # Red
UGreen='\033[4;32m'       # Green
UYellow='\033[4;33m'      # Yellow
UBlue='\033[4;34m'        # Blue
UPurple='\033[4;35m'      # Purple
UCyan='\033[4;36m'        # Cyan
UWhite='\033[4;37m'       # White

# Background
On_Black='\033[40m'       # Black
On_Red='\033[41m'         # Red
On_Green='\033[42m'       # Green
On_Yellow='\033[43m'      # Yellow
On_Blue='\033[44m'        # Blue
On_Purple='\033[45m'      # Purple
On_Cyan='\033[46m'        # Cyan
On_White='\033[47m'       # White

# High Intensity
IBlack='\033[0;90m'       # Black
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
IPurple='\033[0;95m'      # Purple
ICyan='\033[0;96m'        # Cyan
IWhite='\033[0;97m'       # White

# Bold High Intensity
BIBlack='\033[1;90m'      # Black
BIRed='\033[1;91m'        # Red
BIGreen='\033[1;92m'      # Green
BIYellow='\033[1;93m'     # Yellow
BIBlue='\033[1;94m'       # Blue
BIPurple='\033[1;95m'     # Purple
BICyan='\033[1;96m'       # Cyan
BIWhite='\033[1;97m'      # White

# High Intensity backgrounds
On_IBlack='\033[0;100m'   # Black
On_IRed='\033[0;101m'     # Red
On_IGreen='\033[0;102m'   # Green
On_IYellow='\033[0;103m'  # Yellow
On_IBlue='\033[0;104m'    # Blue
On_IPurple='\033[0;105m'  # Purple
On_ICyan='\033[0;106m'    # Cyan
On_IWhite='\033[0;107m'   # White

NO_COLOR='\033[0m'

#########################

function main {
    check_missing_configs

    check_internet_connection

    print_banner

    echo -e "source: ${BIYellow}https://github.com/senpai-10/arch-install${NO_COLOR}"
    echo -e "Version: ${BIYellow}${VERSION}${NO_COLOR}"

    print_debug EFI_SYSTEM_PARTITION: $EFI_SYSTEM_PARTITION
    print_debug SWAP_PARTITION: $SWAP_PARTITION
    print_debug ROOT_PARTITION: $ROOT_PARTITION

    if [[ $1 = "--run-arch-chroot" ]]; then
        configure_the_system
    else
        # stop executing the script and wait for any key press
        # in case the script was ran by accident
        read -rsn1 -p"Press any key to continue " variable;echo

        pre_installation
        main_installation
    fi
}

function print_banner {
    echo -e $IGreen
    cat << "EOF"
                 _           _           _        _ _
   __ _ _ __ ___| |__       (_)_ __  ___| |_ __ _| | | ___ _ __
  / _` | '__/ __| '_ \ _____| | '_ \/ __| __/ _` | | |/ _ \ '__|
 | (_| | | | (__| | | |_____| | | | \__ \ || (_| | | |  __/ |
  \__,_|_|  \___|_| |_|     |_|_| |_|___/\__\__,_|_|_|\___|_|
EOF
    echo -e $NO_COLOR
}

function print_info {
    echo -e "[${IBlue}INFO${NO_COLOR}] ${IYellow}$@${NO_COLOR}"
}

function print_error {
    echo -e "[${IRed}ERROR${NO_COLOR}] ${IYellow}$@${NO_COLOR}"
}

function print_warning {
    echo -e "[${IYellow}WARNING${NO_COLOR}] ${IYellow}$@${NO_COLOR}"
}

function print_debug {
    echo -e "[${IGreen}DEBUG${NO_COLOR}] ${IYellow}$@${NO_COLOR}"
}

function check_missing_configs {
    if [[ -z $HOSTNAME || -z $ROOT_PASSWORD || -z $USERNAME || -z $USER_PASSWORD ]]; then
        print_error "Missing some configs!\n\tedit arch-installer.sh and set the config!"
        exit 1
    fi
}
function check_internet_connection {
    print_info "Checking internet connection..."

    ping -c1 "8.8.8.8" &>"/dev/null"

    if [[ "${?}" -ne 0 ]]; then
        print_error "No internect connection. Exiting now!"
        exit 1
    elif [[ "${#args[@]}" -eq 0 ]]; then
        print_info "internet connection found!"
    fi
}

function pre_installation {
    sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
    sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

    pacman -Sy

    loadkeys $KEYMAP

    timedatectl set-ntp true

    ECHO_FDISK=""

    if [[ $PARTITIONING_SCHEME = "mbr" ]]; then
        ECHO_FDISK+="o\n"
    fi

    if [[ $PARTITIONING_SCHEME = "gpt" ]]; then
        ECHO_FDISK+="g\n"
        # Create boot partition
        ECHO_FDISK+="n\n"
        ECHO_FDISK+="\n"
        ECHO_FDISK+="\n"
        ECHO_FDISK+="+300M\n"
        ECHO_FDISK+="t\n"
        ECHO_FDISK+="uefi\n"
    fi

    if [[ $SWAP_TYPE = "partition" ]]; then
        ECHO_FDISK+="n\n"
        if [[ $PARTITIONING_SCHEME = "mbr" ]]; then
            # select primary partition
            ECHO_FDISK+="p\n"
        fi
        # auto select partition number
        ECHO_FDISK+="\n"
        # select first sector
        ECHO_FDISK+="\n"
        ECHO_FDISK+="+$SWAP_SIZE\n"
        # change partition type
        ECHO_FDISK+="t\n"
        ECHO_FDISK+="\n"
        # select linux swap partition
        ECHO_FDISK+="swap\n"
    fi

    # create root partition
    ECHO_FDISK+="n\n"
    if [[ $PARTITIONING_SCHEME = "mbr" ]]; then
        # select primary partition
        ECHO_FDISK+="p\n"
    fi
    ECHO_FDISK+="\n"
    ECHO_FDISK+="\n"
    ECHO_FDISK+="\n"
    ECHO_FDISK+="w"

    echo -e $ECHO_FDISK | fdisk -L=always $DRIVE

    mkfs.ext4 $ROOT_PARTITION

    if [[ $SWAP_TYPE = "partition" ]]; then
        mkswap $SWAP_PARTITION

        swapon $SWAP_PARTITION
    fi

    if [[ $PARTITIONING_SCHEME = "gpt" ]]; then
        mkfs.fat -F 32 $EFI_SYSTEM_PARTITION
    fi

    mount $ROOT_PARTITION /mnt

    if [[ $PARTITIONING_SCHEME = "gpt" ]]; then
        mount --mkdir $EFI_SYSTEM_PARTITION /mnt/boot
    fi
}

function main_installation {
        reflector --latest 20 --sort rate --save /etc/pacman.d/mirrorlist --protocol https --verbose

        local BASE_PACKAGES="base base-devel linux-lts linux-lts-headers linux linux-headers linux-firmware neovim"

        pacstrap /mnt $BASE_PACKAGES

        genfstab -U /mnt >> /mnt/etc/fstab

        cp arch-installer.sh /mnt/

        arch-chroot /mnt ./arch-installer.sh --run-arch-chroot
        exit
}

function configure_the_system {
    # inside arch-chroot

    sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
    sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

    pacman -Sy

    reflector --latest 20 --sort rate --save /etc/pacman.d/mirrorlist --protocol https --verbose

    local TIME_ZONE=$(curl --fail https://ipapi.co/timezone)

    ln -sf /usr/share/zoneinfo/$TIME_ZONE /etc/localtime

    hwclock --systohc

    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen

    locale-gen

    echo "LANG=en_US.UTF-8" > /etc/locale.conf

    echo $HOSTNAME > /etc/hostname

    echo "127.0.0.1       localhost" >> /etc/hosts
    echo "::1             localhost" >> /etc/hosts
    echo "127.0.1.1       $HOSTNAME.localdomain $HOSTNAME" >> /etc/hosts

    echo "root:$ROOT_PASSWORD" | chpasswd

    pacman --noconfirm -S grub efibootmgr networkmanager network-manager-applet wireless_tools wpa_supplicant os-prober mtools dosfstools

    if [[ $PARTITIONING_SCHEME = "mbr" ]]; then
        grub-install --target=i386-pc $DRIVE
    fi

    if [[ $PARTITIONING_SCHEME = "gpt" ]]; then
        grub-install --target=x86_64-efi $DRIVE --efi-directory=$EFI_SYSTEM_PARTITION --bootloader-id=GRUB
    fi

    grub-mkconfig -o /boot/grub/grub.cfg

    os-prober

    USER_PACKAGES="xorg-xwud xorg-xwininfo xorg-xwd xorg-xvinfo xorg-xset xorg-xrefresh xorg-xrdb ttf-fantasque-sans-mono ttf-fira-code ttf-liberation virt-manager virt-viewer wget xbindkeys xorg-bdftopcf xorg-docs xorg-font-util xorg-fonts-100dpi xorg-fonts-75dpi xorg-fonts-encodings xorg-iceauth xorg-mkfontscale xorg-server xorg-server-common xorg-server-devel xorg-server-xephyr xorg-server-xnest xorg-server-xvfb xorg-sessreg xorg-setxkbmap xorg-smproxy xorg-x11perf xorg-xauth xorg-xbacklight xorg-xcmsdb xorg-xcursorgen xorg-xdpyinfo xorg-xdriinfo xorg-xev xorg-xgamma xorg-xhost xorg-xinput xorg-xkbcomp xorg-xpr xorg-xrandr alacritty alsa-tools alsa-utils atom bashtop bat bc bitwarden bitwarden-cli bspwm cmus code discord dmenu dnsmasq docker easytag emacs fd feh fff ffmpegthumbnailer ffmpegthumbs flameshot gimp gnome-calculator highlight htop imwheel jgmenu lib32-libpulse libguestfs libpng12 libvirt lxappearance lxappearance-obconf menumaker nemo neofetch nitrogen nodejs npm obconf onboard pavucontrol python-setuptools qemu qemu-arch-extra redis reflector rofi rxvt-unicode scrot sdl_image steam terminus-font tree ttf-dejavu ttf-droid xorg-xkbevd xorg-xkbutils xorg-xlsatoms xorg-xlsclients xorg-xmodmap xorg-xinit xorg-xkill xorg-xsetroot xorg-xprop noto-fonts noto-fonts-emoji noto-fonts-cjk ttf-jetbrains-mono ttf-joypixels ttf-font-awesome sxiv mpv zathura zathura-pdf-mupdf ffmpeg imagemagick fzf man-db python-pywal youtube-dl xclip maim zip unzip unrar p7zip xdotool papirus-icon-theme ntfs-3g sxhkd zsh arc-gtk-theme rsync firefox dash slock jq dhcpcd pamixer which yarn yad kdenlive kate gparted gtk4 gtop hwinfo tint2 dbeaver awesome picom libwacom eog github-cli transmission-gtk"

    pacman -S --noconfirm $USER_PACKAGES

    systemctl enable NetworkManager.service

    chsh -s $(which zsh)

    echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

    useradd -m -G wheel $USERNAME

    echo "$USERNAME:$USER_PASSWORD" | chpasswd

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

    exit
}

main $1
