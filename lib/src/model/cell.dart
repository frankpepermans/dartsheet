part of dartsheet.model;

class Cell<V> extends EventDispatcherImpl {
  
  @event Stream<FrameworkEvent> onValueChanged;
  @event Stream<FrameworkEvent> onFormulaChanged;
  
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
  
  Cell(this.id, this.rowIndex, this.colIndex, [V initialValue]) {
    value = initialValue;
  }
  
}