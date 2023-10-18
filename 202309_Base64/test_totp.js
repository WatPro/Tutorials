'use strict';


const fs       = require('fs');
const path     = require('path');
const CryptoJS = require('crypto-js');
const assert   = require('node:assert');
const test     = require('node:test');
const { generateTOTP } = require('./totp_implementation.js');

const folderPath = 'testcase';
const re         = /^TOTP.*\.json$/;
const sample     = fs.readdirSync(folderPath)
  .filter((fileName) => {
    return fileName.match(re);
  })
  .map((fileName) => {
    return path.join(folderPath, fileName);
  })
  .filter((fileName) => {
    return fs.lstatSync(fileName).isFile();
  })
  .map((fileName) => {
    return fs.readFileSync(fileName);
  })
  .map((data) => {
    return JSON.parse(data);
  })
  .reduce(
    (accumulator, currentValue) => {return accumulator.concat(currentValue)}, []
  );

sample.filter((item)=>{
    return ('Seconds' in item) && ('Code' in item) && ('Secret' in item);
  })
  .map((item)=>{
    const key      = CryptoJS.enc.Latin1.parse(item['Secret']);
    const seconds  = parseInt(item['Seconds']);
    const mode     = ('Mode' in item)?('Hmac'+item['Mode']):'';
    const digits   = parseInt(item['Digits']);
    const expected = item['Code'];
    const testName = `${seconds} seconds; ${mode}`;
    test(testName, () => {
      const code = generateTOTP(key, seconds, digits, mode)
      assert.strictEqual(code, expected);
    });
  });
