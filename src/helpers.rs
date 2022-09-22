pub fn is_root() -> bool {
    let command = std::process::Command::new("id")
        .arg("-u")
        .output()
        .expect("failed to execute `id -u`");

    let output = convert_vector_of_bytes_to_string(command.stdout).parse::<i32>().unwrap();

    output == 0
}

pub fn is_online() -> bool {
    let status = std::process::Command::new("sh")
        .arg("-c")
        .arg("ping -c1 8.8.8.8 &>/dev/null")
        .status()
        .expect("failed to execute `ping` command");

    status.success()
}

pub mod pacman {
    use std::process::{Command, ExitStatus};

    /// Execute `pacman -Sy`
    pub fn refresh_database() -> ExitStatus {
        let status = Command::new("pacman")
            .args(["-Sy"])
            .status().expect("failed to refresh database");

        status
    }

    /// Execute `pacman --noconfirm -S {package}`
    pub fn install(packages: Vec<&str>) -> ExitStatus {
        let status = Command::new("pacman")
            .arg("--noconfirm")
            .arg("-S")
            .args(packages)
            .status().expect("failed to install package");
    
        status
    }

    /// pacman config
    /// 
    /// Uncomment `ParallelDownloads`, and change number 
    /// 
    /// file: `/etc/pacman.conf`
    pub fn set_parallel_downloads(n: usize) {
        // put the number in the regex
        let sed_regex = format!("s/^#ParallelDownloads = 5$/ParallelDownloads = {}/", n);

        Command::new("sed")
        .args([
            "-i", 
            &sed_regex,
            "/etc/pacman.conf"])
        .status().unwrap();

        info!("pacman.conf: ParallelDownloads is set to '{}'", n);
    }

    /// pacman config
    /// 
    /// Uncomment [multilib], and 'Include' line
    /// 
    /// file: `/etc/pacman.conf`
    pub fn enable_multilib() {
        Command::new("sed")
        .args([
            "-i", 
            "\"/\\[multilib\\]/,/Include/\"'s/^#//'",
            "/etc/pacman.conf"])
        .status().unwrap();

        info!("pacman.conf: multilib enabled");
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
