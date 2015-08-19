part of dartsheet.model;

class Cell<V> extends EventDispatcherImpl {
  
  @event Stream<FrameworkEvent<V>> onValueChanged;
  @event Stream<FrameworkEvent<String>> onFormulaChanged;
  @event Stream<FrameworkEvent<bool>> onSelectionChanged;
  
  final String id;
  final int rowIndex, colIndex;
  
  ScriptElement scriptElement;
  
  V _value;
  
  V get value => _value;
  void set value(V newValue) {
    if (newValue != value) {
      _value = newValue;
      
      notify(new FrameworkEvent<V>('valueChanged', relatedObject: newValue));
    }
  }
  
  String _formula;
  
  String get formula => _formula;
  void set formula(String value) {
    if (value != _formula) {
      _formula = value;
      
      notify(new FrameworkEvent<String>('formulaChanged', relatedObject: value));
    }
  }
  
  //---------------------------------
  // selected
  //---------------------------------
  
  bool _selected = false;
  
  bool get selected => _selected;
  set selected(bool value) {
    if (value != _selected) {
      _selected = value;
      
      notify(
          new FrameworkEvent<bool>('selectionChanged', relatedObject: value)    
      );
    }
  }
  
  Cell(this.id, this.rowIndex, this.colIndex, [V initialValue]) {
    value = initialValue;
  }
  
  JsFunctionBody getJavaScriptFunctionBody(ObservableList<Row<Cell<dynamic>>> dataProvider, List<StreamSubscription> streamManager, void streamHandler(Cell<V> cell)) {
    final RegExp re = new RegExp(r'#[A-Z]+[\d]+');
    final List<String> args = <String>['cellValue'];
    final JsFunctionBody jsf = new JsFunctionBody(_value);
    final Map<String, String> argMap = <String, String>{};
    int nextCharCode = 0;
        
    re.allMatches(_formula).forEach((Match M) {
      final String id = M.group(0);
      final String cellId = id.substring(1);
      
      argMap[id] = '__arg${nextCharCode++}';
      
      args.add(argMap[id]);
      
      final int rowIndex = toRowIndex(cellId);
      
      if (rowIndex >= 0) {
        final Row<Cell<dynamic>> row = dataProvider[rowIndex];
        
        for (int j=0, cells=row.length; j<cells; j++) {
          Cell<dynamic> dpCell = row[j];
          
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
    
    String rawScript = 'function __${id}(${args.join(",")}) { try { ${_formula} } catch (error) { return null; } }';
    
    argMap.forEach((String K, String V) => rawScript = rawScript.replaceAll(K, V));
    
    jsf.value = rawScript;
    
    return jsf;
  }
  
  int toRowIndex(String id) {
    final RegExp re = new RegExp(r'[\d]+');
    final Match match = re.firstMatch(id);
    
    if (match != null) return int.parse(re.firstMatch(id).group(0)) - 1;
    
    return -1;
  }
}

class JsFunctionBody {
  
  final List<dynamic> arguments;
  
  String value;
  
  JsFunctionBody(dynamic cellOwnValue) : this.arguments = <dynamic>[cellOwnValue];
  
}