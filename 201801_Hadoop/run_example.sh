#!/bin/sh
 
INPUT="./Data_Example"
OUTPUT="./Results"
EXAMPLE_JAR=`ls /usr/local/hadoop-*/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar`
JAR_FILE="examples.jar"
rm --recursive --force "$INPUT" "$OUTPUT"
 
mkdir --parents "$INPUT"
cat << END_OF_FILE > "$INPUT/Time.txt"
Money is not evil by itself
It's just paper with perceived value to obtain other things we value in other ways
If not money – what is evil you may ask?
Evil is the unquenchable, obsessive and moral bending desire for more
Evil is the bottomless, soulless and obsessive-compulsive pursuit of some pot of gold at the end of some rainbow which doesn't exist
Evil is having a price tag for your heart and soul in exchange for financial success at any cost
Evil is trying to buy happiness, again and again
until all of those fake, short lived mirages of emotions are gone
Make more time
I'm not saying you can't be financially successful
I'm saying have a greater purpose in life well beyond the pursuit of financial success
Your soul is screaming for you to answer your true calling
You can change today if you redefine what success is to you
You can transform your damaged relationships and build new ones
You can forgive yourself and others who've hurt you
You can become a leader by mentoring with others who you aspire to be like
You can re-balance your priorities in life
You can heal your marriage and recreate a stronger love than you ever thought possible
You can become the best parent possible at any age – even 86
but don't wait until then...
You will always be able to make more money
But you cannot make more time
END_OF_FILE
cat << END_OF_FILE > "$INPUT/Perfect.txt"
I found a love for me
Darling just dive right in and follow my lead
Well I found a girl beautiful and sweet
Oh I never knew you were the someone waiting for me
'Cause we were just kids when we fell in love
Not knowing what it was
I will not give you up this time
Darling just kiss me slow your heart is all I own
And in your eyes you're holding mine
Baby I'm dancing in the dark with you between my arms
Barefoot on the grass listening to our favourite song
When you said you looked a mess I whispered underneath my breath
But you heard it darling you look perfect tonight
Well I found a woman stronger than anyone I know
She shares my dreams I hope that someday I'll share her home
I found a love to carry more than just my secrets
To carry love to carry children of our own
We are still kids but we're so in love
Fighting against all odds
I know we'll be alright this time
Darling just hold my hand
Be my girl I'll be your man
I see my future in your eyes
Baby I'm dancing in the dark with you between my arms
Barefoot on the grass listening to our favorite song
When I saw you in that dress looking so beautiful
I don't deserve this darling you look perfect tonight
Baby I'm dancing in the dark with you between my arms
Barefoot on the grass listening to our favorite song
I have faith in what I see
Now I know I have met an angel in person
She looks perfect
I don't deserve this
You look perfect tonight
END_OF_FILE
 
hadoop com.sun.tools.javac.Main WordCount2.java Grep.java
jar cf "$JAR_FILE" *.class
# hadoop jar "$JAR_FILE" WordCount2 "$INPUT/*.txt" "$OUTPUT"
hadoop jar "$JAR_FILE" Grep "$INPUT/*.txt" "$OUTPUT" "I(\S)*"
# hadoop jar "$EXAMPLE_JAR" grep "$INPUT/*.txt" "$OUTPUT" "I(\S)*"
# hadoop jar "$EXAMPLE_JAR" wordcount "$INPUT/*.txt" "$OUTPUT" 
 
