#!/bin/sh
 
INPUT="./DataA"
OUTPUT="./Results"
JAR_FILE="examples.jar"
rm --recursive --force "$OUTPUT"
 
hadoop com.sun.tools.javac.Main NetAnalyzer.java
jar cf "$JAR_FILE" *.class
hadoop jar "$JAR_FILE" NetAnalyzer "$INPUT/*log" "$OUTPUT"
 
echo 
echo "Job 5: output sample"
cat ${OUTPUT}/SumHitByFile/part-r-* | grep "the-associates\.js"
echo 
echo "Job 6: output sample"
cat ${OUTPUT}/SumHitByAddress/part-r-* | grep "10\.99\.99\.186"
echo 
echo "Job 5: sorted output sample"
awk --field-separator="\t" '{printf("%s\t%s\n", $2, $1)}' ${OUTPUT}/SumHitByFile/part-* | sort --reverse --numeric-sort | head
echo "Job 7: output sample"
head ${OUTPUT}/SortedHitByFile/part-r-*
 