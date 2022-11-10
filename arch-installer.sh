#!/usr/bin/env bash

set -eu

VERSION="0.1.2"

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

# your username
USERNAME=""

# your user password
USER_PASSWORD=""

# root user password
ROOT_PASSWORD=""

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

# The size of your swap partition
# Values:
#       {size{G,M}}
# example: 8G
SWAP_SIZE=""

ROOT_PARTITION_SIZE=""

# Empty for the rest of the drive!
# or '120G'
HOME_PARTITION_SIZE=""


#########################

if [[ $PARTITIONING_SCHEME = "gpt" ]]; then
    EFI_SYSTEM_PARTITION="${DRIVE}1"
    SWAP_PARTITION="${DRIVE}2"
    ROOT_PARTITION="${DRIVE}3"
    HOME_PARTITION="${DRIVE}4"
fi

if [[ $PARTITIONING_SCHEME = "mbr" ]]; then
    SWAP_PARTITION="${DRIVE}1"
    ROOT_PARTITION="${DRIVE}2"
    HOME_PARTITION="${DRIVE}3"
fi

#########################
# BEGIN colors
#########################

# High Intensity
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue

BIYellow='\033[1;93m'     # Yellow

NO_COLOR='\033[0m'

#########################
# END colors
#########################

function main {
    check_missing_configs

    check_internet_connection

    print_banner

    echo -e "source: ${BIYellow}https://github.com/senpai-10/arch-install${NO_COLOR}"
    echo -e "Version: ${BIYellow}${VERSION}${NO_COLOR}"

    if [[ $1 = "stage_2" ]]; then
        stage_2_configure_the_system
    elif [[ $1 = "stage_3" ]]; then
        stage_3_post_installation
    else
        # stop executing the script and wait for any key press
        # in case the script was ran by accident
        read -rsn1 -p"Press any key to continue " ;echo

        stage_0_pre_installation
        stage_1_main_installation
    fi

}

