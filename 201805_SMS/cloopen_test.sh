
mobiles='15000000000'
accountSid='00000000000000000000000000000000'
accountToken='00000000000000000000000000000000'
appId='00000000000000000000000000000000'
templateId='1'
datas='["恭喜发财","两万"]'
if [ -n "$datas" ]
then
    datas=",\"datas\":$datas"
else 
    datas=''
fi
data="{\"to\":\"${mobiles}\",\"appId\":\"${appId}\",\"templateId\":\"${templateId}\"${datas}}"
datetime=$(date +"%Y%m%d%H%M%S")
SigParameter=`echo -n ${accountSid}${accountToken}${datetime} | md5sum | cut --delimiter=' ' --fields=1 | tr "[:lower:]" "[:upper:]"`
domain='https://app.cloopen.com:8883'
url="/2013-12-26/Accounts/${accountSid}/SMS/TemplateSMS?sig=${SigParameter}"
https_url="${domain}${url}"
Authorization=`echo -n "${accountSid}:${datetime}" | base64`
curl \
    --header 'Accept: application/json' \
    --header 'Content-Type: application/json;charset=utf-8' \
    --header "Authorization: ${Authorization}" \
    --data "${data}"\
    --request POST "${https_url}"
