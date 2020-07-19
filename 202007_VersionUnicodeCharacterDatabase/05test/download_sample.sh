#!/bin/bash

rm *.raw --force
rm *.sample --force
cat sample.txt | 
  sed --silent '/\t/p' |
  while read -r line 
  do 
    url="${line##*$'\t'}"
    scode="${line%%$'\t'*}"
    uuid=`uuidgen`
    echo "${uuid}"
    file_raw="${uuid}.raw"
    curl --output "${file_raw}" "${url}" --header 'user-agent: Mozilla/5.0'
    file_sample="${uuid}.sample"
    iconv --from-code="${scode}" --to-code=UTF-8 --output="${file_sample}" "${file_raw}"
  done
