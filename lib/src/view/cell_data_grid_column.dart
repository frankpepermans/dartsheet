part of dartsheet.view;

class CellDataGridColumn extends DataGridColumn {
  
  @override
  ObservableList<Cell<dynamic>> getItemRendererData(Row<Cell<dynamic>> data) => data.cells;
  
}