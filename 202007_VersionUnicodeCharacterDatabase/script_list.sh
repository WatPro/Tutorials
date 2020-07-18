#!/usr/bin/bash

folder_raw='00raw_html/'
mkdir --parent "${folder_raw}"
 
file_root="${folder_raw}index.html"
unicodeRoot='https://unicode.org/Public/'
curl --output "${file_root}" "${unicodeRoot}"

file_list_all="${folder_raw}list_file_all.txt"
rm --force "${file_list_all}"
sed --silent 's!^.*\shref="\([^"]*\/\)".*$!\1!p' "${file_root}" |
  sed --silent '/^[0-9]/p' | 
  sed --silent 's!\(.*\)!'"${unicodeRoot}"'\1!p' |
  while read -r line
  do
    suburl="${line}"
    version_t="${suburl%/}"
    version_t="${version_t##*/}$"
    version_t="${version_t/-Update$/.0}"
    version_t="${version_t/-Update/.}"
    version="${version_t%$}"
    index_sub="${folder_raw}index_raw_${version}.html"
    curl --output "${index_sub}" "${suburl}"
    sed --silent 's!^.*\shref="\([^"]*\)".*$!\1!p' "${index_sub}" |
      sed --silent '/^[^\/].*\..*[^\/]$/p' |
      sed --silent 's!\(.*\)!'"${suburl}"'\1!p' >> "${file_list_all}"
    subsuburl=`sed --silent 's!^.*\shref="\([^"]*\)".*$!\1!p' "${index_sub}" |
      sed --silent '/^ucd\/$/p' |
      sed --silent 's!\(.*\)!'"${suburl}"'\1!p'`
    if [ -n "${subsuburl}" ]
    then
      index_subsub="${folder_raw}index_raw_ucd_${version}.html"
      curl --output "${index_subsub}" "${subsuburl}"
      sed --silent 's!^.*\shref="\([^"]*\)".*$!\1!p' "${index_subsub}" |
        sed --silent '/^[^\/].*\..*[^\/]$/p' |
        sed --silent 's!\(.*\)!'"${subsuburl}"'\1!p' >> "${file_list_all}" 
    fi
  done
 
url_latest='https://www.unicode.org/versions/latest/'
file_latest="${folder_raw}latest.html"
curl --output "${file_latest}" "${url_latest}"

file_list="${folder_raw}list_file.txt"
version_t=`sed --silent 's!^.*\shref="\([^"]*\)".*$!\1!p' "${file_latest}"`
version_t="${version_t##*www.unicode.org/versions/Unicode}"
version_t="${version_t%/}"
version_latest="${version_t}"
print_switch=''
cat "${file_list_all}" |
  while read -r line 
  do
    url="${line}"
    version_t="${url##${unicodeRoot}}"
    version_t="${version_t%%/*}$"
    version_t="${version_t/-Update$/.0}"
    version_t="${version_t/-Update/.}"
    version="${version_t%$}"
    echo -e "${version}\t${url}"
  done | 
  sort --version-sort --key=1 --reverse | 
  while read -r line 
  do
    version="${line%$'\t'*}"
    if [ "${version}" = "${version_latest}" ] 
    then
      print_switch='on'
    fi
    if [ "${print_switch}" = 'on' ] 
    then
      url="${line#*$'\t'}"
      echo "${url}"
    fi 
  done > "${file_list}"


