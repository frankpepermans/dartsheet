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
  }
  
  void _update(int currentRowOffset) {
    final ColumnList columnList = owner as ColumnList;
    
    if (data != null && button != null) button.label = (data.rowIndex + currentRowOffset + 1).toString();
    
    cssClasses = (columnList != null && data != null && columnList.highlightRange.contains(data.rowIndex + currentRowOffset)) ? const <String>['row-highlighted'] : null;
  }
}