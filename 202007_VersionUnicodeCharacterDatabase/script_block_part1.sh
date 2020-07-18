#!/usr/bin/bash


folder_raw='00raw_html/'
file_list="${folder_raw}list_file.txt"
unicodeRoot='https://unicode.org/Public/'

folder_block='01raw_block/'
mkdir --parent "${folder_block}"
sed --silent '/Blocks/p' "${file_list}" |
  while read -r line
  do
    url="${line}"
    version_t="${url##${unicodeRoot}}"
    version_t="${version_t%%/*}$"
    version_t="${version_t/-Update$/.0}"
    version_t="${version_t/-Update/.}"
    version="${version_t%$}"
    file_block="${folder_block}block_${version}.txt"
    curl --output "${file_block}" "${url}"
  done   
 
folder_blocklist='02txt_block/'
mkdir --parent "${folder_blocklist}"
filelistall="${folder_blocklist}blockall.txt"
ls ${folder_block}*.txt |
  while read -r line 
  do
    version_t="${line##*/}"
    version_t="${version_t##*_}"
    version_t="${version_t%.txt}"
    version="${version_t}"
    versions="${version//./'\t'}"
    sed --silent '/^[0-9A-F]/p' "${line}" |
      sed 's/; /\t/g' |
      sed 's/\.\./\t/g' |
      sed 's/^\(.*\)$/'"${versions}"'\t\1/'
  done |
  awk 'BEGIN{FS="\t"; OFS="\t";} {$4=strtonum("0x"$4); $5=strtonum("0x"$5); print;}' > "${filelistall}"


