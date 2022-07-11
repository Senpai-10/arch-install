#[allow(dead_code)]
pub enum Partitioning {
    Mbr,
    Gpt
}

impl Partitioning {
    pub fn as_str(&self) -> &'static str {
        match self {
            Partitioning::Mbr => "mbr",
            Partitioning::Gpt => "gpt"
        }
    }
}
