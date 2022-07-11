use crate::enums::filesmanges::FilesManages;

pub struct Config {
    pub files_manager: FilesManages
}

impl Config {
    pub fn get() -> Self {
        Config {
            files_manager: FilesManages::Nemo
        }
    }
}