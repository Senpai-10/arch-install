use crate::{helpers::pacman, settings::Settings};
use std::process::{Command, ExitStatus};

/// Setup installation
pub fn setup(settings: Settings) {
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
