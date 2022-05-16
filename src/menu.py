from colors import bright_green

class Menu:
    """
    usage:
        let main_menu = Menu(["choice 1", "choice 2", "choice 3"])
        
        print(f"choice: {main_menu.choice}")
    """
    
    def __init__(self, menu):
        self.__menu = menu
        self.choice = ""
        self.__display()
    
    def __display(self):
        for i in range(len(self.__menu)):
            print(f"[{bright_green(i+1)}] {self.__menu[i]}")
        
        choice = int(input("\nchoice: "))
        
        if choice > len(self.__menu) or choice < 0:
            print("Index is out of bounds!")
            exit(1)
        
        if choice < 1:
            self.choice = self.__menu[choice]
        else: self.choice = self.__menu[choice-1]