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
    _selectionSnapshot.forEach((Cell cell) => print(cell.value));
  }
}