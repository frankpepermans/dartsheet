part of dartsheet.view;

class WorkSheet extends Group {
  
  @event Stream<FrameworkEvent<List<Cell>>> onSelectedCellsChanged;
  
  //---------------------------------
  //
  // Protected properties
  //
  //---------------------------------
  
  final StreamController<int> _rowOffsetStreamController = new StreamController();
  final int initRows;
  final int initCols;
  
  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
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
    
    final ListRenderer columnList = new ListRenderer()
      ..percentWidth = 100.0
      ..percentHeight = 100.0
      ..rowHeight = 23
      ..dataProvider = dataProvider
      ..itemRendererFactory = new ItemRendererFactory<RowItemRenderer>(constructorMethod: RowItemRenderer.construct, className: 'row-item-renderer', constructorArguments: <Stream<int>>[_rowOffsetStreamController.stream.asBroadcastStream()])
      ..autoManageScrollBars = false
      ..horizontalScrollPolicy = ScrollPolicy.NONE
      ..verticalScrollPolicy = ScrollPolicy.NONE;
    
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
    
    return cell;
  }
  
  void _updateRowIndices(FrameworkEvent event) {
    _rowOffsetStreamController.add(spreadsheet.scrollPosition ~/ spreadsheet.rowHeight);
    
    if (spreadsheet.scrollPosition > (spreadsheet.rowHeight * spreadsheet.dataProvider.length - spreadsheet.height) * .95) spreadsheet.dataProvider.addAll(_createNewDataProvider(spreadsheet.dataProvider.length));
  }
  
  void _handleNewRowRenderer(FrameworkEvent<DataGridItemRenderer> event) {
    event.relatedObject.onRendererAdded.listen(_handleNewCellRenderer);
  }
  
  void _handleNewCellRenderer(FrameworkEvent<CellItemRenderer> event) {
    event.relatedObject.onMouseDown.listen(_handleCellDown);
    event.relatedObject.onMouseOver.listen(_handleCellEntry);
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
    Cell cell;
    int startIndex = minCell.globalIndex;
    int endIndex = maxCell.globalIndex;
    
    _selectedCells = <Cell>[];
    
    if (startIndex > endIndex) {
      Cell tmpCell = minCell;
      int tmp = startIndex;
      
      startIndex = endIndex;
      endIndex = tmp;
      
      minCell = maxCell;
      maxCell = tmpCell;
    }
    
    for (int i=startIndex; i<=endIndex; i++) {
      cell = _spreadsheetCells[i];
      
      if (
          (cell.rowIndex >= minCell.rowIndex && cell.colIndex >= minCell.colIndex) &&
          (cell.rowIndex <= maxCell.rowIndex && cell.colIndex <= maxCell.colIndex)
      ) _selectedCells.add(cell..selected = true);
    }
    
    notify(new FrameworkEvent<List<Cell>>('selectedCellsChanged', relatedObject: _selectedCells));
  }
}