# Birthday Count
 
This exercise evolves for quality assurance purposes, and concludes in the idea of unit testing. 
 
The question asked was what is the number of days until your birthday. 

### BirthdayCount 
 
This script tries to include user-friendly UI features, and as a result, verifying the results largely relays on manual operations. Attempts to automatically run it with standard streams (stdin/stdout) are troubled by its UI's I/O. 

Moreover, if any try goes wrong, it is hard to tell which part of the program (UI or the core) causes it. 
 
### BirthdayCount_Testable 

This script could be tested via another script TestCase.sh since the unnecessary UI features are simplified. 
 
However, the results are time-sensitive, so test cases will need to be modified when conduced next time (on another date). 
 
### BirthdayCount.py 
 
This script keeps a user-friendly user interface, but it is separated from the core part of the program (different units). 
 
The date of today is mocked so that the test script Test_BirthdayCount.py is repeatable anytime. 
 
