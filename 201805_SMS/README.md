
## Sending Messages via Alibaba DaYu SMS API 

See demo [here](./TEST.md#alibaba-dayu-sms-api).

The following script help to send messages to mobile users listed in [sample.txt](./sample.txt)

```bash
yes | cp "dayu_test.sh" "dayu.sh"
## Installation and Setup
sed --in-place "s/^accessKeyId=.*$/accessKeyId='testId'/" "dayu.sh"
sed --in-place "s/^accessSecret=.*$/accessSecret='testSecret'/" "dayu.sh"
sed --in-place "s/^LOG_FILE=.*$/LOG_FILE='log_dayu.log'/" "dayu.sh"
## Set A Job 
export phoneNumbers=`sed "s/\r$//" sample.txt | paste --serial --delimiters=","`
export templateCode='SMS_71390007'
export templateParam='{"customer":"test"}'
export signName='阿里云短信测试专用'
bash dayu.sh
```

## Sending Messages via Cloopen Text Message Platform 

```bash
cat cloopen_test.sh |\
    sed "s/^\(accountSid=\).*$/\1'0'/ ; s/^\(accountToken=\).*$/\1'0'/ ; s/^\(appId=\).*$/\1'0'/" |\
    sed "s/^\(mobiles=\).*$/\1'15000000000,13000000000'/" |\
    sed "s/^\(templateId=\).*$/\1'1'/ ; s/^\(datas=\).*$/\1'[\"Secret\",\"2\"]'/" |\
    sed "s|^\(domain=\).*$|\1'https://sandboxapp.cloopen.com:8883'|" |\
    bash -
```
 
