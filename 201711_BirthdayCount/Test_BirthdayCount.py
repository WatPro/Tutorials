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
#from pymongo import MongoClient

########## Import the testing target       ##########
import BirthdayCount
from BirthdayCount import BirthdayCalculation as BC, UserInterface as UI


class TestBirthdayCalculation(unittest.TestCase):

    def __test_calculator(self,data): 
        with patch('BirthdayCount.date') as mock_date:
            mock_date.side_effect = lambda *args, **kw: date(*args, **kw) 
            mock_date.today.return_value = date(
                data['premise']['today_year'], 
                data['premise']['today_month'], 
                data['premise']['today_day']
            )
            self.assertEqual(
                BC.calculator(data['input']['DOB_month'],data['input']['DOB_day']), 
                data['expect']['ans']
            ) 

    def test_calculator(self):
        data = [
            {
                'premise':{
                    'today_year': 2017,
                    'today_month': 11, 
                    'today_day': 15
                }, 
                'input':{
                    'DOB_month': 11, 
                    'DOB_day': 15
                }, 
                'expect':{
                    'ans': 0
                }
            }, {
                'premise':{
                    'today_year': 2017,
                    'today_month': 11, 
                    'today_day': 15
                }, 
                'input':{
                    'DOB_month': 11, 
                    'DOB_day': 16
                }, 
                'expect':{
                    'ans': 1
                }
            }, {
                'premise':{
                    'today_year': 2017,
                    'today_month': 11, 
                    'today_day': 15
                }, 
                'input':{
                    'DOB_month': 11, 
                    'DOB_day': 17
                }, 
                'expect':{
                    'ans': 2
                }
            }, {
                'premise':{
                    'today_year': 2017,
                    'today_month': 12, 
                    'today_day': 19
                }, 
                'input':{
                    'DOB_month': 12, 
                    'DOB_day': 19
                }, 
                'expect':{
                    'ans': 0
                }
            }, {
                'premise':{
                    'today_year': 2017,
                    'today_month': 12, 
                    'today_day': 19
                }, 
                'input':{
                    'DOB_month': 12, 
                    'DOB_day': 26
                }, 
                'expect':{
                    'ans': 7
                }
            }, {
                'premise':{
                    'today_year': 2017,
                    'today_month': 12, 
                    'today_day': 19
                }, 
                'input':{
                    'DOB_month': 1, 
                    'DOB_day': 1
                }, 
                'expect':{
                    'ans': 13
                }
            }, {
                'premise':{
                    'today_year': 2017,
                    'today_month': 12, 
                    'today_day': 19
                }, 
                'input':{
                    'DOB_month': 2, 
                    'DOB_day': 1
                }, 
                'expect':{
                    'ans': 44
                }
            }
        ]
        for each in data: 
            with self.subTest('test_calculator'):
                self.__test_calculator(each)
    

class TestUserInterface(unittest.TestCase):
    
    def test_ask(self): 
        UI_ui = UI()
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
    unittest.main(verbosity=2)
    
    