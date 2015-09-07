part of dartsheet.view;

class Window extends DartFlexRootContainer {

  Header menuGroup;
  HGroup worksheetGroup;
  FloatingWindow methodFieldFloater;
  ValueEntry valueEntry;
  EditableTextArea methodField;
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
      ..percentWidth = 100.0
      ..percentHeight = 100.0
      ..onValueInput.listen(_valueField_inputHandler)
      ..onFocus.listen(
          (_) => notify(new FrameworkEvent('valueEntryFocus'))
      );
    
    methodField = new EditableTextArea()
      ..className = 'method-field'
      ..percentWidth = 100.0
      ..percentHeight = 100.0
      ..onTextChanged.listen(_handleMethodField)
      ..enabled = false;
    
    sheet = new WorkSheet(160, 50)
      ..className = 'workbook'
      ..percentWidth = 100.0
      ..percentHeight = 100.0
      ..onSelectedCellsChanged.listen(_handleCellSelection)
      ..onValueEntryFocus.listen(
          (_) => methodFieldFloater.visible = true
      );
    
    worksheetGroup.addComponent(sheet);
    
    //addComponent(menuGroup);
    addComponent(worksheetGroup);
    
    methodFieldFloater.addHeaderComponent(valueEntry);
    methodFieldFloater.addComponent(methodField);
    
    addComponent(methodFieldFloater);
  }
  
  void _handleMethodField(FrameworkEvent event) {
    if (sheet.selectedCells != null && sheet.selectedCells.isNotEmpty) sheet.selectedCells.forEach((Cell cell) {
      cell.formula.originator = sheet.selectedCells.first;
      cell.formula.body = methodField.text;
    });
  }
  
  void _handleCellSelection(FrameworkEvent<List<Cell>> event) {
    valueEntry.value = sheet.selectedCells.isNotEmpty ? sheet.selectedCells.first.value : '';
    
    methodField.enabled = true;
    
    if (event.relatedObject.length > 1) return;
    
    if (event.relatedObject.isNotEmpty) methodField.text = event.relatedObject.first.formula.body;
    else methodField.text = '';
  }
  
  void _valueField_inputHandler(FrameworkEvent<String> event) {
    if (sheet.selectedCells != null && sheet.selectedCells.isNotEmpty)
      sheet.selectedCells.first.value = event.relatedObject;
  }
}