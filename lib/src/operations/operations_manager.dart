part of dartsheet.operations;

class OperationsManager {
  
  final WorkSheet worksheet;
  final List<StreamSubscription> _subscriptions = <StreamSubscription>[];
  
  List<Cell> _selectionSnapshot;
  
  OperationsManager(this.worksheet);
  
  void start() {
    if (_subscriptions.isNotEmpty) return;
    
    _subscriptions.add(document.onCopy.listen(_document_copyHandler));
    _subscriptions.add(document.onPaste.listen(_document_pasteHandler));
    
    _subscriptions.add(window.onKeyDown.listen((KeyboardEvent event) {
      switch (event.keyCode) {
        case KeyCode.UP : case KeyCode.DOWN : case KeyCode.LEFT : case KeyCode.RIGHT :
          final Element activeElement = document.activeElement;
          
          event.preventDefault();
          
          worksheet.spreadsheet.list.itemRenderers.forEach((DataGridItemRenderer IR) {
            IR.itemRendererInstances.forEach((CellItemRenderer<Cell> cellIR) {
              if (cellIR.textArea.control == activeElement) {
                switch (event.keyCode) {
                  case KeyCode.UP :     worksheet.focusCellSibling(cellIR, -1, 0);  break;
                  case KeyCode.DOWN :   worksheet.focusCellSibling(cellIR, 1, 0);   break;
                  case KeyCode.LEFT :   worksheet.focusCellSibling(cellIR, 0, -1);  break;
                  case KeyCode.RIGHT :  worksheet.focusCellSibling(cellIR, 0, 1);   break;
                }
              }
            });
          });
          
          break;
        case KeyCode.S :
          if (event.ctrlKey) {
            event.preventDefault();
            
            worksheet.saveToFile();
          }
          
          break;
        case KeyCode.O :
          if (event.ctrlKey) {
            event.preventDefault();
            
            worksheet.loadFromFile();
          }
          
          break;
      }
    }));
  }
  
  void stop() {
    _subscriptions.forEach((StreamSubscription S) => S.cancel());
    
    _subscriptions.clear();
  }
  
  void _document_copyHandler(Event event) {
    _selectionSnapshot = new List<Cell>.generate(worksheet.selectedCells.length, (int i) => new Cell.fromOtherCell(worksheet.selectedCells[i]));
  }
  
  void _document_pasteHandler(Event event) {
    if (_selectionSnapshot == null || _selectionSnapshot.isEmpty) return; 
      
    final Cell startCell = _selectionSnapshot.first;
    final Cell offsetCell = worksheet.selectedCells.first;
    final int dx = offsetCell.colIndex - startCell.colIndex;
    final int dy = offsetCell.rowIndex - startCell.rowIndex;
    
    for (int i=0, len=_selectionSnapshot.length; i<len; i++) {
      Cell currCell = _selectionSnapshot[i];
      Cell tmpCell = worksheet.getCell(currCell.rowIndex + dy, currCell.colIndex + dx);
      
      if (tmpCell != null) tmpCell.copyFrom(currCell, startCell, startCell.formula.body);
    }
    
    event.preventDefault();
  }
}