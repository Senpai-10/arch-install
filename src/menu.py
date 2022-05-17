from ctypes import cast
from colors import bright_green, bright_yellow

class Menu:
    """
    usage:
        main_menu = Menu("title", ["choice 1", "choice 2", "choice 3"])
        
        print(f"choice: {main_menu.choice}")
    """
    
    def __init__(self,  title: str, menu: list[str]):
        self.__title = title
        self.__menu: list[str] = menu
        self.choice: str = ""
        self.__display()
    
    def __display(self) -> None:
        print("-- " + bright_yellow(f"{self.__title}") + " --")
        print()
        
        for i in range(len(self.__menu)):
            print(f"[{bright_green(i+1)}] {self.__menu[i]}")
            
        print()
        
        while True:
            choice_input = input("choice: ")
            
            if (not choice_input.isnumeric() or 
                int(choice_input) > len(self.__menu) or 
                int(choice_input) < 0):
                print("Index is out of bounds!")
                continue
            
            break
            
        choice_index = int(choice_input)
        
        if choice_index < 1:
            self.choice = self.__menu[choice_index]
        else: self.choice = self.__menu[choice_index-1]
        