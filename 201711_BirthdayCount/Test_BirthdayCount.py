#!/usr/bin/env python3

import unittest
from unittest.mock import patch
import BirthdayCount
from BirthdayCount import BirthdayCalculation
from datetime import date

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
        

if __name__ == '__main__':
    unittest.main()