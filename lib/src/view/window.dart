part of dartsheet.view;

class Window extends DartFlexRootContainer {
  
  static const int _INIT_ROWS = 160;
  static const int _INIT_COLS = 50;
  
  HGroup gridGroup;
  ListRenderer columnList;
  InfiniGrid grid;
  StreamController<int> rowOffsetStreamController;
  Cell selectedCell;
  EditableTextArea methodField;
  
  Window(String elementId) : super(elementId: elementId) {
    className = 'main-window';
  }
  
  @override
  void createChildren() {
    final ObservableList<Row<Cell<dynamic>>> dataProvider = _createNewDataProvider(0);
    
    super.createChildren();
    
    layout = new VerticalLayout();
    
    rowOffsetStreamController = new StreamController();
    
    BoundsContainer methodFieldBC = new BoundsContainer()
      ..percentWidth = 100.0
      ..height = 220
      ..left = 20
      ..right = 20
      ..top = 5
      ..bottom = 5;
    
    methodField = new EditableTextArea()
      ..percentWidth = 100.0
      ..percentHeight = 100.0
      ..onTextChanged.listen(_handleMethodField);
    
    methodFieldBC.body.addComponent(methodField);
    
    gridGroup = new HGroup(gap: 0)
      ..className = 'workbook'
      ..percentWidth = 100.0
      ..percentHeight = 100.0;
    
    final VGroup columnListGroup = new VGroup(gap: 0)
      ..width = 30
      ..percentHeight = 100.0;
    
    final Spacer spacer = new Spacer()
      ..percentWidth = 100.0
      ..height = 23;
    
    columnList = new ListRenderer()
      ..percentWidth = 100.0
      ..percentHeight = 100.0
      ..rowHeight = 23
      ..dataProvider = dataProvider
      ..itemRendererFactory = new ItemRendererFactory<RowItemRenderer>(constructorMethod: RowItemRenderer.construct, className: 'row-item-renderer', constructorArguments: <Stream<int>>[rowOffsetStreamController.stream.asBroadcastStream()])
      ..autoManageScrollBars = false
      ..horizontalScrollPolicy = ScrollPolicy.NONE
      ..verticalScrollPolicy = ScrollPolicy.NONE;
    
    columnListGroup.addComponent(spacer);
    columnListGroup.addComponent(columnList);
    
    grid = new InfiniGrid()
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
    gridGroup.addComponent(grid);
    
    addComponent(methodFieldBC);
    addComponent(gridGroup);
  }
  
  ObservableList<Row<Cell<dynamic>>> _createNewDataProvider(int startRowIndex) =>
    new ObservableList<Row<Cell<dynamic>>>.from(
        new List<Row<Cell<dynamic>>>.generate(_INIT_ROWS, (int rowIndex) => _createRow(startRowIndex + rowIndex))
    );
  
  ObservableList<DataGridColumn> _createGridColumns() {
    final ObservableList<DataGridColumn> list = new ObservableList<DataGridColumn>.from(
      new List<DataGridColumn>.generate(_INIT_COLS, (int i) {
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
    
    for (int i=0; i<_INIT_COLS; i++) row.add(_createCell(toCellIdentity(rowIndex, i), rowIndex, i));
    
    return row;
  }
  
  Cell<dynamic> _createCell(String id, int rowIndex, int colIndex) => new Cell<dynamic>(id, rowIndex, colIndex, null);
  
  void _updateRowIndices(FrameworkEvent event) {
    rowOffsetStreamController.add(grid.scrollPosition ~/ grid.rowHeight);
    
    if (grid.scrollPosition > (grid.rowHeight * grid.dataProvider.length - grid.height) * .95) grid.dataProvider.addAll(_createNewDataProvider(grid.dataProvider.length));
  }
  
  void _handleNewRowRenderer(FrameworkEvent<DataGridItemRenderer> event) {
    event.relatedObject.onRendererAdded.listen(_handleNewCellRenderer);
  }
  
  void _handleNewCellRenderer(FrameworkEvent<CellItemRenderer> event) {
    event.relatedObject.onClick.listen(_handleCellClick);
  }
  
  void _handleCellClick(FrameworkEvent event) {
    final CellItemRenderer<Cell<String>> renderer = event.currentTarget as CellItemRenderer<Cell<String>>;
    final Cell<String> cell = renderer.data;
    
    selectedCell = cell;
    
    methodField.text = selectedCell.formula;
  }
  
  void _handleMethodField(FrameworkEvent event) {
    if (selectedCell != null) selectedCell.formula = methodField.text;
  }
}