
## Tests on Node.js `for` loop v.s. `map()`

```javascript 

const generateArray = function() {
    const test = [];
    for(let ii=0; ii<10000; ii+=1) {
        test.push(Math.random());
    }
    return test;
}

const numOperation = function(num) {
    return num*100;
}

const forTestOnce = function(test) {
    const testArray = test;
    console.time('for_loop')
    const t   = process.hrtime();
    const ll  = testArray.length;
    for(let ii=0; ii<ll; ii+=1) {
        numOperation(testArray[ii]); 
    }
    const tt  = process.hrtime(t);
    console.timeEnd('for_loop');
    return tt[0]+tt[1]/1000000000;
}

const mapTestOnce = function(test) {
    const testArray = test;
    console.time('map_loop')
    const t   = process.hrtime();
    testArray.map(numOperation);
    const tt  = process.hrtime(t);
    console.timeEnd('map_loop');
    return tt[0]+tt[1]/1000000000;
}

const mean_std = function(a) {
    const sum  = a.reduce((m1,m2)=>{return m1+m2;},0); 
    const nn   = a.length; 
    const mean = sum/nn; 
    const n_1  = nn-1;
    const b    = a.map((m)=>{return (m-mean)**2;}).reduce((m1,m2)=>{return m1+m2;},0);
    const std  = Math.sqrt(b/n_1);
    return [mean, std];
}

let forTimes = [];
let mapTimes = []
for(ii=0; ii<100; ii+=1) {
    const testArray = generateArray();
    const forTime = forTestOnce(testArray);
    const mapTime = mapTestOnce(testArray);
    forTimes.push(forTime);
    mapTimes.push(mapTime);
}

mean_std(forTimes)
mean_std(mapTimes)

```









