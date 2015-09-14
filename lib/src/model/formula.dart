part of dartsheet.model;

class Formula extends EventDispatcherImpl {
  
  @event Stream<FrameworkEvent<String>> onBodyChanged;
  @event Stream<FrameworkEvent<Cell>> onOriginatorChanged;
  
  static final RegExp _REGEXP_ID = new RegExp(r'\$[A-Z]+[\d]*');
  
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
        
    _REGEXP_ID.allMatches(_body).forEach((Match M) {
      final String id = M.group(0);
      
      String cellId = id.substring(1);
      
      argMap[id] = '\$.$cellId';
    });
    
    String rawScript = 'function __${appliesTo.id}() { try {${newLine}var onvalue = onvalue_${appliesTo.id}${newLine}var onvaluedown = onvaluedown_${appliesTo.id}${newLine}var oncss = oncss_${appliesTo.id}${newLine} $body${newLine}} catch (error) { console.log(error); } };';
    
    argMap.forEach((String K, String V) => rawScript = rawScript.replaceAll(K, V));
    
    jsf.value = rawScript;
    
    return jsf;
  }
  
  int toColIndex(String id) {
    final RegExp re = new RegExp(r'[A-Z]+');
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
    
    int offset = 0;
        
    _REGEXP_ID.allMatches(value).forEach((Match M) {
      final String id = M.group(0);
      
      String cellId = id.substring(1);
      
      int rowIndex = toRowIndex(cellId);
      int colIndex = toColIndex(cellId);
      
      final String localCellId = (rowIndex < 0) ? cellId : toCellIdentity(rowIndex + appliesTo.rowIndex - _originator.rowIndex, colIndex + appliesTo.colIndex - _originator.colIndex);
      
      value = value.substring(0, M.start + offset) + '\$' + localCellId + value.substring(M.end + offset);
      
      offset += localCellId.length - cellId.length;
    });
    
    return value;
  }
}

class JsFunctionBody {
  
  final List<dynamic> arguments;
  
  String value;
  
  JsFunctionBody(dynamic cellOwnValue) : this.arguments = <dynamic>[cellOwnValue];
  
}