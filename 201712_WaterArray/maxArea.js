/**
 * @param {number[]} height
 * @return {number}
 */
var maxArea = function(height) {
    let ss = {}; 
    let maxh = -1;
    for(let ii=0; ii<height.length; ii+=1) {
        let h = height[ii]; 
        if( h>maxh ){
            maxh = h; 
        }
        if( ss.hasOwnProperty(h) ){
            let ht = ss[h]; 
            if( ii<ht.min ){
                ht.min = ii; 
            }
            if( ii>ht.max ){
                ht.max = ii; 
            }
        } else {
            ss[h] = {min:ii, max:ii}; 
        }
    }
    let top  = ss[maxh];
    let area = (top.max-top.min)*maxh;
    for( let h=maxh-1; h>=0; h-=1 ){
        if( !ss.hasOwnProperty(h) ){
            continue;
        }
        let mm = ss[h];
        let aa = [(mm.max-mm.min)*h];
        if( top.min<mm.min ) {
            aa.push([(mm.max-top.min)*h]);
        }
        if( mm.max<top.max ) {
            aa.push([(top.max-mm.min)*h]);
        }
        aaa = Math.max(...aa); 
        if( aaa>area ) {
            area = aaa; 
        }
        if( mm.min<top.min ){
            top.min = mm.min; 
        }
        if( top.max<mm.max ){
            top.max = mm.max; 
        }
    }
    return area;
};
