part of dartsheet.view;

class CellItemRenderer<D extends Cell<String>> extends EditableLabelItemRenderer<Cell<String>> {
  
  @event Stream<FrameworkEvent<Cell>> onSelectionDrag;

  //---------------------------------
  //
  // Protected properties
  //
  //---------------------------------
  
  CssStyleDeclaration _defaultStyle;

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  Group selectionDragTarget;
  
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
    streamSubscriptionManager.flushIdent('style-listener');
    
    super.data = value;
    
    if (value != null) {
      streamSubscriptionManager.add('value-listener', value.onValueChanged.listen((_) => invalidateData()));
      streamSubscriptionManager.add('selection-listener', value.onSelectionChanged.listen((_) => invokeLaterSingle('invalidateSelection', _invalidateSelection)));
      streamSubscriptionManager.add('selection-outline-listener', value.onSelectionOutlineChanged.listen((_) => invokeLaterSingle('invalidateSelection', _invalidateSelection)));
      streamSubscriptionManager.add('focus-listener', value.onFocusChanged.listen((_) => invokeLaterSingle('invalidateSelection', _invalidateSelection)));
      streamSubscriptionManager.add('style-listener', value.onStyleChanged.listen((_) => invokeLaterSingle('invalidateStyle', _invalidateStyle)));
    }
    
    _invalidateSelection();
    _invalidateStyle();
  }

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  CellItemRenderer() : super() {
    className = 'cell-item-renderer';
  }

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
  void updateLayout() {
    super.updateLayout();
    
    if (selectionDragTarget != null) {
      selectionDragTarget.x = width - 10;
      selectionDragTarget.y = height - 10;
    }
  }
  
  @override
  void textArea_onTextChangedHandler(FrameworkEvent Event) {
    if (data != null) data.value = textArea.text;
  }
  
  void _addSelectionDragHandler() {
    if (selectionDragTarget == null) {
      selectionDragTarget = new Group()
        ..width = 10
        ..height = 10
        ..className = 'cell-item-renderer-selection-drag-target'
        ..includeInLayout = false
        ..onControlChanged.listen((FrameworkEvent<Element> event) {
          event.relatedObject.onMouseDown.listen(_activateSelectionDrag);
        });
    }
    
    addComponent(selectionDragTarget);
  }
  
  void _removeSelectionDragHandler() {
    if (selectionDragTarget == null) return;
    
    if (selectionDragTarget.owner != null) removeComponent(selectionDragTarget, flush: false);
  }
  
  void _invalidateSelection() {
    if (data != null) {
      List<String> cssSelection = const <String>[];
      List<String> cssOutline = <String>[];
      
      if (data.focused) cssSelection = const <String>['cell-selected', 'focused'];
      else if (data.selected) cssSelection = const <String>['cell-selected'];
      else cssSelection = const <String>[];
      
      if (data.selectionOutline & 1 > 0 || data.selectionLockOutline & 1 > 0) cssOutline.add('cell-outline-top');
      if (data.selectionOutline & 2 > 0 || data.selectionLockOutline & 2 > 0) cssOutline.add('cell-outline-left');
      if (data.selectionOutline & 4 > 0 || data.selectionLockOutline & 4 > 0) cssOutline.add('cell-outline-bottom');
      if (data.selectionOutline & 8 > 0 || data.selectionLockOutline & 8 > 0) cssOutline.add('cell-outline-right');
      
      data.isSelectionDragTargetShown ? _addSelectionDragHandler() : _removeSelectionDragHandler();
      
      cssClasses = new List<String>()..addAll(cssSelection)..addAll(cssOutline);
      
      invalidateLayout(true);
    }
  }
  
  void _invalidateStyle() {
    if (textArea == null) return;
    
    if (data != null && data.style != null) {
      final Iterable<String> keys = context['Object'].callMethod('keys', [data.style]);
      
      if (_defaultStyle == null) _defaultStyle = new CssStyleDeclaration.css(textArea.control.style.cssText);
      
      try {
        keys.forEach((String K) => textArea.control.style.setProperty(K, data.style[K]));
      } catch (error) {}
    } else if (_defaultStyle != null) {
      textArea.control.style.cssText = _defaultStyle.cssText;
    }
  }
  
  void _activateSelectionDrag(MouseEvent event) {
    event.preventDefault();
    
    event.stopImmediatePropagation();
    
    notify('selectionDrag', this);
  }
}