part of dartsheet.view;

class RowItemRenderer<D extends Row<Cell>> extends ItemRenderer<Row<Cell>> {

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
  
  Button button;
  
  //---------------------------------
  // data
  //---------------------------------
  
  @override
  set data(D value) {
    streamSubscriptionManager.flushIdent('highlight-listener');
    
    super.data = value;
    
    if (value != null) {
      streamSubscriptionManager.add('highlight-listener', value.onHighlightedChanged.listen((_) => invalidateData()));
    }
  }

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  RowItemRenderer() : super();

  static RowItemRenderer construct() => new RowItemRenderer();

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
    if ( button != null) {
      if (data != null) {
        button.label = (data.rowIndex + 1).toString();
        
        button.cssClasses = data.highlighted ? const <String>['row-highlighted'] : null;
      } else {
        button.label = '';
        
        button.cssClasses = null;
      }
    }
  }
} 