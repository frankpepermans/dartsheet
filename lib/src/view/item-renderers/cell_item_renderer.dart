part of dartsheet.view;

class CellItemRenderer<D extends Cell<String>> extends EditableLabelItemRenderer<Cell<String>> {

  //---------------------------------
  //
  // Protected properties
  //
  //---------------------------------
  
  List<StreamSubscription> _siblingSubscriptions = <StreamSubscription>[];

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
    streamSubscriptionManager.flushIdent('selection-listener');
    
    super.data = value;
    
    if (value != null) {
      streamSubscriptionManager.add('value-listener', value.onValueChanged.listen((_) => invalidateData()));
      streamSubscriptionManager.add('formula-listener', value.onFormulaChanged.listen((FrameworkEvent<String> event) => invalidateFormula(event.currentTarget as Cell<String>)));
      streamSubscriptionManager.add('selection-listener', value.onSelectionChanged.listen((_) => _invalidateSelection()));
    }
    
    _invalidateSelection();
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
  
  Future invalidateFormula(Cell<String> cell) async {
    await _clearSiblingSubscriptions();
    
    final DataGridItemRenderer parentContainer = owner as DataGridItemRenderer;
    final JsFunctionBody jsf = cell.getJavaScriptFunctionBody(parentContainer.grid.dataProvider, _siblingSubscriptions, invalidateFormula);
    
    if (cell.scriptElement != null) cell.scriptElement.remove();
    
    try {
      cell.scriptElement = new ScriptElement()..innerHtml = jsf.value;
      
      document.head.append(cell.scriptElement);
      
      cell.value = context.callMethod('__${cell.id}', jsf.arguments).toString();
    } catch (error) {
      cell.value = null;
    }
  }
  
  @override
  void textArea_onTextChangedHandler(FrameworkEvent Event) {
    if (
        (data != null) &&
        (field != null)
    ) data.value = textArea.text;
  }
  
  Future _clearSiblingSubscriptions() async {
    await _siblingSubscriptions.forEach((StreamSubscription S) async => await S.cancel());
        
    _siblingSubscriptions.clear();
  }
  
  void _invalidateSelection() {
    cssClasses = (data != null && data.selected) ? const <String>['cell-selected'] : null;
  }
}