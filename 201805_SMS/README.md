
## Sending Messages via Cloopen Text Message Platform 

```bash
cat cloopen_test.sh | \
    sed "s/^\(mobiles=\).*$/\1'15000000000,13000000000'/ ; s/^\(accountSid=\).*$/\1'0'/ ; s/^\(accountToken=\).*$/\1'0'/ ; s/^\(appId=\).*$/\1'0'/ ; s/^\(templateId=\).*$/\1'1'/" |\
    sed "s/^\(datas=\).*$/\1'[\"Secret\",\"2\"]'/ " | \
    sed "s|^\(domain=\).*$|\1'https://sandboxapp.cloopen.com:8883'|" |\
    bash -
```
 
