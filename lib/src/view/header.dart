part of dartsheet.view;

class Header extends Group {
  
  Dropdown cellFormatter;
  
  Header() : super() {
    className = 'menu-group';
  }
  
  @override
  void createChildren() {
    super.createChildren();
    
    layout = new HorizontalLayout()..gap = 6;
    
    cellFormatter = new Dropdown()
      ..width = 58
      ..height = 40
      ..dataProvider = new ObservableList<String>.from(<String>['alphanumeric', 'numeric', 'date', 'time'])
      ..selectedItem = 'alphanumeric'
      ..itemRendererFactory = new ItemRendererFactory<LabelItemRenderer>(
          constructorMethod: LabelItemRenderer.construct
      );
    
    addComponent(cellFormatter);
  }
  
}