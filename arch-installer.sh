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

function run {
    check_missing_configs

    check_internet_connection

    print_banner

    echo -e "source: ${BIYellow}https://github.com/senpai-10/arch-install${NO_COLOR}"
    echo -e "Version: ${BIYellow}${VERSION}${NO_COLOR}"

    print_debug EFI_SYSTEM_PARTITION: $EFI_SYSTEM_PARTITION
    print_debug SWAP_PARTITION: $SWAP_PARTITION
    print_debug ROOT_PARTITION: $ROOT_PARTITION

    # stop executing the script and wait for any key press
    # in case the script was ran by accident
    read -rsn1 -p"Press any key to continue " variable;echo

    pre_installation
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

run
