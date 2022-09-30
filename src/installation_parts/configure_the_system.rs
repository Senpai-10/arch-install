use crate::settings::Settings;
use std::process::{Command, Stdio};
use execute::{Execute, shell};
use std::fs::File;

pub fn configure_the_system(settings: &Settings) {
    // genfstab -U /mnt >> /mnt/etc/fstab

    let file = File::create("/mnt/etc/fstab").unwrap();
    let stdio = Stdio::from(file);

    Command::new("genfstab")
        .arg("-U")
        .arg("/mnt")
        .stdout(stdio)
        .status()
        .unwrap();
}
