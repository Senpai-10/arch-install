class Menu:
    """
    usage:
        let main_menu = Menu(["choice 1", "choice 2", "choice 3"])
        
        print(f"choice: {main_menu.choice}")
    """
    
    def __init__(self, menu):
        self.menu = menu
        self.choice = ""
        self._display()
    
    def _display(self):
        for i in range(len(self.menu)):
            print(f"{i+1}. {self.menu[i]}")
        
        choice = int(input("index: "))
        
        if choice > len(self.menu) or choice < 0:
            print("Index is out of bounds!")
            exit(1)
        
        if choice < 1:
            self.choice = self.menu[choice]
        else: self.choice = self.menu[choice-1]