part of dartsheet.view;

class RowItemRenderer<D extends Row<Cell<dynamic>>> extends ItemRenderer<Row<Cell<dynamic>>> {
  
  @event Stream<FrameworkEvent> onHighlightedChanged;

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
  
  final Stream<int> rowOffset;
  
  Button button;
  
  //---------------------------------
  // highlighted
  //---------------------------------
  
  bool _highlighted = false;
  
  bool get highlighted => _highlighted;
  void set highlighted(bool value) {
    if (value != _highlighted) {
      _highlighted = value;
      
      invalidateData();
      
      notify(new FrameworkEvent<bool>('highlightedChanged', relatedObject: value));
    }
  }
  
  //---------------------------------
  // data
  //---------------------------------
  
  void set data(D value) {
    super.data = value;
    
    rowOffset.last.then(_update);
  }

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  RowItemRenderer(this.rowOffset) : super() {
    rowOffset.listen(_update);
  }

  static RowItemRenderer construct(Stream<int> rowOffset) => new RowItemRenderer(rowOffset);

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  @override
  void createChildren() {
    super.createChildren();
    
    button = new Button()
      ..percentWidth = 100.0
      ..percentHeight = 100.0;
    
    addComponent(button);
  }
  
  @override
  void invalidateData() {
    rowOffset.last.then(_update);
    
    cssClasses = _highlighted ? const <String>['row-highlighted'] : null;
  }
  
  void _update(int currentRowOffset) {
    if (data != null && button != null) button.label = (data.rowIndex + currentRowOffset + 1).toString();
  }
}