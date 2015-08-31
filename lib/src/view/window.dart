part of dartsheet.view;

class Window extends DartFlexRootContainer {

  HGroup menuGroup;
  HGroup worksheetGroup;
  EditableTextArea methodField;
  WorkSheet sheet;
  
  Window(String elementId) : super(elementId: elementId) {
    className = 'main-window';
  }
  
  @override
  void createChildren() {
    super.createChildren();
    
    layout = new VerticalLayout()..gap = 5;
    
    menuGroup = new HGroup()
      ..percentWidth = 100.0
      ..height = 110;
    
    worksheetGroup = new HGroup()
      ..percentWidth = 100.0
      ..percentHeight = 100.0;
    
    BoundsContainer methodFieldBC = new BoundsContainer()
      ..width = 360
      ..percentHeight = 100.0
      ..left = 5
      ..right = 5
      ..top = 5
      ..bottom = 5;
    
    methodField = new EditableTextArea()
      ..percentWidth = 100.0
      ..percentHeight = 100.0
      ..onTextChanged.listen(_handleMethodField)
      ..enabled = false;
    
    methodFieldBC.body.addComponent(methodField);
    
    sheet = new WorkSheet(160, 50)
      ..className = 'workbook'
      ..percentWidth = 100.0
      ..percentHeight = 100.0
      ..onSelectedCellsChanged.listen(_handleCellSelection);
    
    worksheetGroup.addComponent(sheet);
    worksheetGroup.addComponent(methodFieldBC);
    
    addComponent(menuGroup);
    addComponent(worksheetGroup);
  }
  
  void _handleMethodField(FrameworkEvent event) {
    if (sheet.selectedCells != null && sheet.selectedCells.isNotEmpty) sheet.selectedCells.forEach((Cell cell) {
      cell.formula.originator = sheet.selectedCells.first;
      cell.formula.body = methodField.text;
    });
  }
  
  void _handleCellSelection(FrameworkEvent<List<Cell>> event) {
    methodField.enabled = true;
    
    if (event.relatedObject.length > 1) return;
    
    if (event.relatedObject.isNotEmpty) methodField.text = event.relatedObject.first.formula.body;
    else methodField.text = '';
  }
}