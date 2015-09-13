$A
.flatMapLatest(x => Rx.Observable.from([x]))
.subscribe(x => onvalue(x))