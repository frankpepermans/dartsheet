part of dartsheet.model;

class Row<E extends Cell<dynamic>> extends ObservableList<Cell<dynamic>> {
  
  final int rowIndex;
  
  Row(this.rowIndex);
  
}