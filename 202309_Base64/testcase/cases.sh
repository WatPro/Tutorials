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

urlrfc='https://www.rfc-editor.org/rfc/rfc6238.txt'
filerfc='TOTP.json'

(
echo 'Seconds,TOTP,Digits,Mode,Secret' &
curl "${urlrfc}" |
  sed '0,/^Appendix B.[ ]\+Test Vectors$/d' |
  sed '/^[ ]*Table 1: TOTP Table[ ]*$/,$d' |
  sed --silent 's/^[ ]*|[ ]*\([0-9]*\)[ ]*|[^|]*|[^|]*| \([0-9]\+\) |[ ]*\([^ |]*\)[ ]*|[ ]*$/\1,"\2",8,\3,\3/p' |
  sed 's/,SHA1$/,"12345678901234567890"/' |
  sed 's/,SHA256$/,"12345678901234567890123456789012"/' |
  sed 's/,SHA512$/,"1234567890123456789012345678901234567890123456789012345678901234"/'
) | 
  python3 -c 'import csv, json, sys; sys.stdout.write(json.dumps([dict(r) for r in csv.DictReader(sys.stdin)],indent=4))' > "${filerfc}"
