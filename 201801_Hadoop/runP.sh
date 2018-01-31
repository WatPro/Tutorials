#!/bin/sh
 
INPUT="./DataP"
OUTPUT="./Results"
JAR_FILE="examples.jar"
rm --recursive --force "$OUTPUT"
 
hadoop com.sun.tools.javac.Main SalesAnalyzer.java
jar cf "$JAR_FILE" *.class
hadoop jar "$JAR_FILE" SalesAnalyzer "$INPUT/*.txt" "$OUTPUT"
 
echo
echo "Job 2: output sample"
cat ${OUTPUT}/SumCostByItem/part-r-* | grep "\(Toys\)\|\(Consumer Electronics\)"
echo
echo "Job 3: output sample" 
cat ${OUTPUT}/MaxCostByStore/part-r-* | grep "\(Reno\)\|\(Toledo\)\|\(Chandler\)"
echo 
echo "Job 4: output sample" 
cat ${OUTPUT}/Total/part-r-*
 