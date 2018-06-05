#!/bin/bash

accessKeyId='testId'
accessSecret='testSecret'
LOG_FILE='log_dayu.log'
if [ ! -n "${phoneNumbers}" ]
then
    >&2 echo 'Phone Number Needed! '
    exit 1 
fi
if [ ! -n "${signName}" ]
then
    signName='阿里云短信测试专用'
fi
if [ ! -n "${templateCode}" ]
then
    templateCode='SMS_71390007'
fi
if [ -n "`which uuidgen`" ]
then
    UUID=`uuidgen`
elif [ -n "`which dbus-uuidgen`" ]
then
    UUID=`dbus-uuidgen | sed 's/^\(.\{8\}\)\(.\{4\}\)\(.\{4\}\)\(.\{4\}\)/\1-\2-\3-\4-/'`
else 
    UUID=`date +"%T"`
fi
timestamp=`TZ=GMT date +"%Y-%m-%dT%H:%M:%SZ"`

function urlencode() {
    function percent() {
        read instream 
        i=0
        until [ ! -n "${instream:i:2}" ]
        do
            echo -n "%${instream:i:2}" 
            ((i=i+2))
        done
    }
    read instream 
    l="${#instream}"
    i=0
    until [ "$i" -ge "$l" ]
    do
        c="${instream:i:1}"
        case $c in
            [A-Za-z0-9-_.~])
                echo -n "$c"
            ;;
            *)
                echo -n "$c" | xxd -plain -u | percent
            ;;
        esac
        ((i=i+1))
    done
}

function specialUrlEncode() {
    read instream; 
    echo -n "${instream}" | urlencode | sed 's/+/%20/g' | sed 's/\*/%2A/g' | sed 's/%7E/~/g'
}

function urlencode_key_value() {
    while read line 
    do
        key=`echo "${line}" | sed 's/^\([^ ]\+\)\([ ]\+\)\(.*\)$/\1/' | urlencode` 
        separator=`echo "${line}" | sed 's/^\([^ ]\+\)\([ ]\+\)\(.*\)$/\2/'` 
        value=`echo "${line}" | sed 's/^\([^ ]\+\)\([ ]\+\)\(.*\)$/\3/' | urlencode` 
        echo "${key}${separator}${value}"
    done
} 

secretKey="${accessSecret}&"
paras="""
SignatureMethod     HMAC-SHA1
SignatureNonce      ${UUID}
AccessKeyId         ${accessKeyId}
SignatureVersion    1.0
Timestamp           ${timestamp}
Action              SendSms
Version             2017-05-25
RegionId            cn-hangzhou
PhoneNumbers        ${phoneNumbers}
SignName            ${signName}
TemplateCode        ${templateCode}
"""
if [ -n "${templateParam}" ]
then
paras="""
${paras}
TemplateParam       ${templateParam}
"""
fi
if [ -n "${outId}" ]
then
paras="""
${paras}
OutId               ${outId}
"""
fi
paras=`echo "${paras}" | awk '/.+/ && !/^Signature /'` 
sortedQueryString=`echo "${paras}" | LC_COLLATE=C sort | urlencode_key_value | awk '{printf "&%s=%s", $1, $2}'`
sortedQueryString="${sortedQueryString:1}"
stringToSign="GET&`echo / | specialUrlEncode`&`echo ${sortedQueryString} | specialUrlEncode`"
signature=`echo -n "${stringToSign}" | openssl dgst -sha1 -hmac "${secretKey}" -binary | base64`
paras="""
$paras
Signature           ${signature}
"""
paras=`echo "${paras}" | awk '/.+/'` 
URL="http://dysmsapi.aliyuncs.com/?`echo Signature | specialUrlEncode`=`echo ${signature} | specialUrlEncode`&${sortedQueryString}"

echo "GMT:"         >> "${LOG_FILE}"
echo "${timestamp}" >> "${LOG_FILE}"
echo "URL:"         >> "${LOG_FILE}"
echo "${URL}"       >> "${LOG_FILE}"
curl "${URL}"       >> "${LOG_FILE}"  2>> "${LOG_FILE}"
if [ $? -eq 0 ]
then
    echo "Request Successfully Processed "
else
    echo "Request NOT Successfully Processed "
fi
echo                >> "${LOG_FILE}"
echo                >> "${LOG_FILE}"
