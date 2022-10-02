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

function fn_main {
    fn_check_missing_configs

    fn_check_internet_connection

    fn_print_banner

    echo -e "source: ${BIYellow}https://github.com/senpai-10/arch-install${NO_COLOR}"
    echo -e "Version: ${BIYellow}${VERSION}${NO_COLOR}"

    fn_print_debug EFI_SYSTEM_PARTITION: $EFI_SYSTEM_PARTITION
    fn_print_debug SWAP_PARTITION: $SWAP_PARTITION
    fn_print_debug ROOT_PARTITION: $ROOT_PARTITION

    if [[ $1 = "--run-arch-chroot" ]]; then
        fn_configure_the_system
        fn_configure_the_system
    elif [[ $1 = "--run-post-installation" ]]; then
        fn_post_installation
    else
        # stop executing the script and wait for any key press
        # in case the script was ran by accident
        read -rsn1 -p"Press any key to continue " variable;echo

        fn_pre_installation
        fn_main_installation
    fi
}

function fn_print_banner {
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

function fn_print_info {
    echo -e "[${IBlue}INFO${NO_COLOR}] ${IYellow}$@${NO_COLOR}"
}

function fn_print_error {
    echo -e "[${IRed}ERROR${NO_COLOR}] ${IYellow}$@${NO_COLOR}"
}

function fn_print_warning {
    echo -e "[${IYellow}WARNING${NO_COLOR}] ${IYellow}$@${NO_COLOR}"
}

function fn_print_debug {
    echo -e "[${IGreen}DEBUG${NO_COLOR}] ${IYellow}$@${NO_COLOR}"
}

function fn_check_missing_configs {
    if [[ -z $HOSTNAME || -z $ROOT_PASSWORD || -z $USERNAME || -z $USER_PASSWORD ]]; then
        fn_print_error "Missing some configs!\n\tedit arch-installer.sh and set the config!"
        exit 1
    fi
}
function fn_check_internet_connection {
    fn_print_info "Checking internet connection..."

    ping -c1 "8.8.8.8" &>"/dev/null"

    if [[ "${?}" -ne 0 ]]; then
        fn_print_error "No internect connection. Exiting now!"
        exit 1
    elif [[ "${#args[@]}" -eq 0 ]]; then
        fn_print_info "internet connection found!"
    fi
}

function fn_pre_installation {
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

function fn_main_installation {
        reflector --latest 20 --sort rate --save /etc/pacman.d/mirrorlist --protocol https --verbose

        local BASE_PACKAGES="base base-devel linux-lts linux-lts-headers linux linux-headers linux-firmware neovim"

        pacstrap /mnt $BASE_PACKAGES

        genfstab -U /mnt >> /mnt/etc/fstab

        cp arch-installer.sh /mnt/

        arch-chroot /mnt ./arch-installer.sh --run-arch-chroot
        exit
}

function fn_configure_the_system {
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

    systemctl enable NetworkManager.service

    echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

    useradd -m -G wheel $USERNAME

    echo "$USERNAME:$USER_PASSWORD" | chpasswd

    local SCRIPT_PATH=/home/$USERNAME/arch-installer.sh

    cp /arch-installer.sh $SCRIPT_PATH

    chown $USERNAME:$USERNAME $SCRIPT_PATH

    chmod +x $SCRIPT_PATH

    echo "source $SCRIPT_PATH --run-post-installation" >> /home/$USERNAME/.bash_profile

    fn_print_info "REMOVE INSTALLATION MEDIUM!!"
    fn_print_info "after rebooting login as '$USERNAME'."

    secs=$((5))

    while [ $secs -gt 0 ]; do
        echo -ne "REBOOTING in ${IRed}$secs${NO_COLOR}\033[0K\r"
        sleep 1
        : $((secs--))
    done

    exit
    reboot
}

function fn_post_installation {
    echo "hi post installation"
}

fn_main $1
