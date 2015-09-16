part of dartsheet.view;

class Window extends DartFlexRootContainer {

  Header menuGroup;
  HGroup worksheetGroup;
  FloatingWindow methodFieldFloater;
  ValueEntry valueEntry;
  Dropdown examples;
  FormulaBox methodField;
  ScriptValidationRenderer<Formula> scriptValidationRenderer;
  WorkSheet sheet;
  
  Window(String elementId) : super(elementId: elementId) {
    className = 'main-window';
  }
  
  @override
  void createChildren() {
    super.createChildren();
    
    layout = new VerticalLayout()..gap = 5;
    
    menuGroup = new Header()
      ..percentWidth = 100.0
      ..height = 110;
    
    worksheetGroup = new HGroup()
      ..percentWidth = 100.0
      ..percentHeight = 100.0;
    
    methodFieldFloater = new FloatingWindow()
      ..width = 640
      ..height = 400
      ..paddingLeft = 300
      ..paddingTop = 300
      ..gap = 0
      ..includeInLayout = false
      ..visible = true
      ..onClose.listen((FrameworkEvent event) => (event.currentTarget as FloatingWindow).visible = false);
    
    valueEntry = new ValueEntry()
      ..width = 100
      ..percentHeight = 100.0;
    
    examples = new Dropdown()
      ..percentWidth = 100.0
      ..percentHeight = 100.0
      ..labelFunction = ((Map<String, dynamic> M) => (M == null) ? '' : M['title'])
      ..itemRendererFactory = new ItemRendererFactory<LabelItemRenderer>(constructorMethod: LabelItemRenderer.construct)
      ..onSelectedItemChanged.listen(_dropdown_selectionHandler);
    
    methodField = new FormulaBox()
      ..className = 'method-field'
      ..percentWidth = 100.0
      ..percentHeight = 100.0
      ..onTextChanged.listen(_handleMethodField)
      ..onControlChanged.listen((FrameworkEvent<Element> event) => (event.currentTarget as FormulaBox).code.onFocus.listen((_) => sheet._operationsManager.stop()))
      ..enabled = false;
    
    sheet = new WorkSheet(160, 50)
      ..className = 'workbook'
      ..percentWidth = 100.0
      ..percentHeight = 100.0
      ..onSelectedCellsChanged.listen(_handleCellSelection)
      ..onSelectionStart.listen((_) => reflowManager.invalidateCSS(methodFieldFloater.control, 'z-index', '-1'))
      ..onSelectionEnd.listen((_) => reflowManager.invalidateCSS(methodFieldFloater.control, 'z-index', '99999'))
      ..onScriptValidationChanged.listen(_handleScriptValidation);
    
    scriptValidationRenderer = new ScriptValidationRenderer<Formula>()
      ..percentWidth = 100.0
      ..percentHeight = 100.0;
    
    worksheetGroup.addComponent(sheet);
    
    addComponent(worksheetGroup);
    
    methodFieldFloater.addHeaderComponent(valueEntry);
    methodFieldFloater.addHeaderComponent(new Spacer()..width = 1);
    methodFieldFloater.addHeaderComponent(examples);
    
    methodFieldFloater.addComponent(methodField);
    
    methodFieldFloater.addFooterComponent(scriptValidationRenderer);
    
    addComponent(methodFieldFloater);
    
    _loadManifest();
  }
  
  void _handleMethodField(FrameworkEvent event) {
    if (sheet.selectedCells != null && sheet.selectedCells.isNotEmpty) sheet.selectedCells.forEach((Cell cell) {
      cell.formula.originator = sheet.selectedCells.first;
      cell.formula.body = methodField.text;
    });
  }
  
  void _handleCellSelection(FrameworkEvent<List<Cell>> event) {
    if (sheet.selectedCells.length >= 2)
      valueEntry.value = '${sheet.selectedCells.first.id} - ${sheet.selectedCells.last.id}';
    else if (sheet.selectedCells.isNotEmpty)
      valueEntry.value = sheet.selectedCells.first.id;
    else
      valueEntry.value = '';
    
    methodField.enabled = methodFieldFloater.visible = true;
    examples.selectedItem = null;
    
    if (event.relatedObject.length > 1) return;
    
    if (event.relatedObject.isNotEmpty) methodField.text = event.relatedObject.first.formula.body;
    else methodField.text = '';
    
    scriptValidationRenderer.data = event.relatedObject.first.formula;
  }
  
  void _handleScriptValidation(FrameworkEvent<Formula> event) {
    scriptValidationRenderer.data = event.relatedObject;
  }
  
  void _dropdown_selectionHandler(FrameworkEvent<String> event) {
    if (event.relatedObject != null) _loadExample((event.relatedObject as Map<String, dynamic>)['fileName']);
  }
  
  Future _loadManifest() async {
    final List<Map<String, dynamic>> manifest = JSON.decode(await HttpRequest.getString('examples/manifest.json'));
    
    final Map<String, dynamic> defaultExample = manifest.firstWhere(
        (Map<String, dynamic> M) => M.containsKey('loadByDefault') && M['loadByDefault'] == true,
        orElse: () => null
    );
    
    examples.dataProvider = new ObservableList<Map<String, dynamic>>.from(manifest);
    
    _loadExample(defaultExample['fileName']);
  }
  
  Future _loadExample(String fileName) async {
    final String exampleJs = await HttpRequest.getString(fileName);
    
    /*if (sheet.lastEditedCell != null) methodField.text = exampleJs.replaceAll(new RegExp(r'\$[A-Z]+[\d]+'), '\$${sheet.lastEditedCell.id}');
    else methodField.text = exampleJs;*/
    
    methodField.text = exampleJs;
    
    return null;
  }
}