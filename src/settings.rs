pub struct Settings {
    pub hostname: String,
    pub root_password: String,
    pub username:  String,
    pub user_password:  String,
    pub timezone: String,
    pub keymap: String,

    pub partitioning_scheme: String,
    pub drive: String,
    
    // user apps
    pub files_manager: String,
}

impl Settings {
    pub fn new() -> Self {
        Settings {
            hostname: String::from(""),
            root_password: String::from(""),
            username: String::from(""),
            user_password: String::from(""),
            timezone: String::from("Asia/Riyadh"),
            keymap: String::from("us"),

            /*
                options:
                    1. mbr
                    2. gpt
            */
            partitioning_scheme: String::from("mbr"),

            // Main installation drive name
            // Example: sda without '/dev/'
            drive: String::from(""),

            files_manager: String::from("nemo"),
        }
    }
}