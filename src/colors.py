reset = "\u001b[0m"

def black(string):
    return f"\u001b[30m{string}{reset}"

def red(string):
    return f"\u001b[31m{string}{reset}"

def green(string):
    return f"\u001b[32m{string}{reset}"

def yellow(string):
    return f"\u001b[33m{string}{reset}"

def blue(string):
    return f"\u001b[34m{string}{reset}"

def magenta(string):
    return f"\u001b[35m{string}{reset}"

def cyan(string):
    return f"\u001b[36m{string}{reset}"

def white(string):
    return f"\u001b[37m{string}{reset}"

# Bright

def bright_black(string):
    return f"\u001b[30;1m{string}{reset}"

def bright_red(string):
    return f"\u001b[31;1m{string}{reset}"

def bright_green(string):
    return f"\u001b[32;1m{string}{reset}"

def bright_yellow(string):
    return f"\u001b[33;1m{string}{reset}"

def bright_blue(string):
    return f"\u001b[34;1m{string}{reset}"

def bright_magenta(string):
    return f"\u001b[35;1m{string}{reset}"

def bright_cyan(string):
    return f"\u001b[36;1m{string}{reset}"

def bright_white(string):
    return f"\u001b[37;1m{string}{reset}"

# Background colors

def bg_black(string):
    return f"\u001b[40m{string}{reset}"

def bg_red(string):
    return f"\u001b[41m{string}{reset}"

def bg_green(string):
    return f"\u001b[42m{string}{reset}"

def bg_yellow(string):
    return f"\u001b[43m{string}{reset}"

def bg_blue(string):
    return f"\u001b[44m{string}{reset}"

def bg_magenta(string):
    return f"\u001b[45m{string}{reset}"

def bg_cyan(string):
    return f"\u001b[46m{string}{reset}"

def bg_white(string):
    return f"\u001b[47m{string}{reset}"

# Background bright colors

def bg_bright_black(string):
    return f"\u001b[40;1m{string}{reset}"

def bg_bright_red(string):
    return f"\u001b[41;1m{string}{reset}"

def bg_bright_green(string):
    return f"\u001b[42;1m{string}{reset}"

def bg_bright_yellow(string):
    return f"\u001b[43;1m{string}{reset}"

def bg_bright_blue(string):
    return f"\u001b[44;1m{string}{reset}"

def bg_bright_magenta(string):
    return f"\u001b[45;1m{string}{reset}"

def bg_bright_cyan(string):
    return f"\u001b[46;1m{string}{reset}"

def bg_bright_white(string):
    return f"\u001b[47;1m{string}{reset}"