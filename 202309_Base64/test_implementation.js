'use strict';

const assert   = require('node:assert');
const test     = require('node:test');
const fs       = require('fs');
const path     = require('path');
const CryptoJS = require('crypto-js');
const { Base16, Base32, Base64 } = require('./base_implementation.js');

const folderPath = 'testcase';
const re         = /^BASE.*\.json$/;
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

const genBaseFunc = function(BaseO) {
  return function(t) {
    const workArray = CryptoJS.enc.Latin1.parse(t);
    return BaseO.stringify(workArray);
  }
};
  
const genBaseRevFunc = function(BaseO) {
  return function(t) {
    const workArray = BaseO.parse(t);
    return CryptoJS.enc.Latin1.stringify(workArray);
  }
};

for (const category of ['BASE16','BASE32','BASE64']) {
  let BaseFunc, BaseRevFunc;
  switch (category) {
    case 'BASE16':
      BaseFunc    = genBaseFunc(Base16);
      BaseRevFunc = genBaseRevFunc(Base16);
      break;
    case 'BASE32':
      BaseFunc    = genBaseFunc(Base32);
      BaseRevFunc = genBaseRevFunc(Base32);
      break;
    case 'BASE64':
      BaseFunc    = genBaseFunc(Base64);
      BaseRevFunc = genBaseRevFunc(Base64);
      break;
    default:
      ;
  }
  sample.filter((item) => {
    return ('Category' in item) && (item['Category']===category);
  })
  .filter((item) => {
    return ('Input' in item) && ('Output' in item);
  })
  .map((item) => {
    const text     = item['Input'];
    const code     = item['Output'];
    const testFunc = `${category}("${text}")`;
    const testName = `${testFunc}`;
    test(testName, () => {
      const testResult = BaseFunc(text);
      assert.strictEqual(testResult, code);
    });
  });
  sample.filter((item) => {
    return ('Category' in item) && (item['Category']===category);
  })
  .filter((item) => {
    return ('Input' in item) && ('Output' in item);
  })
  .map((item) => {
    const text     = item['Input'];
    const code     = item['Output'];
    const testFunc = `${category}("${text}")`;
    const testName = `Reversed ${testFunc}`;
    test(testName, () => {
      const testResult = BaseRevFunc(code);
      assert.strictEqual(testResult, text);
    });
  });
}


