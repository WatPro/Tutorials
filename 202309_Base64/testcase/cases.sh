#!/usr/bin/bash

thisscript=`realpath "${0}"`
thispath="${thisscript%/*}/"
cd "${thispath}"

## [Test Vectors](https://datatracker.ietf.org/doc/html/rfc4648#section-10 "The Base16, Base32, and Base64 Data Encodings")

urlrfc='https://www.rfc-editor.org/rfc/rfc4648.txt'
filerfc='BASE.json'

curl "${urlrfc}" |
  sed '0,/^10.[ ]*Test Vectors$/d' |
  sed '/^11.[ ]*ISO C99 Implementation of Base64$/,$d' |
  sed --silent 's/^[ ]*\(BASE[^(]*\)("\([^"]*\)")[ ]*=[ ]*"\([^"]*\)"[ ]*$/\1,"\2","\3"/p' |
  (
    echo 'Category,Input,Output' & 
    while read -r line
      do
        echo "${line}"
      done
  ) | 
  python3 -c 'import csv, json, sys; sys.stdout.write(json.dumps([dict(r) for r in csv.DictReader(sys.stdin)],indent=4))' > "${filerfc}"


## https://github.com/agnoster/base32-js/blob/master/test/base32-test.coffee
## https://github.com/agnoster/base32-js/blob/master/README.md

file32='BASE32.json'

(
echo 'Category,Input,Output' & 
cat << END_OF_FILE | sed 's/"\([^"*]*\)"$/"\U\1"/'
BASE32,"lowercase UPPERCASE 1234567 !@#$%^&*","dhqqetbjcdgq6t90an850haj8d0n6h9064t36d1n6rvj08a04cj2aqh658"
BASE32,"Hello World","91jprv3f41bpywkccg50"
BASE32,"Wow, it really works!","axqqeb10d5u20wk5c5p6ry90exqq4uvk44"
END_OF_FILE
) | python3 -c 'import csv, json, sys; sys.stdout.write(json.dumps([dict(r) for r in csv.DictReader(sys.stdin)],indent=4))' > "${file32}"
