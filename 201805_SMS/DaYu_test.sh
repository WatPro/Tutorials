#!/bin/bash

accessKeyId='testId'
accessSecret='testSecret'
phoneNumbers='15300000001'
templateCode='SMS_71390007'
templateParam='{\"customer\":\"test\"}'
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
Timestamp           2017-07-12T02:42:19Z
Format              XML
Action              SendSms
Version             2017-05-25
RegionId            cn-hangzhou
PhoneNumbers        ${phoneNumbers}
SignName            ${signName}
TemplateParam       ${templateParam}
TemplateCode        ${templateCode}
OutId               123
"""
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

echo "Sorted Parameters: "
echo
echo "${paras}" | awk '{ if (!/^Signature /) print $1 "=" $2}'
echo
echo "Sorted Query String: "
echo
echo "${sortedQueryString}"
echo
echo "String To Sign: "
echo
echo "${stringToSign}"
echo
echo "HMAC Cryptographic Key:  "
echo
echo "${secretKey}"
echo
echo "Signature: "
echo
echo "${signature}"
echo
echo "URL (GET method): "
echo
echo "${URL}"
