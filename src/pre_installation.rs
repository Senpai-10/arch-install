use crate::{helpers::pacman, settings::Settings};
use std::process::{Command, ExitStatus};

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
    info!("Selecting the fastest mirrors");
    if !update_mirrorlist().success() {
        error!("Failed to update mirrorlist");
    }

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
    
    let mut fdisk_commmand = String::new();
    
    // 'o' create a new empty Dos partition table
    if settings.partitioning_scheme == "mbr" {
        fdisk_commmand.push_str("o\n");
    }

    if settings.partitioning_scheme == "gpt" {
        fdisk_commmand.push_str("g\n");
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
