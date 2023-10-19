'use strict';

const CryptoJS = require('crypto-js');

const generateTOTP = function(key, seconds=0, digits=8, mode='HmacSHA1') {
  let hashFunc;
  switch (mode) {
    case 'HmacSHA512':
      hashFunc = CryptoJS.HmacSHA512;
      break;
    case 'HmacSHA256':
      hashFunc = CryptoJS.HmacSHA256;
      break;
    case 'HmacSHA1':
    default:
      hashFunc = CryptoJS.HmacSHA1;
  }
  const Hex      = CryptoJS.enc.Hex;
  const hexParse = function(h) {
    return Hex.parse(h);
  };
  const getByte = function(wordArray,location) {
    const words = wordArray.words;
    const shift = location%4;
    const byte  = (location-shift)/4;
    return words[byte]>>> 8*(3-shift);
  };
  const HOTPComputation = function(hash, digits) {
    const words    = hash.words;
    const sigBytes = hash.sigBytes;
    const lastByte = getByte(hash,sigBytes-1)
    const offset = lastByte & 0xf;
    const oset   = offset % 4;
    const bstart = (offset-oset)/4;
    let byte1 = words[bstart] << 8*oset;
    let byte2 = 0;
    if (oset>0) {
      byte2 = words[bstart+1] >>> 8*(4-oset);
    }
    let code = byte1 | byte2;
    code &= 0x7fffffff;
    code  = code.toString(10);
    code  = code.slice(-digits);
    code  = code.padStart(digits, '0')
    return code;
  };
  const stepSize   = 30;
  const second0    = 0;
  const steps      = parseInt((seconds-second0)/stepSize);
  const stepsHex   = steps.toString(16).padStart(16,'0').toUpperCase();
  const stepsWords = hexParse(stepsHex);
  const hash       = hashFunc(stepsWords,key);
  const code       = HOTPComputation(hash,digits);
  return code;
};

module.exports = {
  generateTOTP: generateTOTP
};