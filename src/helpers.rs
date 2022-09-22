pub fn is_root() -> bool {
    let command = std::process::Command::new("id")
        .arg("-u")
        .output()
        .expect("failed to execute `id -u`");

    let output = convert_vector_of_bytes_to_string(command.stdout).parse::<i32>().unwrap();

    output == 0
}

pub mod pacman {
    use std::process::{Command, ExitStatus};

    /// execute `pacman -Sy`
    pub fn refresh_database() -> ExitStatus {
        let status = Command::new("pacman")
            .args(["-Sy"])
            .status().expect("failed to refresh database");

        status
    }

    pub fn install(package: &str) -> ExitStatus {
        let status = Command::new("pacman")
            .args(["--noconfirm", "-S", package]).status().expect("failed to install package");
    
        status
    }
}

fn convert_vector_of_bytes_to_string(bytes: Vec<u8>) -> String {
    let mut s = String::from_utf8(bytes).unwrap();

    if s.ends_with('\n') {
        s.pop();
        if s.ends_with('\r') {
            s.pop();
        }
    }

    s
}
