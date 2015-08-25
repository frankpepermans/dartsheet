part of dartsheet.model;

class Formula extends EventDispatcherImpl {
  
  @event Stream<FrameworkEvent<String>> onBodyChanged;
  @event Stream<FrameworkEvent<Cell<dynamic>>> onOriginatorChanged;
  
  final Cell<dynamic> appliesTo;
  
  String _body;
  
  String get body => _body;
  void set body(String value) {
    if (value != _body) {
      _body = _localize(value);
      
      notify(new FrameworkEvent<String>('bodyChanged', relatedObject: value));
    }
  }
  
  Cell<dynamic> _originator;
  
  Cell<dynamic> get originator => _originator;
  void set originator(Cell<dynamic> value) {
    if (value != _originator) {
      _originator = value;
      
      notify(new FrameworkEvent<Cell<dynamic>>('originatorChanged', relatedObject: value));
    }
  }
  
  Formula(this.appliesTo);
  
  JsFunctionBody getJavaScriptFunctionBody(ObservableList<Row<Cell<dynamic>>> dataProvider, List<StreamSubscription> streamManager, void streamHandler(Formula formula)) {
    if (_body == null) return null;
    
    final RegExp re = new RegExp(r'#[A-Z]+[\d]+');
    final List<String> args = <String>['cellValue'];
    final JsFunctionBody jsf = new JsFunctionBody(appliesTo.value);
    final Map<String, String> argMap = <String, String>{};
    int nextCharCode = 0;
        
    re.allMatches(_body).forEach((Match M) {
      final String id = M.group(0);
      
      String cellId = id.substring(1);
      
      argMap[id] = '__arg${nextCharCode++}';
      
      args.add(argMap[id]);
      
      int rowIndex = toRowIndex(cellId);
      
      if (rowIndex >= 0) {
        final Row<Cell<dynamic>> row = dataProvider[rowIndex];
        
        for (int j=0, cells=row.cells.length; j<cells; j++) {
          Cell<dynamic> dpCell = row.cells[j];
          
          if (dpCell.id == cellId) {
            if (dpCell.value == null) jsf.arguments.add(null);
            else if (!num.parse(dpCell.value, (_) => double.NAN).isNaN) jsf.arguments.add(num.parse(dpCell.value));
            else jsf.arguments.add(dpCell.value);
            
            if (dpCell.id != id) streamManager.add(dpCell.onValueChanged.listen((_) => streamHandler(this)));
            
            break;
          }
        }
      }
    });
    
    String rawScript = 'function __${appliesTo.id}(${args.join(",")}) { try { ${body} } catch (error) { return null; } }';
    
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
  
  String _localize(String value) {
    if (value == null) return null;
    
    final RegExp re = new RegExp(r'#[A-Z]+[\d]+');
    int offset = 0;
        
    re.allMatches(value).forEach((Match M) {
      final String id = M.group(0);
      
      String cellId = id.substring(1);
      
      int rowIndex = toRowIndex(cellId);
      int colIndex = toColIndex(cellId);
      
      final String localCellId = toCellIdentity(rowIndex + appliesTo.rowIndex - _originator.rowIndex, colIndex + appliesTo.colIndex - _originator.colIndex);
      
      value = value.substring(0, M.start + offset) + '#' + localCellId + value.substring(M.end + offset);
      
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