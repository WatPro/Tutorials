
## Prepare Download List

```bash
folder_list='10list/'
mkdir --parent "${folder_list}"
page_download='https://target-data.nci.nih.gov/Public/AML/mRNA-seq/L3/expression/BCCA/'
curl ${page_download} | 
  sed --silent 's/^.*\shref="\([^\/]\+.txt\)".*$/\1/p' | 
  while read -r line
  do
    echo "${page_download}${line}"
  done > "${folder_list}BCCA.txt"

```

## Download Data from TARGET 

```bash
folder_raw='00raw/'
mkdir --parent "${folder_raw}"
folder_list='10list/'
cat "${folder_list}BCCA.txt" | 
  ##sed --silent '/\.gene\.quantification\.txt$/p' |
  while read -r line
  do 
    curl --output "${folder_raw}${line##*/}" "${line}"
  done

```

## Download XML files

```bash
folder_raw='02raw_xml/'
folder_list='10list/'
mkdir --parent "${folder_list}"

curl --request POST --header "Content-Type: application/json" --data "@${folder_raw}Payload_full.json" 'https://api.gdc.cancer.gov/files' > "${folder_list}LAML.json"
curl --request POST --header "Content-Type: application/json" --data "@${folder_raw}Payload.json" 'https://api.gdc.cancer.gov/files' > "${folder_list}LAML.tsv"

api_data='https://api.gdc.cancer.gov/data/'
cat "${folder_list}LAML.tsv" | 
  sed --silent 's/^\([0-9a-z]\{8\}\(-[0-9a-z]\{4\}\)\{3\}-[0-9a-z]\{12\}\)\s\+\(\S\+\.xml\)\s.*$/\1 \3/p' | 
  while read -r line
  do
    uuid="${line%% *}"
    file="${folder_raw}${line##* }" 
    curl --output "${file}" "${api_data}${uuid}" 
  done

```

