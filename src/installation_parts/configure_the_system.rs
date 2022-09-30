use crate::settings::Settings;
use std::process::{Command};

pub fn configure_the_system(settings: &Settings) {
    // genfstab -U /mnt >> /mnt/etc/fstab
    Command::new("genfstab")
        .arg("-U")
        .arg("/mnt")
        .arg(">>")
        .arg("/mnt/etc/fstab")
        .status()
        .unwrap();
}
