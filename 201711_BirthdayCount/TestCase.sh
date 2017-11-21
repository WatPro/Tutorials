#!/usr/bin/env bash

################################################################################
########## Test Cases are set on 2017-11-15                           ##########
################################################################################

PROG=BirthdayCount_Testable
TF01=STDOUT.txt
TF02=STDERR.txt

COMP_A() {
./"$PROG" "$1" 1>"$TF01" 2>"$TF02"
##  ##
PASS1=`diff --ignore-trailing-space "$TF01" <(echo -n "$2")`
PASS2=`diff --ignore-trailing-space "$TF02" <(echo -n "$3")`
if [[ -z "$PASS1" && -z "$PASS2" ]]
then
echo "INPUT(AS ARGUMENT): $1, passed. "
else 
echo "INPUT(AS ARGUMENT): $1, failed. "
fi 
}

COMP_B() {
./"$PROG" <<< "$1" 1>"$TF01" 2>"$TF02"
##  ##
PASS1=`diff --ignore-trailing-space "$TF01" <(echo -n "$2")`
PASS2=`diff --ignore-trailing-space "$TF02" <(echo -n "$3")`
if [[ -z "$PASS1" && -z "$PASS2" ]]
then
echo "INPUT (VIA STDIN) : $1, passed. "
else 
echo "INPUT (VIA STDIN) : $1, failed. "
fi 
}

INPUT1=1115
EXPECT=0
ERRMSG=

COMP_A "$INPUT1" "$EXPECT" "$ERRMSG"
COMP_B "$INPUT1" "$EXPECT" "$ERRMSG"

INPUT1=0229
EXPECT=836
ERRMSG=

COMP_A "$INPUT1" "$EXPECT" "$ERRMSG"
COMP_B "$INPUT1" "$EXPECT" "$ERRMSG"

INPUT1=0100
EXPECT=
ERRMSG="Invalid Input!!!"

COMP_A "$INPUT1" "$EXPECT" "$ERRMSG"
COMP_B "$INPUT1" "$EXPECT" "$ERRMSG"

rm -f "$TF01" "$TF02"

