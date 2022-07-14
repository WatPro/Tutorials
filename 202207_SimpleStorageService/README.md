
## Simple Storage Service recipes

### Copy Latest Versions

Copy the latest two (2) versions of CSV file(s) under `s3://${s3bucket%/}/${inputkeyprefix}` to new location `s3://${s3bucket%/}/${outputkeyprefix}`. Different versions of a same file would be distincted with Last Modified timestamp.

```bash
aws s3api list-object-versions \
  --bucket "${s3bucket}" \
  --prefix "${inputkeyprefix}" \
  --query "reverse(sort_by(Versions,&LastModified))[:2] | [].{Key:join('?versionId=',[Key,VersionId]),LastModified:LastModified} | [].join(' ',[Key,LastModified])" |
  sed '/^\[\|\]$/d' |
  sed 's/^\s*"\|",\?\s*$//g' |
  while read -r line 
    do
      key="${line% *}"
      mtime="${line##* }"
      mtime=`echo ${mtime} | tr --delete --complement [0-9]`
      filename="${key##*/}"
      filename="${filename%\?*}"
      filename="${filename%.csv}"
      filename="${filename}_${mtime}.csv"
      icopysource="${s3bucket%/}/${key}"
      ikey="${outputkeyprefix%/}/${filename}"
      aws s3api copy-object --copy-source "${icopysource}" --bucket "${s3bucket}" --key "${ikey}"
    done

```
