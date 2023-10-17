#!/usr/bin/bash

thisscript=`realpath "${0}"`
thispath="${thisscript%/*}/"
cd "${thispath}"

npm init --yes
npm install crypto-js
npm install base32

folderbackup='backup/'
mkdir --parent "${folderbackup%/}/"
filesource='node_modules/crypto-js/enc-base64.js'
if [[ -f "${filesource}" ]]
then
  cp --force "${filesource}" "${folderbackup%/}/"
fi

urljs='https://cdnjs.cloudflare.com/ajax/libs/crypto-js/4.1.1/crypto-js.min.js'
filejs="${urljs##*/}"
filejs="${folderbackup%/}/${filejs}"
curl --output "${filejs}" "${urljs}"

