#!/usr/bin/env bash

if [ ! -e junit-4.12.jar ] 
then
    curl -O http://search.maven.org/remotecontent?filepath=junit/junit/4.12/junit-4.12.jar
fi

javac BirthdayCalculation.java

javac -classpath '.:./junit-4.12.jar' Test_BirthdayCalculation.java

java -classpath '.:./junit-4.12.jar:./hamcrest-core-1.3.jar' org.junit.runner.JUnitCore Test_BirthdayCalculation