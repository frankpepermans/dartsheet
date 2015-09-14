$A1.flatMapLatest((stockName) => 	  
   Rx.Observable.timer(0, 1000)
   .flatMapLatest(  _ => Rx.Observable.from(['select Symbol,LastTradePriceOnly from yahoo.finance.quotes where symbol in ("' + stockName + '")']))
   .flatMapLatest(yql => Rx.Observable.from(['https://query.yahooapis.com/v1/public/yql?q=' + yql + '&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys&callback=']))
   .flatMapLatest(url => Rx.DOM.ajax({url: url, responseType: 'json', crossDomain: true}))
   .pluck('response', 'query', 'results', 'quote', 'LastTradePriceOnly')
   .bufferWithCount(2, 1)
   .retry()
).subscribe(function (n) {
   oncss({'background-color': (n[0] > n[1]) ? '#cfc' : (n[0] < n[1]) ? '#fcc' : '#fff'})
   onvalue(n[1])
}, err => onvalue('-'))