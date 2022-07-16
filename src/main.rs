mod config;
mod enums;

use config::Config;

fn main() {
    println!("config: {}", Config::get().partitioning.as_str());
}
