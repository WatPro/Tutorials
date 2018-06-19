
```bash
URL='https://dev.mysql.com/downloads/connector/j/?tpl=platform&os=31'
DOMAIN=`echo "${URL}" | sed --silent 's_^\(http[s]\?://[a-zA-Z0-9\.]*/\).*_\1_p'`
PAGE=`curl "${URL}" | sed --silent 's_^.*<a href="\(/downloads/file/?id=[0-9]*\)">Download</a>.*_\1_p' | head --lines=1`
DOWNLOAD_PAGE="${DOMAIN%/}${PAGE}"
RPM_PATH=`curl "${DOWNLOAD_PAGE}" | sed --silent 's/^.*href="\([^"]*\.rpm\)".*$/\1/p'`
DOWNLOAD_RPM="${DOMAIN%/}${RPM_PATH}"
```
