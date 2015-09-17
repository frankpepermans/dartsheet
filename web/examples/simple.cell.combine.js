Rx.Observable.combineLatest(Cell(A, 1), Cell(B, 1))
.bufferWithCount(1)
.subscribe(x => onvalue(x[0][0] + ' and ' + x[0][1]))