#[macro_use] extern crate prettytable;

mod settings;
mod setup;
mod constants;
mod censor_password;

use setup::get_settings;
use constants::metadata::{VERSION, AUTHORS, DESCRIPTION, REPOSITORY};

use dialoguer::Confirm;
use dialoguer::theme::ColorfulTheme;
use colored::{self, Colorize};

fn main() {
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
}
