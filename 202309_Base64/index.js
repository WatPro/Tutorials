'use strict';

const CryptoJS = require('crypto-js');
const assert   = require('node:assert');
const test     = require('node:test');
const { Base16, Base32, Base64 } = require('./base_implementation.js');

// https://datatracker.ietf.org/doc/html/rfc4648#section-10
const TestCases = {
  'BASE16': [
    ['',      ''],
    ['f',     '66'],
    ['fo',    '666F'],
    ['foo',   '666F6F'],
    ['foob',  '666F6F62'],
    ['fooba', '666F6F6261'],
    ['foobar','666F6F626172']
  ],
  'BASE32': [
    ['',      ''],
    ['f',     'MY======'],
    ['fo',    'MZXQ===='],
    ['foo',   'MZXW6==='],
    ['foob',  'MZXW6YQ='],
    ['fooba', 'MZXW6YTB'],
    ['foobar','MZXW6YTBOI======']
  ],
  'BASE64': [
    ['',      ''],
    ['f',     'Zg=='],
    ['fo',    'Zm8='],
    ['foo',   'Zm9v'],
    ['foob',  'Zm9vYg=='],
    ['fooba', 'Zm9vYmE='],
    ['foobar','Zm9vYmFy']
  ]
};


const genBaseFunc = function(BaseO) {
  return function(t) {
    const wa = CryptoJS.enc.Latin1.parse(t);
    return BaseO.stringify(wa);
  }
};

const genBaseRevFunc = function(BaseO) {
  return function(t) {
    const wa = BaseO.parse(t);
    return CryptoJS.enc.Latin1.stringify(wa);
  }
};


for (const [key, values] of Object.entries(TestCases)) {
  let BaseFunc, BaseRevFunc;
  switch (key) {
    case 'BASE16':
      BaseFunc    = genBaseFunc(Base16);
      BaseRevFunc = genBaseRevFunc(Base16);
      break;
    case 'BASE32':
      BaseFunc    = genBaseFunc(Base32);
      BaseRevFunc = genBaseRevFunc(Base32);
      break;
    case 'BASE64':
      // BaseFunc = genBaseFunc(CryptoJS.enc.Base64);
      // BaseFunc = genBaseFunc(Base64);
      BaseFunc    = genBaseFunc(Base64);
      // BaseFunc = genBaseRevFunc(CryptoJS.enc.Base64);
      // BaseFunc = genBaseRevFunc(Base64);
      BaseRevFunc = genBaseRevFunc(CryptoJS.enc.Base64);
      break;
    default:
      ;
  } 
  for (const pair of values) {
    const Text     = pair[0];
    const Code     = pair[1];
    const TestFunc = `${key}("${Text}")`;
    const TestName = `${TestFunc}`;
    // console.log(`Expecting : ${TestName} = "${Code}"`);
    // console.log(BaseFunc(Text));
    test(TestName, () => {
      const TestResult = BaseFunc(Text);
      assert.strictEqual(TestResult, Code);
    });
  }
  for (const pair of values) {
    const Text     = pair[0];
    const Code     = pair[1];
    const TestFunc = `${key}("${Text}")`;
    const TestName = `Reversed ${TestFunc}`;
    //console.log(`Expecting : "${Code}" = ${TestFunc}`);
    //console.log(BaseRevFunc(Code));
    test(TestName, () => {
      const TestResult = BaseRevFunc(Code);
      assert.strictEqual(TestResult, Text);
    });
  }
}

