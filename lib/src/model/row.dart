part of dartsheet.model;

class Row<E extends Cell> extends EventDispatcherImpl {
  
  @event Stream<FrameworkEvent<bool>> onHighlightedChanged;
  
  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  final int rowIndex;
  final ObservableList<E> cells = new ObservableList<E>();
  
  //---------------------------------
  // highlighted
  //---------------------------------
  
  bool _highlighted = false;
  
  bool get highlighted => _highlighted;
  set highlighted(bool value) {
    if (value != _highlighted) {
      _highlighted = value;
      
      notify('highlightedChanged', value);
    }
  }
  
  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------
  
  Row(this.rowIndex);
  
}