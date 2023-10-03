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
  const g = function(b=6) {
    const size = 2**b;
    const mask = size-1;
    const bobj = {
      _map: maps[b],
      stringify: function(wa) {
        wa.clamp();
        const w    = wa.words;
        const s    = wa.sigBytes;
        const sbit = s*8;
        const map  = this._map;
        const v = [];
        for (let ii=0; ii<sbit; ii+=b) { // process b bits each time
          let u           = 0;
          let {q:jj,r:kk} = division(ii,8);
          let shift       = 8-b-kk;
          let uo          =  w[(jj)>>2] >>> 8*(3-(jj)%4);
          if (shift >= 0) {
            u |= (uo >>> shift);
          } else {
            uo    &= mask;
            u     |= (uo << (-shift));
            shift += 8;
            uo     =  w[(jj+1)>>2] >>> 8*(3-(jj+1)%4);
            u     |= (uo >>>  shift);
          }
          u    &= mask;
          let c = map.charAt(u);
          v.push(c);
        }
        const padding = map.charAt(size);
        if (padding !== '') {
          for (; (v.length * b) % 8 !== 0; ) {
            v.push(padding);
          }
        }
        return v.join('');
      },
      parse: function(t) {
        let l    = t.length;
        let m    = this._map;
        let rMap = this._reverseMap;
        if (rMap===undefined) {
          rMap = this._reverseMap = [];
          for (let ii = 0; ii < m.length; ii++) {
            rMap[m.charCodeAt(ii)] = ii;
          }
        }
        let padding = m.charAt(size);
        if (padding!='') {
          let paddingAt = t.indexOf(padding);
          if ( paddingAt !== -1 ) {
            l = paddingAt;
          }
        }
        return (function(t, l, m) {
          let w  = [];
          let s  = 0;
          for (let ii = 0; ii < l; ii +=1) {
            let c  = m[t.charCodeAt(ii)];
            let {q:jj,r:kk} = division(ii*b,8);
            let sh = (8-b)-kk;
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
        })(t, l, rMap);
      },
    };
    return bobj;
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