function print_banner {
    echo -e "$IGreen"
    cat << "EOF"
                 _           _           _        _ _
   __ _ _ __ ___| |__       (_)_ __  ___| |_ __ _| | | ___ _ __
  / _` | '__/ __| '_ \ _____| | '_ \/ __| __/ _` | | |/ _ \ '__|
 | (_| | | | (__| | | |_____| | | | \__ \ || (_| | | |  __/ |
  \__,_|_|  \___|_| |_|     |_|_| |_|___/\__\__,_|_|_|\___|_|
EOF
    echo -e "$NO_COLOR"
}

function print_info {
    echo -e "[${IBlue}INFO${NO_COLOR}] ${IYellow}$*${NO_COLOR}"
}

function print_error {
    echo -e "[${IRed}ERROR${NO_COLOR}] ${IYellow}$*${NO_COLOR}"
}

function print_warning {
    echo -e "[${IYellow}WARNING${NO_COLOR}] ${IYellow}$*${NO_COLOR}"
}

function print_debug {
    echo -e "[${IGreen}DEBUG${NO_COLOR}] ${IYellow}$*${NO_COLOR}"
}

function check_missing_configs {
    if [[ -z $HOSTNAME || -z $ROOT_PASSWORD || -z $USERNAME || -z $USER_PASSWORD ]]; then
        print_error "Missing some configs!\n\tedit arch-installer.sh and set the config!"
        exit 1
    fi
}

function check_internet_connection {
    print_info "Checking internet connection..."

    # Because of set -e
    # if ping fails it will exit with non zero code
    ping -c1 "8.8.8.8" &>"/dev/null"

    print_info "internet connection found!"
}

function stage_0_pre_installation {
    sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
    sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

    pacman -Sy

    loadkeys $KEYMAP

    timedatectl set-ntp true

    if [[ $PARTITIONING_SCHEME = "mbr" ]]; then
        echo 'label: mbr' | sfdisk "$DRIVE"
    fi

    if [[ $PARTITIONING_SCHEME = "gpt" ]]; then
        echo 'label: gpt' | sfdisk "$DRIVE"

        # Create boot partition
        echo -e 'size=+300M, type=uefi' | sfdisk --append "$DRIVE"
    fi

    # create swap partition
    echo -e "size=+$SWAP_SIZE, type=swap" | sfdisk --append "$DRIVE"

    # create root partition
    echo -e "size=+$ROOT_PARTITION_SIZE, type=linux" | sfdisk --append "$DRIVE"

    # create home partition
    echo -e "size=+$HOME_PARTITION_SIZE, type=linux" | sfdisk --append "$DRIVE"

    # format
    mkfs.ext4 $ROOT_PARTITION
    mkfs.ext4 $HOME_PARTITION

    mkswap $SWAP_PARTITION
    swapon $SWAP_PARTITION

    if [[ $PARTITIONING_SCHEME = "gpt" ]]; then
        mkfs.fat -F 32 $EFI_SYSTEM_PARTITION
    fi

    # mount
    mount $ROOT_PARTITION /mnt
    mount $HOME_PARTITION /mnt/home

    if [[ $PARTITIONING_SCHEME = "gpt" ]]; then
        mount --mkdir $EFI_SYSTEM_PARTITION /mnt/boot
    fi
}

function stage_1_main_installation {
        local BASE_PACKAGES=(base base-devel linux-lts linux-lts-headers linux linux-headers linux-firmware neovim reflector)

        pacstrap /mnt "${BASE_PACKAGES[@]}"

        genfstab -U /mnt >> /mnt/etc/fstab

        cp arch-installer.sh /mnt/

        arch-chroot /mnt ./arch-installer.sh stage_2
        exit
}

function stage_2_configure_the_system {
    # inside arch-chroot

    sed -i "s/^#ParallelDownloads = 5$/ParallelDownloads = 15/" /etc/pacman.conf
    sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

    pacman -Sy

    reflector --latest 40 --sort rate --save /etc/pacman.d/mirrorlist --protocol https --verbose

    local TIME_ZONE

    TIME_ZONE=$(curl --fail https://ipapi.co/timezone)

    ln -sf /usr/share/zoneinfo/"$TIME_ZONE" /etc/localtime

    hwclock --systohc

    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen

    locale-gen

    echo "LANG=en_US.UTF-8" > /etc/locale.conf

    echo "$HOSTNAME" > /etc/hostname

    {
      echo "127.0.0.1       localhost"
      echo "::1             localhost"
      echo "127.0.1.1       $HOSTNAME.localdomain $HOSTNAME"
    } >> /etc/hosts

    echo "root:$ROOT_PASSWORD" | chpasswd

    pacman --noconfirm -S grub efibootmgr networkmanager network-manager-applet wireless_tools wpa_supplicant os-prober mtools dosfstools

    if [[ $PARTITIONING_SCHEME = "mbr" ]]; then
        grub-install --target=i386-pc "$DRIVE"
    fi

    if [[ $PARTITIONING_SCHEME = "gpt" ]]; then
        grub-install --target=x86_64-efi "$DRIVE" --efi-directory=$EFI_SYSTEM_PARTITION --bootloader-id=GRUB
    fi

    grub-mkconfig -o /boot/grub/grub.cfg

    os-prober

    pacman -S --noconfirm git

    systemctl enable NetworkManager.service

    echo -e "root ALL=(ALL) ALL\n" > /etc/sudoers
    echo -e "%wheel ALL=(ALL) ALL\n" >> /etc/sudoers
    echo -e "@includedir /etc/sudoers.d\n" >> /etc/sudoers

    useradd -m -G wheel "$USERNAME"

    echo "$USERNAME:$USER_PASSWORD" | chpasswd

    if [ "$ONLY_DO_BASE_INSTALLATION" = false ] ; then
        local SCRIPT_PATH=/home/$USERNAME/arch-installer.sh

        cp /arch-installer.sh $SCRIPT_PATH

        chown "$USERNAME":"$USERNAME" $SCRIPT_PATH

        chmod +x $SCRIPT_PATH

        echo "echo \"Run \"$SCRIPT_PATH stage_3\"\"" >> /home/"$USERNAME"/.bash_profile
    fi

    print_info "remove installation medium and reboot!!"
    print_info "after rebooting login as '$USERNAME'."

    exit
}

function stage_3_post_installation {
    sed -i '/arch/d' .bash_profile

    git clone https://github.com/Senpai-10/dotfiles.git .dotfiles

    cd .dotfiles/ || :

    ./bootstrap.sh

    #rm -- "$0"
    rm ~/arch-installer.sh
}

main "$*"
