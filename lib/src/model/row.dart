part of dartsheet.model;

class Row<E extends Cell<dynamic>> extends EventDispatcherImpl {
  
  final int rowIndex;
  final ObservableList<E> cells = new ObservableList<E>();
  
  Row(this.rowIndex);
  
}