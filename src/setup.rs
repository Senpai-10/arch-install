use crate::helpers::pacman;
use std::process::{Command, ExitStatus};
use colored::{self, Colorize};

/// Setup installation
pub fn setup() {
    println!(
        "{}",
        "Selecting the fastest mirrors".bright_green()
    );
    
    if !update_mirrorlist().success() {
        println!("{}", "Failed to update mirrorlist".bright_red());
    }

    println!("refreshing pacman database!");
    pacman::refresh_database();

    // pacman::install("archlinux-keyring");
}

fn update_mirrorlist() -> ExitStatus {
    // reflector --latest 100 --sort rate --save /etc/pacman.d/mirrorlist --protocol https
    let status = Command::new("reflector")
        .args(["--latest", "100",
                "--sort", "rate",
                "--save", "/etc/pacman.d/mirrorlist", 
                "--protocol", "https"])
        .status().unwrap();
    
    status
}