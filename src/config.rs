/*
    Only edit 'Config {}' inside of get function
*/

use crate::enums::*;

pub struct Config {
    pub hostname: String,
    pub root_password: String,
    pub username:  String,
    pub user_password:  String,
    pub timezone: String,
    pub keymap: String,

    pub partitioning: Partitioning,
    pub main_drive: String,
    
    // user apps
    pub files_manager: FilesManages,
}

impl Config {
    pub fn get() -> Self {
        Config {
            hostname: String::from(""),
            root_password: String::from(""),
            username:  String::from(""),
            user_password: String::from(""),
            timezone: String::from("Asia/Riyadh"),
            keymap: String::from("us"),
            partitioning: Partitioning::Mbr,
            // Main installation drive name
            // Example: sda without '/dev/'
            main_drive: String::from(""),

            files_manager: FilesManages::Nemo,
        }
    }
}