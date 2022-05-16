from menu import Menu

def main():
    print("===================[ Archlinux Installer ]===================")
    print("=    Author: senpai-10 <bmjfdrh@gmail.com>            =")
    print("=    GitHub profile: https://github.com/senpai-10     =")
    print("============================================================\n")
    
    main_menu = Menu(["choice 1", "choice 2", "choice 3"]).choice
    print(f"choice: {main_menu}")
    
    if main_menu == "choice 1":
        print("hi")

if __name__ == '__main__':
    main()