mod settings;
mod setup;
mod constants;

use setup::get_settings;

fn main() {
    let settings: settings::Settings = get_settings();

    println!("hostname '{}'", settings.hostname);
    println!("username '{}'", settings.username);
    println!("timezone '{}'", settings.timezone);
}
