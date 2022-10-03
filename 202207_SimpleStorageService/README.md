
## Simple Storage Service recipes

### Copy Latest Versions

Copy the latest two (2) versions of CSV file(s) with prefix `s3://${s3bucket%/}/${inputkeyprefix}` to new location under `s3://${s3bucket%/}/${outputkeyprefix%/}`. Last Modified timestamps would be used to rename the files in the destination for differentiating versions from a same original location. 

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

### Recover Deleted Objects

Find out the version right before a file object was or objects were deleted, with prefix `s3://${s3bucket%/}/${inputkeyprefix}`, and create a copy for the version to new location under `s3://${s3bucket%/}/${outputkeyprefix%/}`. Version information indentified would be stored at file `s3version.json`. Information about reated objects would be stored at file `s3version.log`. 

```bash
aws s3api list-object-versions \
  --bucket "${s3bucket}" \
  --prefix "${inputkeyprefix}" \
  --query '[map(&(merge(@,`{"DeleteMarker":false}`)),Versions), map(&(merge(@,`{"DeleteMarker":true}`)), DeleteMarkers)][]' |
  ./jq '[.[]|select(.DeleteMarker?==true or .Size?>0)] | group_by(.Key) | [.[]|sort_by(.LastModified)|reverse] | [.[]|select(.[0].DeleteMarker?==true and .[0].IsLatest?==true)|select(.[1].IsLatest?==false and .[1].Key?!=null and .[1].VersionId?!=null)]' |
  ./jq '[.[]|.[1]?|select(.!=null)]' > s3version.json

aws s3api list-object-versions \
  --bucket "${s3bucket}" \
  --prefix "${inputkeyprefix}" \
  --query '[map(&(merge(@,`{"DeleteMarker":false}`)),Versions), map(&(merge(@,`{"DeleteMarker":true}`)), DeleteMarkers)][]' |
  ./jq '[.[]|select(.DeleteMarker?==true or .Size?>0)] | group_by(.Key) | [.[]|sort_by(.LastModified)|reverse] | [.[]|select(.[0].DeleteMarker?==true and .[0].IsLatest?==true)|select(.[1].IsLatest?==false and .[1].Key?!=null and .[1].VersionId?!=null)]' |
  ./jq '[.[]|.[1]?|select(.!=null)]' |
  ./jq --raw-output '[.[]|.Key+"?versionId="+.VersionId] | .[]' |
  while read -r line 
  do
    icopysource="${s3bucket%/}/${line}"
    destfile="${line%\?*}"
    destfile="${destfile##*/}"
    ikey="${outputkeyprefix%/}/${destfile}"
    aws s3api copy-object --copy-source "${icopysource}" --bucket "${s3bucket}" --key "${ikey}"
  done > s3version.log

```

These codes employs utility [jq](https://github.com/stedolan/jq/releases/tag/jq-1.5 "jq version 1.5"). It can be downloaded as the script block below. For its usage, see [Manual](https://stedolan.github.io/jq/manual/v1.5/ "jq 1.5 Manual").
 
```bash
if [ ! -f 'jq' ]
then
  aws s3 cp s3://cdd-kpmg-mi-file-pool-prod/mitools/official/utility/jq/jq-1.5/jq-linux64 ./jq
  chmod +x ./jq
fi

```

