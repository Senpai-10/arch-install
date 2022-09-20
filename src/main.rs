#[macro_use] extern crate prettytable;

mod settings;
mod setup;
mod constants;
mod censor_password;

use setup::get_settings;

use dialoguer::Confirm;
use dialoguer::theme::ColorfulTheme;

fn main() {
    let theme = ColorfulTheme::default();
    let mut settings: settings::Settings;

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

    println!("after: gs{}", settings.hostname);
}
