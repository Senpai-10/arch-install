// https://wiki.archlinux.org/title/Installation_guide

#[macro_use] extern crate prettytable;

#[macro_use]
extern crate log;
extern crate rust_logger;

mod settings;
mod pre_installation;
mod constants;
mod censor_password;
mod helpers;
mod get_settings;

use get_settings::get_settings;
use constants::metadata::{VERSION, AUTHORS, DESCRIPTION, REPOSITORY};
use helpers::{is_root, is_online};
use pre_installation::pre_installation;

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

    pre_installation(settings);
}

