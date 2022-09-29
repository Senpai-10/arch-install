use crate::helpers;
use crate::{helpers::pacman, settings::Settings};
use std::io::{Read, Write};
use std::process::{Command, Stdio};

/**
1. **pre installation**

    Set the console keyboard layout

    Update the system clock

    Partition the disks

        Example layouts

    Format the partitions

    Mount the file systems
*/
pub fn pre_installation(settings: &Settings) {
    const PARALLEL_DOWNLOADS: usize = 15;

    info!("pacman.conf: multilib enabled");
    pacman::config::enable_multilib();

    info!("pacman.conf: ParallelDownloads = {PARALLEL_DOWNLOADS}");
    pacman::config::set_parallel_downloads(PARALLEL_DOWNLOADS);

    info!("Refreshing pacman database!");
    pacman::refresh_database();

    info!("Set the console keyboard layout");
    Command::new("loadkeys").arg(&settings.keymap);

    info!("Update the system clock");
    Command::new("timedatectl").args(["set-ntp", "true"]);

    /*                                              Layouts

                                                UEFI with GPT

                Mount point	    Partition	                Partition type	        Suggested size

        /dev/1  /mnt/boot1	    /dev/efi_system_partition	EFI system partition	At least 300 MiB
        /dev/2  [SWAP]	        /dev/swap_partition	        Linux swap	            More than 512 MiB
        /dev/3  /mnt	        /dev/root_partition	        Linux x86-64 root (/)	Remainder of the device
    -----------------------------------------------------------------------------------------------------------
                                                BIOS with MBR

                Mount point	    Partition	                Partition type	        Suggested size

        /dev/1  [SWAP]	        /dev/swap_partition	        Linux swap	            More than 512 MiB
        /dev/2  /mnt	        /dev/root_partition	        Linux	                Remainder of the device

    */

    let mut fdisk_commmand = String::new();

    // 'o' create a new empty Dos partition table
    if settings.partitioning_scheme == "mbr" {
        fdisk_commmand.push_str("o\n");
    }

    if settings.partitioning_scheme == "gpt" {
        fdisk_commmand.push_str("g\n");
        // create boot partition
        fdisk_commmand.push_str("n\n");
        fdisk_commmand.push_str("\n");
        fdisk_commmand.push_str("\n");
        fdisk_commmand.push_str("+300M\n");
        fdisk_commmand.push_str("t\n");
        fdisk_commmand.push_str("uefi\n");
    }

    if settings.swap_type == "partition" {
        fdisk_commmand.push_str("n\n");
        // primary partition
        if settings.partitioning_scheme == "mbr" {
            fdisk_commmand.push_str("p\n");
        }
        // auto select partition number
        fdisk_commmand.push_str("\n");
        // select first sector
        fdisk_commmand.push_str("\n");

        fdisk_commmand.push_str(&format!("+{}\n", settings.swap_size));

        // change partition type
        fdisk_commmand.push_str("t\n");
        fdisk_commmand.push_str("\n");
        // select linux swap partition type
        fdisk_commmand.push_str("swap\n");
    }

    // create root partition
    fdisk_commmand.push_str("n\n");
    // primary partition
    if settings.partitioning_scheme == "mbr" {
        fdisk_commmand.push_str("p\n");
    }
    fdisk_commmand.push_str("\n");
    fdisk_commmand.push_str("\n");
    fdisk_commmand.push_str("\n");

    // write to disk
    fdisk_commmand.push_str("w");

    info!("Creating partitions..");
    let mut cmd_echo = Command::new("echo")
        .arg(fdisk_commmand)
        .stdout(Stdio::piped())
        .spawn()
        .unwrap();

    let mut cmd_fdisk = Command::new("fdisk")
        .arg(&settings.drive)
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .spawn()
        .unwrap();

    if let Some(ref mut stdout) = cmd_echo.stdout {
        if let Some(ref mut stdin) = cmd_fdisk.stdin {
            let mut buf: Vec<u8> = Vec::new();
            stdout.read_to_end(&mut buf).unwrap();
            stdin.write_all(&buf).unwrap();
        }
    }
    println!(
        "output: {}",
        helpers::convert_vector_of_bytes_to_string(cmd_fdisk.wait_with_output().unwrap().stdout)
    );

    let mut root_partition = settings.drive.clone();
    let mut efi_system_partition = settings.drive.clone();
    let mut swap_partition = settings.drive.clone();

    if settings.partitioning_scheme == "gpt" && settings.swap_type == "partition" {
        efi_system_partition.push('1');
        swap_partition.push('2');
        root_partition.push('3');
    }

    if settings.partitioning_scheme == "gpt" && settings.swap_type == "file" {
        efi_system_partition.push('1');
        root_partition.push('2');
    }

    if settings.partitioning_scheme == "mbr" && settings.swap_type == "partition" {
        swap_partition.push('1');
        root_partition.push('2');
    }

    if settings.partitioning_scheme == "mbr" && settings.swap_type == "file" {
        root_partition.push('1');
    }

    Command::new("mkfs.ext4")
        .arg(&root_partition)
        .status()
        .unwrap();

    if settings.swap_type == "partition" {
        info!("mkswap {swap_partition}");
        Command::new("mkswap")
            .arg(&swap_partition)
            .status()
            .unwrap();

        info!("swapon {swap_partition}");
        Command::new("swapon")
            .arg(&swap_partition)
            .status()
            .unwrap();
    }

    if settings.partitioning_scheme == "gpt" {
        info!("formating the efi system partition");
        Command::new("mkfs.fat")
            .arg("-F")
            .arg("32")
            .arg(&efi_system_partition)
            .status()
            .unwrap();
    }

    info!("Mount the file systems");
    Command::new("mount")
        .arg(&root_partition)
        .arg("/mnt")
        .status()
        .unwrap();

    if settings.partitioning_scheme == "gpt" {
        info!("mounting efi system partition");
        Command::new("mount")
            .arg("--mkdir")
            .arg(&efi_system_partition)
            .arg("/mnt/boot")
            .status()
            .unwrap();
    }
}
