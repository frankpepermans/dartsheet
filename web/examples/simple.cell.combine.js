Rx.Observable.combineLatest($A1, $B1)
.bufferWithCount(1)
.subscribe(x => onvalue(x[0][0] + ' and ' + x[0][1]))