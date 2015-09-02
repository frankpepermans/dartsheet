part of dartsheet.model;

class Cell<V> extends EventDispatcherImpl {
  
  @event Stream<FrameworkEvent<V>> onValueChanged;
  @event Stream<FrameworkEvent<bool>> onSelectionChanged;
  @event Stream<FrameworkEvent<bool>> onFocusChanged;
  
  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  final String id;
  final int globalIndex, rowIndex, colIndex;
  final List<StreamSubscription> siblingSubscriptions = <StreamSubscription>[];
  
  ScriptElement scriptElement;
  
  //---------------------------------
  // value
  //---------------------------------
  
  V _value;
  
  V get value => _value;
  void set value(V newValue) {
    if (newValue != value) {
      _value = newValue;
      
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
  //
  // Constructor
  //
  //---------------------------------
  
  Cell(this.id, this.globalIndex, this.rowIndex, this.colIndex, [V initialValue]) {
    _formula = new Formula(this);
    
    value = initialValue;
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
    await siblingSubscriptions.forEach((StreamSubscription S) async => await S.cancel());
        
    siblingSubscriptions.clear();
  }
}