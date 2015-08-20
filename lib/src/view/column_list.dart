part of dartsheet.view;

class ColumnList extends ListRenderer {
  
  final StreamController<int> offsetStream = new StreamController();
  
  ItemRendererFactory<RowItemRenderer<Row<Cell<dynamic>>>> _itemRendererFactory;
  Stream<int> stream;
  
  ColumnList() : super() {
    stream = offsetStream.stream.asBroadcastStream();
    
    stream.listen(_invalidateHighlight);
    
    _itemRendererFactory = new ItemRendererFactory<RowItemRenderer<Row<Cell<dynamic>>>>(
        constructorMethod: RowItemRenderer.construct, 
        className: 'row-item-renderer', 
        constructorArguments: <Stream<int>>[stream]
    );
  }
  
  List<int> _highlightRange;
  
  List<int> get highlightRange => _highlightRange;
  void set highlightRange(List<int> value) {
    if (_highlightRange != value) {
      _highlightRange = value;
      
      stream.last.then(_invalidateHighlight);
    }
  }
  
  @override
  void commitProperties() {
    super.commitProperties();
    
    percentWidth = 100.0;
    percentHeight = 100.0;
    itemRendererFactory = _itemRendererFactory;
    autoManageScrollBars = false;
    horizontalScrollPolicy = ScrollPolicy.NONE;
    verticalScrollPolicy = ScrollPolicy.NONE;
  }
  
  void _invalidateHighlight(int currentRowOffset) {
    if (itemRenderers != null && _highlightRange != null) itemRenderers.forEach((RowItemRenderer<Row<Cell<dynamic>>> renderer) {
      renderer.highlighted = _highlightRange.contains(renderer.data.rowIndex + currentRowOffset);
    });
  }
}