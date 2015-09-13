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
		if ($[id] == null) $[id] = new Rx.ReplaySubject();
		
		return $[id];
	} catch (error) {}
}

function __updateCellStream(id, value) {
	try {
		$[id].onNext(value);
	} catch (error) {}
}