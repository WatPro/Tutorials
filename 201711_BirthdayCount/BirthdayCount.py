#!/usr/bin/env python3

################################################################################
########## Tell How Many Days You Have To Wait Until Your Birthday    ##########
################################################################################


########## Import from standard libeary ##########
from sys import argv, stdin, stdout
from datetime import date


class BirthdayCalculation():
    @classmethod
    def valid_date(cls, month, day):
        """Check If Input Date Is Valid 
        import calendar
        calenar.isleap(2000) == True
        """
        LEAP_YEAR = 2000
        try: 
            date(LEAP_YEAR, month, day)
        except ValueError as e: 
            return False
        except:
            return False
        return True
 
    @classmethod
    def calculator(cls, birthday_month, birthday_day): 
        """Calculate the number of days to the next birthday """
        date_today = date.today() 
        year = date_today.year
        if ( cls.valid_date(birthday_month, birthday_day) ): 
            while True:
                try: 
                    birthday = date(year, birthday_month, birthday_day)  
                except ValueError:
                    """intended for 02-29 """
                except: 
                    """Unexpected Exception """
                    return -1 
                else: 
                    if birthday >= date_today: 
                        return (birthday-date_today).days
                year += 1
        return -1
        

class UserInterface():

    def __init__(self):  
        self.__max_attempt = 3 
        
    def ask(self):
        """Input""" 
        days_month = [31, 29, 31 , 30, 31, 30, 31, 
                      31, 30, 31, 30, 31]
        attempt = 0
        while True: 
            stdout.write("Enter MONTH(1-12) of your date of birth: ") 
            stdout.flush() 
            line = stdin.readline().strip()
            attempt += 1
            if line.isdigit() and int(line)>=1 and int(line)<=12: 
                MM = int(line) 
                break
            elif attempt >= self.__max_attempt: 
                return
        attempt = 0
        max_day = days_month[MM-1]
        while True: 
            stdout.write("Enter DAY(1-{}) of your date of birth: ".format(max_day)) 
            stdout.flush() 
            line = stdin.readline().strip()
            attempt += 1
            if line.isdigit() and int(line)>=1 and int(line)<=max_day: 
                DD = int(line)
                break
            elif attempt >= self.__max_attempt: 
                return 
        return (MM,DD)
        
    def answer(self, ans): 
        try: 
            if ans!=int(ans) or ans<0:
                return
        except:
            return
        if ans == 0:
            stdout.write("Happy Birthday!!! \n")
        elif ans == 1: 
            stdout.write("Your Birthday Will Be {} Day Later. \n".format(ans))
        elif ans > 1: 
            stdout.write("Your Birthday Will Be {} Days Later. \n".format(ans))
        return
                

if __name__ == "__main__": 

    ui = UserInterface() 
    if len(argv)>=3 and argv[1].isdigit() and argv[2].isdigit() :
        MM = int(argv[1])
        DD = int(argv[2])
    else: 
        MMDD = ui.ask()
        if MMDD == None: 
            sys.exit(1)
        else: 
            (MM,DD) = MMDD
    result = BirthdayCalculation.calculator(MM,DD) 
    ui.answer(result)

    