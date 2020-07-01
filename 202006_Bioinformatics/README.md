
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

## Download Clinical Data

```bash
folder_raw='03raw_json/'
mkdir --parent "${folder_raw}"
folder_raw_xml='02raw_xml/'
folder_list='13list_json/'

api_file='https://api.gdc.cancer.gov/files'
curl --request POST --header "Content-Type: application/json" --data "@${folder_list}search_payload_full.json" "${api_file}" > "${folder_raw}LAML_FULL.json"
curl --request POST --header "Content-Type: application/json" --data "@${folder_list}search_payload.json" "${api_file}" > "${folder_raw}LAML.json"

payloadbulk="${folder_list}download_payload_bulk.json"
python3 script_payload_gen_bulk.py > "${payloadbulk}"
api_data='https://api.gdc.cancer.gov/data/'
download_filename='gdc_download.tar.gz'
curl --output "${download_filename}" --request POST --header 'Content-Type: application/json' --data @${payloadbulk} "${api_data}"
tar --extract --file="${download_filename}" --directory="${folder_raw_xml}"

```

## Get Common Data Element definition

```bash
folder_raw='02raw_xml/'
folder_list='10list/'
mkdir --parent "${folder_list}"

python3 get_CDEList.py > "${folder_list}cde_id_raw.txt"
cat "${folder_list}cde_id_raw.txt" | sort --ignore-leading-blanks --ignore-nonprinting --field-separator=$'\t' --key=3,3 --key=1,1 | uniq > "${folder_list}cde_id_sorted.txt"
api_search='https://cdebrowser.nci.nih.gov/cdebrowserServer/rest/search?publicId=__cde__'
cat "${folder_list}cde_id_sorted.txt" | 
  cut --delimiter=$'\t' --fields=3 | 
  sed '/^$/d' | 
  sort --numeric-sort | uniq | 
  while read -r line 
  do
    api_search_query="${api_search/__cde__/$line}"
    jsonpath="${folder_raw}search_${line}.json"
    curl --output "${jsonpath}" "${api_search_query}"
  done 

api_deIdseq='https://cdebrowser.nci.nih.gov/cdebrowserServer/rest/CDEData?deIdseq=__deIdseq__'
cat ${folder_raw}search_*.json |
  sed 's/,/,\n/g' |

  sed --silent 's/^.*"deIdseq":"\([^"]*\)".*$/\1/p' |
  while read -r line
  do
    api_search_query="${api_deIdseq/__deIdseq__/$line}"
    jsonpath="${folder_raw}deIdseq_${line}.json"
    curl --output "${jsonpath}" "${api_search_query}"
  done 

python3 get_CDEdefinition.py > "${folder_list}CDE_Definition.txt"

```


