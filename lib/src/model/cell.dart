part of dartsheet.model;

class Cell<V> extends EventDispatcherImpl {
  
  @event Stream<FrameworkEvent<V>> onValueChanged;
  @event Stream<FrameworkEvent<bool>> onSelectionChanged;
  @event Stream<FrameworkEvent<int>> onSelectionOutlineChanged;
  @event Stream<FrameworkEvent<int>> onSelectionLockOutlineChanged;
  @event Stream<FrameworkEvent<bool>> onFocusChanged;
  @event Stream<FrameworkEvent<int>> onIsSelectionDragTargetShownChanged;
  @event Stream<FrameworkEvent<JsObject>> onStyleChanged;
  
  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  final String id;
  final int globalIndex, rowIndex, colIndex;
  final List<StreamSubscription> siblingSubscriptions = <StreamSubscription>[];
  
  ScriptElement scriptElement;
  JsObject cell$;
  
  //---------------------------------
  // value
  //---------------------------------
  
  V _value;
  
  V get value => _value;
  void set value(V newValue) {
    if (newValue != value) {
      _value = newValue;
      
      //cell$.callMethod('onNext', [newValue]);
      final String cellId = new String.fromCharCode(colIndex + 65);
      
      context.callMethod('__updateCellStream', [id, newValue]);
      context.callMethod('__updateCellStream', [cellId, newValue]);
      context.callMethod('__updateCellStream', ['R${rowIndex + 1}', newValue]);
      
      notify(new FrameworkEvent<V>('valueChanged', relatedObject: newValue));
    }
  }
  
  Formula _formula;
  
  Formula get formula => _formula;
  
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
  
  //---------------------------------
  // selectionOutline
  //---------------------------------
  
  int _selectionOutline = 0;
  
  int get selectionOutline => _selectionOutline;
  set selectionOutline(int value) {
    if (value != _selectionOutline) {
      _selectionOutline = value;
      
      notify(
          new FrameworkEvent<int>('selectionOutlineChanged', relatedObject: value)    
      );
    }
  }
  
  //---------------------------------
  // selectionLockOutline
  //---------------------------------
  
  int _selectionLockOutline = 0;
  
  int get selectionLockOutline => _selectionLockOutline;
  set selectionLockOutline(int value) {
    if (value != _selectionLockOutline) {
      _selectionLockOutline = value;
      
      notify(
          new FrameworkEvent<int>('selectionLockOutlineChanged', relatedObject: value)    
      );
    }
  }
  
  //---------------------------------
  // isSelectionDragTargetShown
  //---------------------------------
  
  bool _isSelectionDragTargetShown = false;
  
  bool get isSelectionDragTargetShown => _isSelectionDragTargetShown;
  set isSelectionDragTargetShown(bool value) {
    if (value != _isSelectionDragTargetShown) {
      _isSelectionDragTargetShown = value;
      
      notify(
          new FrameworkEvent<bool>('isSelectionDragTargetShownChanged', relatedObject: value)    
      );
    }
  }
  
  //---------------------------------
  // focused
  //---------------------------------
  
  bool _focused = false;
  
  bool get focused => _focused;
  set focused(bool value) {
    if (value != _focused) {
      _focused = value;
      
      notify(
          new FrameworkEvent<bool>('focusChanged', relatedObject: value)    
      );
    }
  }
  
  //---------------------------------
  // style
  //---------------------------------
  
  JsObject _style;
  
  JsObject get style => _style;
  set style(JsObject value) {
    if (value != _style) {
      _style = value;
      
      notify(
          new FrameworkEvent<JsObject>('styleChanged', relatedObject: value)    
      );
    }
  }
  
  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------
  
  Cell(this.id, this.globalIndex, this.rowIndex, this.colIndex, [V initialValue]) {
    _formula = new Formula(this);
    
    value = initialValue;
    
    cell$ = context.callMethod('__createCellStream', [id]);
    //new JsObject(context['Rx']['Subject'], []);
  }
  
  factory Cell.fromOtherCell(Cell cell) {
    final Cell newCell = new Cell(cell.id, cell.globalIndex, cell.rowIndex, cell.colIndex, cell.value);
    
    newCell._formula = new Formula.from(cell.formula, newCell);
    
    return newCell;
  }
  
  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------
  
  void copyFrom(Cell otherCell, Cell originator, String formulaBody) {
    _formula.originator = originator;
    
    value = otherCell.value;
    
    _formula.body = formulaBody;
  }
  
  Future clearSiblingSubscriptions() async {
    await siblingSubscriptions.forEach((StreamSubscription S) async => await _cancelSubscription(S));
        
    siblingSubscriptions.clear();
  }
  
  Future _cancelSubscription(StreamSubscription S) {
    Future F;
    
    try {
      F = S.cancel();
    } catch (error) {}
    
    return F;
  }
}