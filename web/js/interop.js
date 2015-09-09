var $ = {};

function __createCellStream(id) {
	try {
		if ($[id] == null) $[id] = new Rx.Subject();
		
		return $[id];
	} catch (error) {}
}

function __updateCellStream(id, value) {
	try {
		$[id].onNext(value);
	} catch (error) {}
}