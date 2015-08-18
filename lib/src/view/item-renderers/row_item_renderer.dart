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
  
  final Stream<int> rowOffset;
  
  Button button;

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
  void invalidateData() {}
  
  void _update(int currentRowOffset) {
    if (data != null && button != null) button.label = (data.rowIndex + currentRowOffset + 1).toString();
  }
}