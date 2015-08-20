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
    streamSubscriptionManager.flushIdent('focus-listener');
    
    super.data = value;
    
    if (value != null) {
      streamSubscriptionManager.add('value-listener', value.onValueChanged.listen((_) => invalidateData()));
      streamSubscriptionManager.add('formula-listener', value.formula.onBodyChanged.listen((FrameworkEvent<String> event) => invalidateFormula(event.currentTarget as Formula)));
      streamSubscriptionManager.add('selection-listener', value.onSelectionChanged.listen((_) => invokeLaterSingle('invalidateSelection', _invalidateSelection)));
      streamSubscriptionManager.add('focus-listener', value.onFocusChanged.listen((_) => invokeLaterSingle('invalidateSelection', _invalidateSelection)));
    }
    
    invokeLaterSingle('invalidateSelection', _invalidateSelection);
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
  
  Future invalidateFormula(Formula formula) async {
    await _clearSiblingSubscriptions();
    
    final DataGridItemRenderer parentContainer = owner as DataGridItemRenderer;
    final JsFunctionBody jsf = formula.getJavaScriptFunctionBody(parentContainer.grid.dataProvider, _siblingSubscriptions, invalidateFormula);
    
    if (formula.appliesTo.scriptElement != null) formula.appliesTo.scriptElement.remove();
    
    try {
      formula.appliesTo.scriptElement = new ScriptElement()..innerHtml = jsf.value;
      
      document.head.append(formula.appliesTo.scriptElement);
      
      formula.appliesTo.value = context.callMethod('__${formula.appliesTo.id}', jsf.arguments).toString();
    } catch (error) {
      formula.appliesTo.value = null;
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
    if (data != null) {
      if (data.focused) cssClasses = const <String>['cell-selected', 'focused'];
      else if (data.selected) cssClasses = const <String>['cell-selected'];
      else cssClasses = null;
    }
  }
}