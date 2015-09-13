part of dartsheet.view;

class ValueEntry extends HGroup {
  
  @event Stream<FrameworkEvent<String>> onValueInput;
  @event Stream<FrameworkEvent<String>> onFocus;
  
  EditableText valueField;
  
  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------

  //---------------------------------
  // value
  //---------------------------------
  
  String _value = '';

  String get value => _value;
  set value(String value) {
    if (value != _value) {
      _value = value;

      invalidateProperties();
    }
  }
  
  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  ValueEntry() : super() {
    className = 'value-entry';
  }
  
  @override
  void createChildren() {
    super.createChildren();
    
    valueField = new EditableText()
      ..className = 'value-field'
      ..percentWidth = 100.0
      ..percentHeight = 100.0;
    
    addComponent(valueField);
  }
  
  @override
  void commitProperties() {
    super.commitProperties();
    
    if (valueField != null) {
      valueField.text = _value;
    }
  }
}