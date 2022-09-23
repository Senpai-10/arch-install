use crate::helpers;
use crate::{helpers::pacman, settings::Settings};
use std::process::{Command, ExitStatus, Stdio};
use std::io::{Read, Write};

/**
1. **pre installation**
 
    Set the console keyboard layout

    Update the system clock
 
    Partition the disks
 
        Example layouts
 
    Format the partitions
 
    Mount the file systems
*/
pub fn pre_installation(settings: Settings) {
    // info!("Selecting the fastest mirrors");
    // if !update_mirrorlist().success() {
    //     error!("Failed to update mirrorlist");
    // }

    pacman::enable_multilib();
    pacman::set_parallel_downloads(15);

    info!("Refreshing pacman database!");
    pacman::refresh_database();

    info!("Set the console keyboard layout");
    Command::new("loadkeys")
        .arg(settings.keymap);

    info!("Update the system clock");
    Command::new("timedatectl")
        .args(["set-ntp", "true"]);
    

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
    println!("output: {}", helpers::convert_vector_of_bytes_to_string(cmd_fdisk.wait_with_output().unwrap().stdout));

    let mut root_partition = settings.drive.clone();
    let mut boot_partition = settings.drive.clone();
    let mut swap_partition = settings.drive.clone();


    if settings.partitioning_scheme == "gpt" && settings.swap_type == "partition" {
        boot_partition.push('1');
        swap_partition.push('2');
        root_partition.push('3');
    } 
    
    if settings.partitioning_scheme == "gpt" && settings.swap_type == "file" {
        boot_partition.push('1');
        root_partition.push('2');
    }

    if settings.partitioning_scheme == "mbr" && settings.swap_type == "partition" {
        swap_partition.push('1');
        root_partition.push('2');
    }

    if settings.partitioning_scheme == "mbr" && settings.swap_type == "file" {
        root_partition.push('1');
    }

}

fn update_mirrorlist() -> ExitStatus {
    // reflector --latest 100 --sort rate --save /etc/pacman.d/mirrorlist --protocol https
    let status = Command::new("reflector")
        .args(["--latest", "100",
                "--sort", "rate",
                "--save", "/etc/pacman.d/mirrorlist", 
                "--protocol", "https",
                "--verbose"])
        .status().unwrap();
    
    status
}
