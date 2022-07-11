#[allow(dead_code)]
pub enum FilesManages {
    Nemo,
    Pcmanfm
}

impl FilesManages {
    pub fn as_str(&self) -> &'static str {
        match self {
            FilesManages::Nemo => "nemo",
            FilesManages::Pcmanfm => "pcmanfm"
        }
    }
}
