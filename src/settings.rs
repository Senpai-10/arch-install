use crate::censor_password::censor_password;

use prettytable::Table;
use prettytable::format;

pub struct Settings {
    pub hostname: String,
    pub root_password: String,
    pub username:  String,
    pub user_password:  String,
    pub timezone: String,
    pub keymap: String,

    pub partitioning_scheme: String,
    pub drive: String,
    pub swap_type: String,
    /// <N>GB
    /// 4GB
    pub swap_size: String,
    
    // user apps
    pub files_manager: String,
}

impl Settings {
    pub fn print_all(&self) -> () {
        let format = *format::consts::FORMAT_BOX_CHARS;

        let mut system_table = Table::new();
        let mut user_table = Table::new();

        system_table.set_format(format);
        user_table.set_format(format);

        system_table.set_titles(row!["Setting", "Value"]);
        
        system_table.add_row(row!["hostname", self.hostname]);
        system_table.add_row(row!["root password", censor_password(&self.root_password)]);
        system_table.add_row(row!["username", self.username]);
        system_table.add_row(row!["user password", censor_password(&self.user_password)]);
        system_table.add_row(row!["timezone", self.timezone]);
        system_table.add_row(row!["keymap", self.keymap]);
        system_table.add_row(row!["partitioning scheme", self.partitioning_scheme]);
        system_table.add_row(row!["drive", self.drive]);
        system_table.add_row(row!["swap_type", self.swap_type]);
        system_table.add_row(row!["swap_size", self.swap_size]);

        user_table.set_titles(row!["Setting", "Value"]);

        user_table.add_row(row!["files manager", self.files_manager]);

        println!("All settings");
        println!();
        println!("System install settings");
        println!();
        
        system_table.printstd();

        println!();
        println!("User install settings");
        println!();
        
        user_table.printstd();
    
    }
}