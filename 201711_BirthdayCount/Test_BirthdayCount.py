#!/usr/bin/env python3

################################################################################
########## Test The Module BirthdayCount                              ##########
################################################################################


########## Import from standard libeary    ##########
import unittest
from unittest.mock import patch
from datetime import date
from io import StringIO

########## Import from related third party ##########
from pymongo import MongoClient

########## Import the testing target       ##########
import BirthdayCount
from BirthdayCount import BirthdayCalculation, UserInterface


class TestBirthdayCalculation(unittest.TestCase):

    def test_calculator(self):
        with patch('BirthdayCount.date') as mock_date: 
            mock_date.side_effect = lambda *args, **kw: date(*args, **kw)
            mock_date.today.return_value = date(2017, 11, 15)
            self.assertEqual(BirthdayCalculation.calculator(11,15), 0)
            self.assertEqual(BirthdayCalculation.calculator(11,16), 1)
            self.assertEqual(BirthdayCalculation.calculator(11,17), 2)
            self.assertEqual(BirthdayCalculation.calculator(11,18), 3)
            mock_date.today.return_value = date(2017, 12, 19)
            self.assertEqual(BirthdayCalculation.calculator(12,19), 0)
            self.assertEqual(BirthdayCalculation.calculator(12,26), 7)
            self.assertEqual(BirthdayCalculation.calculator( 1, 1), 13)
            self.assertEqual(BirthdayCalculation.calculator( 2, 1), 44)
    

class TestUserInterface(unittest.TestCase):
    
    def test_ask(self): 
        UI_ui = UserInterface()
        with patch('BirthdayCount.stdin', StringIO("1\n1\n")) , \
             patch('BirthdayCount.stdout', new_callable=StringIO): 
            self.assertEqual(UI_ui.ask(),(1,1))
        with patch('BirthdayCount.stdin', StringIO("02\n29\n")), \
             patch('BirthdayCount.stdout', new_callable=StringIO): 
            self.assertEqual(UI_ui.ask(),(2,29))
        with patch('BirthdayCount.stdin', StringIO("100\n100\n100\n100\n100\n100\n100\n")), \
             patch('BirthdayCount.stdout', new_callable=StringIO): 
            self.assertEqual(UI_ui.ask(),None)

if __name__ == '__main__':
    unittest.main()
    
    