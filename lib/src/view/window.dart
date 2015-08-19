part of dartsheet.view;

class Window extends DartFlexRootContainer {

  EditableTextArea methodField;
  WorkSheet sheet;
  
  Window(String elementId) : super(elementId: elementId) {
    className = 'main-window';
  }
  
  @override
  void createChildren() {
    super.createChildren();
    
    layout = new VerticalLayout();
    
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
    
    sheet = new WorkSheet(160, 50)
      ..className = 'workbook'
      ..percentWidth = 100.0
      ..percentHeight = 100.0
      ..onSelectedCellsChanged.listen(_handleCellSelection);
    
    addComponent(methodFieldBC);
    addComponent(sheet);
  }
  
  void _handleMethodField(FrameworkEvent event) {
    if (sheet.selectedCells != null) sheet.selectedCells.forEach((Cell cell) => cell.formula = methodField.text);
  }
  
  void _handleCellSelection(FrameworkEvent<List<Cell>> event) {
    if (event.relatedObject.isNotEmpty) methodField.text = event.relatedObject.first.formula;
    else methodField.text = '';
  }
}