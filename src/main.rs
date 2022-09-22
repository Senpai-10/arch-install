// https://wiki.archlinux.org/title/Installation_guide

#[macro_use] extern crate prettytable;

#[macro_use]
extern crate log;
extern crate rust_logger;

mod settings;
mod setup;
mod constants;
mod censor_password;
mod helpers;

use constants::{TIMEZONES, PARTITIONING_SCHEMES};
use constants::metadata::{VERSION, AUTHORS, DESCRIPTION, REPOSITORY};
use helpers::{is_root, is_online};
use std::process::Command;
use setup::setup;

use std::process::exit;
use dialoguer::Confirm;
use dialoguer::theme::ColorfulTheme;
use colored::{self, Colorize};

fn main() {
    rust_logger::init();

    let theme = ColorfulTheme::default();
    let mut settings: settings::Settings;

    println!("{}", r"
                 _           _           _        _ _           
   __ _ _ __ ___| |__       (_)_ __  ___| |_ __ _| | | ___ _ __ 
  / _` | '__/ __| '_ \ _____| | '_ \/ __| __/ _` | | |/ _ \ '__|
 | (_| | | | (__| | | |_____| | | | \__ \ || (_| | | |  __/ |   
  \__,_|_|  \___|_| |_|     |_|_| |_|___/\__\__,_|_|_|\___|_|
".bright_green());

    println!("Autors: {}", AUTHORS.bright_black());
    println!("Description: {}", DESCRIPTION.bright_black());
    println!("Repository: {}", REPOSITORY.bright_black());
    println!("Version: {}", VERSION.bright_black());

    println!();

    if is_root() == false {
        error!("This script require root permissions :(");
        exit(1);
    }

    info!("Checking internet connection");
    if is_online() == false {
        error!("Not connected to the internet.");
        exit(1);
    }
    
    loop {
        settings = get_settings(&theme);

        settings.print_all();

        let continue_script = Confirm::with_theme(&theme)
            .with_prompt("Do you want to continue")
            .default(true)
            .show_default(true)
            .interact().unwrap();

        if continue_script {
            break;
        }
    }

    setup(settings);
}

pub fn get_settings<'a>(theme: &'a dyn dialoguer::theme::Theme) -> settings::Settings {

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

    settings::Settings {
        // system
        hostname: hostname.trim().to_owned(),
        root_password: root_password.trim().to_owned(),
        username: username.trim().to_owned(),
        user_password: user_password.trim().to_owned(),
        timezone: TIMEZONES[timezone_index].to_owned(),
        keymap: String::from("us"),
        partitioning_scheme: PARTITIONING_SCHEMES[partitioning_schemes_index].to_owned(),
        drive: drive.trim().to_owned(),

        // user packages
        files_manager: String::from("nemo"),
    }
}
