part of dartsheet.view;

class RowItemRenderer<D extends Row<Cell<dynamic>>> extends ItemRenderer<Row<Cell<dynamic>>> {

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
    final ColumnList columnList = owner as ColumnList;
    
    if (data != null) {
      if ( button != null) {
        button.label = (data.rowIndex + columnList.currentRowOffset + 1).toString();
           
        button.cssClasses = (columnList != null && columnList.highlightRange.contains(data.rowIndex + columnList.currentRowOffset)) ? const <String>['row-highlighted'] : null;
      }
    } else {
      if ( button != null) {
        button.label = '';
        
        button.cssClasses = null;
      }
    }
  }
} 