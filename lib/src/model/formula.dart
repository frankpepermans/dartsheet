part of dartsheet.model;

class Formula extends EventDispatcherImpl {
  
  @event Stream<FrameworkEvent<String>> onBodyChanged;
  @event Stream<FrameworkEvent<Cell>> onOriginatorChanged;
  @event Stream<FrameworkEvent<bool>> onValidationChanged;
  
  final Cell appliesTo;
  
  final List<JsObject> subscriptions = <JsObject>[];
  
  String _body;
  
  String get body => _body;
  void set body(String value) {
    if (value != _body) {
      _body = _localize(value);
      
      notify('bodyChanged', value);
    }
  }
  
  Cell _originator;
  
  Cell get originator => _originator;
  void set originator(Cell value) {
    if (value != _originator) {
      _originator = value;
      
      notify('originatorChanged', value);
    }
  }
  
  bool _isValid = true;
  
  bool get isValid => _isValid;
  void set isValid(bool value) {
    if (value != _isValid) {
      _isValid = value;
      
      notify('validationChanged', value);
    }
  }
  
  Formula(this.appliesTo);
  
  factory Formula.from(Formula formula, Cell appliesTo) {
      final Formula F = new Formula(appliesTo);
      
      F._originator = formula.originator;
      F._body = formula.body;
      
      return F;
    }
  
  JsFunctionBody getJavaScriptFunctionBody(ObservableList<Row<Cell>> dataProvider, List<StreamSubscription> streamManager) {
    if (_body == null) return null;
    
    final JsFunctionBody jsf = new JsFunctionBody(appliesTo.value);
    final Map<String, String> argMap = <String, String>{};
    final String newLine = new String.fromCharCode(13);
    
    String rawScript = 'function __${appliesTo.id}() { try {${newLine}var onvalue = onvalue_${appliesTo.id}${newLine}var onvaluedown = onvaluedown_${appliesTo.id}${newLine}var oncss = oncss_${appliesTo.id}${newLine} $body${newLine}} catch (error) { console.log(error); return false; } return true; };';
    
    argMap.forEach((String K, String V) => rawScript = rawScript.replaceAll(K, V));
    
    jsf.value = rawScript;
    
    return jsf;
  }
  
  int toColIndex(String id) {
    final RegExp re = new RegExp(r'[A-Z]+', caseSensitive:false);
    final Match match = re.firstMatch(id);
    
    if (match != null) {
      final String colPart = re.firstMatch(id).group(0);
      
      if (colPart.length == 1) return colPart.codeUnitAt(0) - 65;
      else return ((colPart.codeUnitAt(0) - 64) * 26) + colPart.codeUnitAt(1) - 65;
    }
    
    return -1;
  }
  
  int toRowIndex(String id) {
    final RegExp re = new RegExp(r'[\d]+');
    final Match match = re.firstMatch(id);
    
    if (match != null) return int.parse(re.firstMatch(id).group(0)) - 1;
    
    return -1;
  }
  
  void cancelSubscription() {
    try {
      subscriptions.forEach((JsObject S) => S.callMethod('dispose', []));
    } catch (error) {}
    
    subscriptions.clear();
  }
  
  bool isEmpty() => (_body == null || _body.trim().isEmpty);
  
  String _localize(String value) {
    if (value == null) return null;
    
    final Selector S = new Selector();
    
    return value.replaceAllMapped(new RegExp(r"Select\([']{0,1}([A-Z,:\s\d]+)[']{0,1}\)", multiLine:true, caseSensitive:false), (Match M) =>
      'Select(\'${S.transformCellSelector(M.group(1), appliesTo.rowIndex - _originator.rowIndex, appliesTo.colIndex - _originator.colIndex)}\')'
    );
  }
}

class JsFunctionBody {
  
  final List<dynamic> arguments;
  
  String value;
  
  JsFunctionBody(dynamic cellOwnValue) : this.arguments = <dynamic>[cellOwnValue];
  
}