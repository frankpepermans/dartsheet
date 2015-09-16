var $ = {};

Rx.Observable.prototype.__subscribe = function(cellId, oOrOnNext, onError, onCompleted) {
  var s = this._subscribe(typeof oOrOnNext === 'object' ?
        oOrOnNext :
        Rx.Observer.create(oOrOnNext, onError, onCompleted));
        
  __registerNewRxSubscription(cellId, s);
  
  return s;
}

function __createCellStream(id) {
	try {
		if ($[id] == null) $[id] = new Rx.ReplaySubject(1);
		
		return $[id];
	} catch (error) {}
}

function __updateCellStream(id, value) {
	try {
		$[id].onNext(value);
	} catch (error) {}
}

function __getMergedStream() {
	var list = [];
	
	if (arguments.length == 0) return null;
	if (arguments.length == 1) return $[arguments[0]];
	
	for (var i=0, len=arguments.length; i<len; i++) list.push($[arguments[i]]);
	
	return Rx.Observable.merge(list).shareReplay(1);
}