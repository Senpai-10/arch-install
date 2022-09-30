use crate::settings::Settings;
use std::process::{Command, Stdio};
use execute::{Execute, shell};
use std::fs::File;

// https://github.com/archlinux/archinstall/blob/c9e1d4a8c3435401220c1108ac938971ad517a37/archinstall/lib/installer.py#L430
//
// how to arch-chroot


pub fn configure_the_system(settings: &Settings) {
    // genfstab -U /mnt >> /mnt/etc/fstab

    let fstab_file = File::create("/mnt/etc/fstab").unwrap();
    let fstab_stdio = Stdio::from(fstab_file);

    Command::new("genfstab")
        .arg("-U")
        .arg("/mnt")
        .stdout(fstab_stdio)
        .status()
        .unwrap();

    Command::new("arch-chroot")
        .arg("/mnt")
        .arg(&format!("ln -sf /usr/share/zoneinfo/{} /etc/localtime", &settings.timezone))
        .status()
        .unwrap();
}
