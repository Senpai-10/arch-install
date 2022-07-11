mod config;
mod enums;

use config::Config;

fn main() {
    println!("config: {}", Config::get().files_manager.as_str());
}
