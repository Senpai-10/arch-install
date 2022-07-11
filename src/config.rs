use crate::enums::*;

pub struct Config {
    pub files_manager: FilesManages,
    pub partitioning: Partitioning
}

impl Config {
    pub fn get() -> Self {
        Config {
            files_manager: FilesManages::Nemo,
            partitioning: Partitioning::Mbr
        }
    }
}