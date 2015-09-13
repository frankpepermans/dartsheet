Rx.Observable.timer(0, 250)
.flatMapLatest(x => Rx.Observable.from([x]))
.subscribe(x => onvaluedown(x))