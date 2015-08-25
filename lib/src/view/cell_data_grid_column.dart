part of dartsheet.view;

class CellDataGridColumn extends DataGridColumn {
  
  @override
  Cell getItemRendererData(Row<Cell> data, int index) => data.cells[index];
  
}