/// get string and return the same length but as stars '*'
pub fn censor_password(string: &str) -> String {
    let length = string.len();

    return "*".repeat(length)
}