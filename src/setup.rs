use crate::settings;
use dialoguer::theme::ColorfulTheme;
use crate::timezones::TIMEZONES;

pub fn get_settings() -> settings::Settings {
    let default_theme = ColorfulTheme::default();

    let hostname: String = dialoguer::Input::with_theme(&default_theme)
        .with_prompt("hostname")
        .interact().unwrap();

    let root_password: String = dialoguer::Password::with_theme(&default_theme)
        .with_prompt("root password")
        .with_confirmation("Confirm password", "Passwords mismatching")
        .interact().unwrap();

    let username: String = dialoguer::Input::with_theme(&default_theme)
        .with_prompt("username")
        .interact().unwrap();

    let user_password: String = dialoguer::Password::with_theme(&default_theme)
        .with_prompt("user password")
        .with_confirmation("Confirm password", "Passwords mismatching")
        .interact().unwrap();

    let timezone_index = dialoguer::FuzzySelect::with_theme(&default_theme).with_prompt("Select timezone").default(0).items(&TIMEZONES).interact().unwrap();

    settings::Settings {
        hostname: hostname.trim().to_owned(),
        root_password: root_password.trim().to_owned(),
        username: username.trim().to_owned(),
        user_password: user_password.trim().to_owned(),
        timezone: TIMEZONES[timezone_index].to_owned(),
        keymap: String::from("us"),
        partition_table_format: String::from("mbr"),
        drive: String::from("/dev/sda"),

        files_manager: String::from("nemo"),
    }
}

