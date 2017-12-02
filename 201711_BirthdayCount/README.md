# Birthday Count
 
This exercise evolves for quality assurance purposes, and concludes in the idea of unit testing. 
 
Practice Question:

```
Calculate the number of days between today and a coming birthday. 
```

### BirthdayCount 
 
This script tries to include user-friendly UI features, and as a result, verifying the results largely relays on manual operations. Attempts to automatically run it with standard streams (stdin/stdout) are troubled by its UI's I/O. 

Moreover, if any try goes wrong, it is hard to tell which part of the program (UI or the core) causes it. 
 
### BirthdayCount_Testable 

This script could be tested via another script `TestCase.sh` since the unnecessary UI features are simplified. 
 
However, the results are time-sensitive, so test cases will need to be modified when conduced next time (on another date). 
 
### BirthdayCalculation.java

This piece of code keeps a user-friendly user interface, but it is separated from the core part of the program. 

However, in order to be repeatedly tested, it has to be modified (see comments within the source file). 

Java is a hard promoter of object-oriented design. If this idea is followed, an implementation could have these three classes/objects: 

* Time Manager: know current date/time, timezone, verify if a date exist in calendar; in Java, Calendar carries out this role. 

* Person: store personal information such as the Date of Birth

* Calculator: find out the coming birthday, given DOB (from Person); calculator the difference between current date (from Time Manager) and that birthday

When the program is tested, the Time Manager would be mocked, so there will be certain results anytime. Completely adopting this idea to finish a simple task is controversial, and here only a class was written up (BirthdayCalculation) to fulfil the task. 
 
Shell script `Test_BirthdayCalculation.sh` helps run tests. 
 
### BirthdayCount.py 
 
The date of today is mocked so that the test script `Test_BirthdayCount.py` is repeatable anytime. 

Mocking is conducted more naturally compared to the one in Java. This dues mainly to the fact that Python is more a scripting language than a programming language (as Java). 
 
