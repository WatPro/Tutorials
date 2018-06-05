
## Sending Messages via Alibaba DaYu SMS API 


## Sending Messages via Cloopen Text Message Platform 

```bash
cat cloopen_test.sh |\
    sed "s/^\(accountSid=\).*$/\1'0'/ ; s/^\(accountToken=\).*$/\1'0'/ ; s/^\(appId=\).*$/\1'0'/" |\
    sed "s/^\(mobiles=\).*$/\1'15000000000,13000000000'/" |\
    sed "s/^\(templateId=\).*$/\1'1'/ ; s/^\(datas=\).*$/\1'[\"Secret\",\"2\"]'/" |\
    sed "s|^\(domain=\).*$|\1'https://sandboxapp.cloopen.com:8883'|" |\
    bash -
```
 
