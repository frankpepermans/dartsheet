part of dartsheet.view;

class CellItemRenderer<D extends Cell<String>> extends EditableLabelItemRenderer<Cell<String>> {

  //---------------------------------
  //
  // Protected properties
  //
  //---------------------------------

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
    streamSubscriptionManager.flushIdent('selection-outline-listener');
    streamSubscriptionManager.flushIdent('focus-listener');
    
    super.data = value;
    
    if (value != null) {
      streamSubscriptionManager.add('value-listener', value.onValueChanged.listen((_) => invalidateData()));
      streamSubscriptionManager.add('selection-listener', value.onSelectionChanged.listen((_) => invokeLaterSingle('invalidateSelection', _invalidateSelection)));
      streamSubscriptionManager.add('selection-outline-listener', value.onSelectionOutlineChanged.listen((_) => invokeLaterSingle('invalidateSelection', _invalidateSelection)));
      streamSubscriptionManager.add('focus-listener', value.onFocusChanged.listen((_) => invokeLaterSingle('invalidateSelection', _invalidateSelection)));
    }
    
    _invalidateSelection();//invokeLaterSingle('invalidateSelection', _invalidateSelection);
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
  
  @override
  void textArea_onTextChangedHandler(FrameworkEvent Event) {
    if (data != null) data.value = textArea.text;
  }
  
  void _invalidateSelection() {
    if (data != null) {
      List<String> cssSelection = const <String>[];
      List<String> cssOutline = <String>[];
      
      if (data.focused) cssSelection = const <String>['cell-selected', 'focused'];
      else if (data.selected) cssSelection = const <String>['cell-selected'];
      else cssSelection = const <String>[];
      
      if (data.selectionOutline & 1 > 0) cssOutline.add('cell-outline-top');
      if (data.selectionOutline & 2 > 0) cssOutline.add('cell-outline-left');
      if (data.selectionOutline & 4 > 0) cssOutline.add('cell-outline-bottom');
      if (data.selectionOutline & 8 > 0) cssOutline.add('cell-outline-right');
      
      cssClasses = new List<String>()..addAll(cssSelection)..addAll(cssOutline);
    }
  }
}