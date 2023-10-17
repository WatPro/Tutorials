'use strict';

const CryptoJS = require('crypto-js');

let Base64;
let Base32;
let Base16;

(function(){
  if ( typeof CryptoJS === 'undefined' ) {
    return;
  };
  const create = (function(w,s){return CryptoJS.lib.WordArray.create(w,s);});
  const maps = {
    4: '0123456789ABCDEF',
    5: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567=',
    6: 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/='
  };
  const division = function(dividend,divisor) {
    let remainder  = dividend % divisor;
    dividend      -= remainder;
    let quotient   = dividend / divisor;
    return {
      q: quotient,
      r: remainder
    };
  };
  const g = function(bitLen=6) {
    const size    = 2**bitLen;
    const mask    = size-1;
    const baseObj = {
      _map: maps[bitLen],
      stringify: function(wordArray) {
        wordArray.clamp();
        const words    = wordArray.words;
        const sigBytes = wordArray.sigBytes;
        const sigBits   = sigBytes*8;
        const map       = this._map;
        const baseChars = [];
        for (let ii=0; ii<sigBits; ii+=bitLen) { // process `bitLen` bits each time
          let value       = 0;
          let {q:jj,r:kk} = division(ii,8);
          let shift       = (8-bitLen)-kk;
          let valu0       =  words[(jj)>>2] >>> 8*(3-(jj)%4);
          if (shift >= 0) {
            value |= (valu0 >>> shift);
          } else {
            valu0 &= mask;
            value |= (valu0 << (-shift));
            shift += 8;
            valu0  =  words[(jj+1)>>2] >>> 8*(3-(jj+1)%4);
            value |= (valu0 >>>  shift);
          }
          value    &= mask;
          let char  = map.charAt(value);
          baseChars.push(char);
        }
        const paddingChar = map.charAt(size);
        if (paddingChar !== '') {
          for (; (baseChars.length * bitLen) % 8 !== 0; ) {
            baseChars.push(paddingChar);
          }
        }
        return baseChars.join('');
      },
      parse: function(baseStr) {
        let baseStrLength = baseStr.length;
        let map           = this._map;
        let reverseMap    = this._reverseMap;
        if (reverseMap===undefined) {
          reverseMap = this._reverseMap = [];
          for (let ii = 0; ii < map.length; ii++) {
            reverseMap[map.charCodeAt(ii)] = ii;
          }
        }
        let paddingChar = map.charAt(size);
        if (paddingChar!='') {
          let paddingAt = baseStr.indexOf(paddingChar);
          if ( paddingAt !== -1 ) {
            baseStrLength = paddingAt;
          }
        }
        return (function(t, l, m) {
          let w  = [];
          let s  = 0;
          for (let ii = 0; ii < l; ii +=1) {
            let c  = m[t.charCodeAt(ii)];
            let {q:jj,r:kk} = division(ii*bitLen,8);
            let sh = (8-bitLen)-kk;
            if (sh>=0) {
              let csh   = c <<   (sh);
              csh      &= 0b11111111;
              w[jj>>2] |= csh << ((3 - jj % 4) * 8);
              s         = jj + 1;
            } else {
              let csh   = c >>> (-sh);
              csh      &= 0b11111111;
              w[jj>>2] |= csh << ((3 - jj % 4) * 8);
              let cs2   = c << (8+sh);
              let j2    = jj + 1;
              cs2      &= 0b11111111;
              if ( cs2 !== 0 ) {
                w[j2>>2] |= cs2 << ((3 - j2 % 4) * 8);
                s = jj + 2;
              } else {
                s = jj + 1;
              }
            }
          }
          return create(w, s)
        })(baseStr, baseStrLength, reverseMap);
      },
    };
    return baseObj;
  };
  Base64 = g(6);
  Base32 = g(5);
  Base16 = g(4);
})();

module.exports = {
  Base16: Base16,
  Base32: Base32,
  Base64: Base64
};
