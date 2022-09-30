// https://wiki.archlinux.org/title/Installation_guide
// Download link: https://senpai-10.github.io/arch-install/arch-installer-testing

#[macro_use]
extern crate prettytable;

#[macro_use]
extern crate log;
extern crate rust_logger;

mod censor_password;
mod constants;
mod get_settings;
mod helpers;
mod installation_parts;
mod settings;

use constants::metadata::{AUTHORS, DESCRIPTION, REPOSITORY, VERSION};
use get_settings::get_settings;
use helpers::{is_online, is_root};
use installation_parts::pre_installation::pre_installation;
use installation_parts::installation::main_installation;
use installation_parts::configure_the_system::configure_the_system;

use clap::Parser;
use colored::{self, Colorize};
use dialoguer::theme::ColorfulTheme;
use dialoguer::Confirm;
use std::process::exit;

/// Simple Arch installer
#[derive(Parser, Debug)]
#[clap(author, version, about, long_about = None)]
pub struct Cli {
    #[clap(flatten)]
    pub verbose: clap_verbosity_flag::Verbosity,
}
fn main() {
    let cli = Cli::parse();
    let mut logger = rust_logger::builder();

    logger.filter_level(cli.verbose.log_level_filter());
    logger.init();

    let theme = ColorfulTheme::default();
    let mut settings: settings::Settings;

    println!(
        "{}",
        r"
                 _           _           _        _ _
   __ _ _ __ ___| |__       (_)_ __  ___| |_ __ _| | | ___ _ __
  / _` | '__/ __| '_ \ _____| | '_ \/ __| __/ _` | | |/ _ \ '__|
 | (_| | | | (__| | | |_____| | | | \__ \ || (_| | | |  __/ |
  \__,_|_|  \___|_| |_|     |_|_| |_|___/\__\__,_|_|_|\___|_|
"
        .bright_green()
    );

    println!("Autors: {}", AUTHORS.bright_black());
    println!("Description: {}", DESCRIPTION.bright_black());
    println!("Repository: {}", REPOSITORY.bright_black());
    println!("Version: {}", VERSION.bright_black());

    println!();

    if is_root() == false {
        error!("This script require root permissions :(");
        exit(1);
    }

    // Internet connection is needed for installing packages and more stuff!
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
            .interact()
            .unwrap();

        if continue_script {
            break;
        }
    }

    info!("Pre installation");
    pre_installation(&settings);

    info!("Main installation");
    main_installation();

    info!("Configure the system");
    configure_the_system(&settings);
}
