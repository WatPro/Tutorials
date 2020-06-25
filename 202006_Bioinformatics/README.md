
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

Download Only GENE Data 

```
folder_raw='00raw/'
mkdir --parent "${folder_raw}"
folder_list='10list/'
cat "${folder_list}BCCA.txt" | 
  sed --silent '/\.gene\.quantification\.txt$/p' |
  while read -r line
  do 
    curl --output "${folder_raw}${line##*/}" "${line}"
  done

```

