if [[ $1 = "--gen-conf" ]]; then
    echo "
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

    " > arch-installer.conf
fi

if [[ ! -z arch-installer.conf ]]; then
    cat ./arch-installer.conf >> test-ai.sh
    echo -e "fn_main \$1" >> test-ai.sh
fi


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
# example: my-desktop
HOSTNAME=mars

# your username
USERNAME=senpai

# your user password
USER_PASSWORD=12305

# root user password
ROOT_PASSWORD=12305

KEYMAP=us

# drive partitioning table scheme
# Values:
#       gpt
#       mbr
# if you are using an old computer select mbr
PARTITIONING_SCHEME=mbr

# System installation drive
# use lsblk command to know what drive to use
# be carefull your drive will be formatted and you will lose all data
# example: /dev/sda
DRIVE=/dev/vda

# select if you want a swap file or a swap partition
# Values:
#       file
#       partition
SWAP_TYPE=partition

# The size of your swap partition/file
# Values:
#       {size{G,M}}
# example: 8G
# this example will create a 8 gigabytes swap partition/file
SWAP_SIZE=8G

#########################


fn_main $1
