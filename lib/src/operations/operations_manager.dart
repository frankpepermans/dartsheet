part of dartsheet.operations;

class OperationsManager {
  
  final WorkSheet worksheet;
  
  List<Cell> _selectionSnapshot;
  
  OperationsManager(this.worksheet) {
    document.onCopy.listen(_document_copyHandler);
    document.onPaste.listen(_document_pasteHandler);
  }
  
  void _document_copyHandler(Event event) {
    _selectionSnapshot = new List<Cell>.generate(worksheet.selectedCells.length, (int i) => new Cell.fromOtherCell(worksheet.selectedCells[i]));
  }
  
  void _document_pasteHandler(Event event) {
    final Cell startCell = _selectionSnapshot.first;
    final Cell offsetCell = worksheet.selectedCells.first;
    final int dx = offsetCell.colIndex - startCell.colIndex;
    final int dy = offsetCell.rowIndex - startCell.rowIndex;
    
    for (int i=0, len=_selectionSnapshot.length; i<len; i++) {
      Cell currCell = _selectionSnapshot[i];
      Cell tmpCell = worksheet.getCell(currCell.rowIndex + dy, currCell.colIndex + dx);
      
      tmpCell.copyFrom(currCell);
    }
  }
}