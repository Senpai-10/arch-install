use crate::settings::Settings;
use std::process::{Command, ExitStatus};
// https://github.com/archlinux/archinstall/blob/c9e1d4a8c3435401220c1108ac938971ad517a37/archinstall/lib/installer.py#L430
//
// how to arch-chroot

/**
**2 Installation**

Select the mirrors

Install essential packages
*/
pub fn main_installation() {
    info!("Selecting the fastest mirrors");
    if !update_mirrorlist(20).success() {
        error!("Failed to update mirrorlist");
    }

    let packages = vec![
        // install_essential_packages
        "base",
        "base-devel",
        "linux-lts",
        "linux-lts-headers",
        "linux",
        "linux-headers",
        "linux-firmware",
        "neovim",
        // user packages
    ];

    Command::new("pacstrap")
        .arg("/mnt")
        .args(packages)
        .status()
        .unwrap();
}

fn update_mirrorlist(latest: usize) -> ExitStatus {
    let status = Command::new("reflector")
        .args([
            "--latest",
            &latest.to_string(),
            "--sort",
            "rate",
            "--save",
            "/etc/pacman.d/mirrorlist",
            "--protocol",
            "https",
            "--verbose",
        ])
        .status()
        .unwrap();

    status
}
