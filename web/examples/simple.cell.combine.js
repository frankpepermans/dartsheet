Rx.Observable.combineLatest($A1, $B1)
.bufferWithCount(2, 1)
.flatMapLatest(x => x)
.subscribe(x => onvalue(x))