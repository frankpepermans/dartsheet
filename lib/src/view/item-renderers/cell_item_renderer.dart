part of dartsheet.view;

class CellItemRenderer<D extends Cell<String>> extends EditableLabelItemRenderer<Cell<String>> {

  //---------------------------------
  //
  // Protected properties
  //
  //---------------------------------
  
  List<StreamSubscription> _cellValueSubscribtions = <StreamSubscription>[];

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  //---------------------------------
  // data
  //---------------------------------
  
  @override
  set data(D value) {
    streamSubscriptionManager.flushIdent('value-listener');
    streamSubscriptionManager.flushIdent('formula-listener');
    
    super.data = value;
    
    streamSubscriptionManager.add('value-listener', value.onValueChanged.listen((_) => invalidateData()));
    streamSubscriptionManager.add('formula-listener', value.onFormulaChanged.listen((FrameworkEvent<String> event) => invalidateFormula(event.currentTarget as Cell<String>)));
  }

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  CellItemRenderer() : super();

  static CellItemRenderer construct() => new CellItemRenderer();

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  @override
  String itemToLabel() {
    if (data != null) return data.value;
    
    return '';
  }
  
  void invalidateFormula(Cell<String> cell) {
    final DataGridItemRenderer parentContainer = owner as DataGridItemRenderer;
    final RegExp re = new RegExp(r'#[A-Z]+[\d]+');
    final List<String> args = <String>['cellValue'];
    final List<dynamic> values = <dynamic>[cell.value];
    final ObservableList<Row<Cell<dynamic>>> dataProvider = parentContainer.grid.dataProvider;
    
    if (cell.scriptElement != null) cell.scriptElement.remove();
    
    cell.scriptElement = new ScriptElement();
    
    _cellValueSubscribtions.forEach((StreamSubscription S) => S.cancel());
    
    _cellValueSubscribtions.clear();
    
    re.allMatches(cell.formula).forEach((Match M) {
      final String id = M.group(0);
      final String cellId = id.substring(1);
      
      args.add(id);
      
      final int rowIndex = toRowIndex(cellId);
      
      if (rowIndex >= 0) {
        final Row<Cell<dynamic>> row = dataProvider[rowIndex];
        
        for (int j=0, cells=row.length; j<cells; j++) {
          Cell<dynamic> dpCell = row[j];
          
          if (dpCell.id == cellId) {
            if (dpCell.value == null) values.add(null);
            else if (!num.parse(dpCell.value, (_) => double.NAN).isNaN) values.add(num.parse(dpCell.value));
            else values.add(dpCell.value);
            
            _cellValueSubscribtions.add(dpCell.onValueChanged.listen((_) => invalidateFormula(cell)));
            
            break;
          }
        }
      }
    });
    
    final String rawScript = 'function _inner_cell_method_${cell.id}(${args.join(",")}) { try { ${cell.formula} } catch (error) { return undefined; } }';
    
    cell.scriptElement.innerHtml = rawScript.replaceAll('#', '');
    
    document.head.append(cell.scriptElement);
    
    try {
      cell.value = context.callMethod('_inner_cell_method_${cell.id}', values).toString();
    } catch (error) {
      cell.value = null;
    }
  }
  
  int toRowIndex(String id) {
    final RegExp re = new RegExp(r'[\d]+');
    final Match match = re.firstMatch(id);
    
    if (match != null) return int.parse(re.firstMatch(id).group(0)) - 1;
    
    return -1;
  }
  
  @override
  void textArea_onTextChangedHandler(FrameworkEvent Event) {
    if (
        (data != null) &&
        (field != null)
    ) data.value = textArea.text;
  }
}