use crate::constants::{TIMEZONES, PARTITIONING_SCHEMES, SWAP_TYPES};
use crate::settings::Settings;

use std::process::Command;

pub fn get_settings<'a>(theme: &'a dyn dialoguer::theme::Theme) -> Settings {

    let hostname: String = dialoguer::Input::with_theme(theme)
        .with_prompt("hostname")
        .interact().unwrap();

    let root_password: String = dialoguer::Password::with_theme(theme)
        .with_prompt("root password")
        .with_confirmation("Confirm password", "Passwords mismatching")
        .interact().unwrap();

    let username: String = dialoguer::Input::with_theme(theme)
        .with_prompt("username")
        .interact().unwrap();

    let user_password: String = dialoguer::Password::with_theme(theme)
        .with_prompt("user password")
        .with_confirmation("Confirm password", "Passwords mismatching")
        .interact().unwrap();

    let timezone_index = dialoguer::FuzzySelect::with_theme(theme)
        .with_prompt("Select timezone")
        .default(0)
        .items(&TIMEZONES)
        .interact().unwrap();

    let partitioning_schemes_index = dialoguer::FuzzySelect::with_theme(theme)
        .with_prompt("Select partitioning scheme")
        .default(0)
        .items(&PARTITIONING_SCHEMES)
        .interact().unwrap();

    let lsblk_command = Command::new("lsblk")
        .output()
        .expect("lsblk command failed to start");

    println!("{}", String::from_utf8_lossy(&lsblk_command.stdout));

    let drive: String = dialoguer::Input::with_theme(theme)
        .with_prompt("enter installation drive (example: /dev/sda)")
        .interact().unwrap();


    /*
        TODO

        ask "do you want root and home seperate"

            if root and home seperate
                ask for root size, and home size in GB
            if not seperate
                ask for root size

                Note: check for drive capacity

        ask "do you want a swap file or partition"

            in both cases ask for size
    */


    let swap_type_index = dialoguer::FuzzySelect::with_theme(theme)
        .with_prompt("Select swap type")
        .default(0)
        .items(SWAP_TYPES)
        .interact().unwrap();

    let swap_size: String = dialoguer::Input::with_theme(theme)
        .with_prompt("swap partition/file (size{K,M,G,T,P})")
        .interact().unwrap();

    Settings {
        // system
        hostname: hostname.trim().to_owned(),
        root_password: root_password.trim().to_owned(),
        username: username.trim().to_owned(),
        user_password: user_password.trim().to_owned(),
        timezone: TIMEZONES[timezone_index].to_owned(),
        keymap: String::from("us"),
        partitioning_scheme: PARTITIONING_SCHEMES[partitioning_schemes_index].to_owned(),
        drive: drive.trim().to_owned(),
        swap_type: SWAP_TYPES[swap_type_index].to_owned(),
        swap_size: swap_size.trim().to_owned(),

        // user packages
        files_manager: String::from("nemo"),
    }
}
