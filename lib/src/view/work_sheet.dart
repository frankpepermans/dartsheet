part of dartsheet.view;

class WorkSheet extends Group {
  
  @event Stream<FrameworkEvent<List<Cell>>> onSelectedCellsChanged;
  
  //---------------------------------
  //
  // Protected properties
  //
  //---------------------------------
  
  final int initRows;
  final int initCols;
  
  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  ColumnList columnList;
  Spreadsheet spreadsheet;
  
  //---------------------------------
  // spreadsheetCells
  //---------------------------------
  
  final List<Cell> _spreadsheetCells = <Cell>[];
  
  List<Cell> get spreadsheetCells => _spreadsheetCells;
  
  //---------------------------------
  // selectedCells
  //---------------------------------
  
  List<Cell> _selectedCells;
  
  List<Cell> get selectedCells => _selectedCells;
  
  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------
  
  WorkSheet(this.initRows, this.initCols) : super();
  
  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------
  
  @override
  void createChildren() {
    final ObservableList<Row<Cell<dynamic>>> dataProvider = _createNewDataProvider(0);
    
    super.createChildren();
    
    final HGroup gridGroup = new HGroup(gap: 0)
      ..className = 'workbook'
      ..percentWidth = 100.0
      ..percentHeight = 100.0;
    
    final VGroup columnListGroup = new VGroup(gap: 0)
      ..width = 30
      ..percentHeight = 100.0;
    
    final Spacer spacer = new Spacer()
      ..percentWidth = 100.0
      ..height = 23;
    
    columnList = new ColumnList()
      ..rowHeight = 23
      ..dataProvider = dataProvider
      ..highlightRange = <int>[];
    
    columnListGroup.addComponent(spacer);
    columnListGroup.addComponent(columnList);
    
    spreadsheet = new Spreadsheet()
      ..cssClasses = const <String>[]
      ..percentWidth = 100.0
      ..percentHeight = 100.0
      ..allowHeaderColumnSorting = true
      ..allowMultipleSelection = true
      ..headerHeight = 24
      ..rowHeight = columnList.rowHeight
      ..columnSpacing = 0
      ..rowSpacing = 0
      ..autoScrollOnDataChange = true
      ..dataProvider = dataProvider
      ..columns = _createGridColumns()
      ..useEvenOdd = false
      ..onListScrollPositionChanged.listen(_updateRowIndices)
      ..onHeightChanged.listen(_updateRowIndices)
      ..onRendererAdded.listen(_handleNewRowRenderer);
    
    gridGroup.addComponent(columnListGroup);
    gridGroup.addComponent(spreadsheet);
    
    addComponent(gridGroup);
  }
  
  Future invalidateFormula(Formula formula) async {
    await formula.appliesTo.clearSiblingSubscriptions();
    
    final JsFunctionBody jsf = formula.getJavaScriptFunctionBody(spreadsheet.dataProvider, formula.appliesTo.siblingSubscriptions, invalidateFormula);
    
    if (formula.appliesTo.scriptElement != null) formula.appliesTo.scriptElement.remove();
    
    try {
      formula.appliesTo.scriptElement = new ScriptElement()..innerHtml = jsf.value;
      
      document.head.append(formula.appliesTo.scriptElement);
      
      formula.appliesTo.value = context.callMethod('__${formula.appliesTo.id}', jsf.arguments).toString();
    } catch (error) {
      formula.appliesTo.value = null;
    }
  }
  
  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------
  
  ObservableList<Row<Cell<dynamic>>> _createNewDataProvider(int startRowIndex) =>
    new ObservableList<Row<Cell<dynamic>>>.from(
        new List<Row<Cell<dynamic>>>.generate(initRows, (int rowIndex) => _createRow(startRowIndex + rowIndex))
    );
  
  ObservableList<DataGridColumn> _createGridColumns() {
    final ObservableList<DataGridColumn> list = new ObservableList<DataGridColumn>.from(
      new List<DataGridColumn>.generate(initCols, (int i) {
        String id;
        
        if (i >= 26 ) id = new String.fromCharCodes(<int>[64 + i ~/ 26, 65 + i - 26 * (i ~/ 26)]);
        else id = new String.fromCharCode(65 + i);
        
        final Symbol S = new Symbol(id);
      
        return new DataGridColumn()
          ..field = S
          ..width = 120
          ..minWidth = 20
          ..headerData = new HeaderData('', S, id, '')
          ..headerItemRendererFactory = new ItemRendererFactory<HeaderItemRenderer>(constructorMethod: HeaderItemRenderer.construct)
          ..columnItemRendererFactory = new ItemRendererFactory<CellItemRenderer<Cell<String>>>(constructorMethod: CellItemRenderer.construct);
      })
    );
    
    return list;
  }
  
