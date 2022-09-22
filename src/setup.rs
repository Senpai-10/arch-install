use crate::helpers::pacman;
use std::process::{Command, ExitStatus};

/// Setup installation
pub fn setup() {
    info!("Selecting the fastest mirrors");
    if !update_mirrorlist().success() {
        error!("Failed to update mirrorlist");
    }

    info!("Refreshing pacman database!");
    pacman::refresh_database();

    // pacman::install("archlinux-keyring");
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