  Row<Cell<dynamic>> _createRow(int rowIndex) {
    final Row<Cell<dynamic>> row = new Row<Cell<dynamic>>(rowIndex);
    
    for (int i=0; i<initCols; i++) row.add(_createCell(toCellIdentity(rowIndex, i), rowIndex, i));
    
    return row;
  }
  
  Cell<dynamic> _createCell(String id, int rowIndex, int colIndex) {
    final Cell<dynamic> cell = new Cell<dynamic>(id, _spreadsheetCells.length, rowIndex, colIndex, null);
    
    _spreadsheetCells.add(cell);
    
    cell.formula.onBodyChanged.listen((FrameworkEvent<String> event) => invalidateFormula(event.currentTarget as Formula));
    
    return cell;
  }
  
  void _updateRowIndices([FrameworkEvent event]) {
    columnList.offsetStream.add(spreadsheet.scrollPosition ~/ spreadsheet.rowHeight);
    
    if (spreadsheet.scrollPosition > (spreadsheet.rowHeight * spreadsheet.dataProvider.length - spreadsheet.height) * .95) 
      spreadsheet.dataProvider.addAll(_createNewDataProvider(spreadsheet.dataProvider.length));
  }
  
  void _handleNewRowRenderer(FrameworkEvent<DataGridItemRenderer> event) {
    event.relatedObject.onRendererAdded.listen(_handleNewCellRenderer);
  }
  
  void _handleNewCellRenderer(FrameworkEvent<CellItemRenderer> event) {
    event.relatedObject.onMouseDown.listen(_handleCellDown);
    event.relatedObject.onMouseOver.listen(_handleCellEntry);
    
    _updateRowIndices();
  }
  
  Cell _selectionStartCell;
  bool _isInSelectionMode = false;
  
  void _handleCellEntry(FrameworkEvent<MouseEvent> event) {
    if (_isInSelectionMode) {
      final CellItemRenderer<Cell<String>> renderer = event.currentTarget as CellItemRenderer<Cell<String>>;
      
      _cleanCurrentSelection();
      
      _updateCurrentSelection(_selectionStartCell, renderer.data);
    }
  }
  
  void _handleCellDown(FrameworkEvent<MouseEvent> event) {
    StreamSubscription mouseUpSubscription;
    
    if (_selectionStartCell != null) _selectionStartCell.focused = false;
    
    _cleanCurrentSelection();
    
    _isInSelectionMode = true;
    _selectionStartCell = (event.currentTarget as CellItemRenderer<Cell>).data;
    
    _selectionStartCell.focused = true;
    
    mouseUpSubscription = document.onMouseUp.listen((MouseEvent event) {
      _isInSelectionMode = false;
      
      mouseUpSubscription.cancel();
    });
    
    _updateCurrentSelection(_selectionStartCell, _selectionStartCell);
  }
  
  void _cleanCurrentSelection() {
    if (_selectedCells != null) _selectedCells.forEach((Cell cell) => cell.selected = false);
  }
  
  void _updateCurrentSelection(Cell minCell, Cell maxCell) {
    final List<int> highlightedRows = <int>[];
    final List<int> highlightedCols = <int>[];
    Cell cell;
    
    _selectedCells = <Cell>[];
    
    if (minCell.globalIndex > maxCell.globalIndex) {
      Cell tmpCell = minCell;
      
      minCell = maxCell;
      maxCell = tmpCell;
    }
    
    final int minRowIndex = (minCell.rowIndex < maxCell.rowIndex) ? minCell.rowIndex : maxCell.rowIndex;
    final int maxRowIndex = (minCell.rowIndex > maxCell.rowIndex) ? minCell.rowIndex : maxCell.rowIndex;
    final int minColIndex = (minCell.colIndex < maxCell.colIndex) ? minCell.colIndex : maxCell.colIndex;
    final int maxColIndex = (minCell.colIndex > maxCell.colIndex) ? minCell.colIndex : maxCell.colIndex;
    
    final int startIndex = minRowIndex * this.initCols + minColIndex;
    final int endIndex = maxRowIndex * this.initCols + maxColIndex;
    
    for (int i=startIndex; i<=endIndex; i++) {
      cell = _spreadsheetCells[i];
      
      if (
          (cell.rowIndex >= minRowIndex && cell.rowIndex <= maxRowIndex) &&
          (cell.colIndex >= minColIndex && cell.colIndex <= maxColIndex)
      ) {
        cell.selected = true;
        
        if (!highlightedRows.contains(cell.rowIndex)) highlightedRows.add(cell.rowIndex);
        if (!highlightedCols.contains(cell.colIndex)) highlightedCols.add(cell.colIndex);
        
        _selectedCells.add(cell);
      }
    }
    
    columnList.highlightRange = highlightedRows;
    spreadsheet.highlightRange = highlightedCols;
    
    _updateRowIndices();
    
    notify(new FrameworkEvent<List<Cell>>('selectedCellsChanged', relatedObject: _selectedCells));
  }
}