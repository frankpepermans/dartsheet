part of dartsheet.view;

class ColumnList extends ListRenderer {
  
  @event Stream<FrameworkEvent<int>> onCurrentRowOffsetChanged;
  @event Stream<FrameworkEvent<List<int>>> onHighlightRangeChanged;
  
  //---------------------------------
  // currentRowOffset
  //---------------------------------
  
  int _currentRowOffset = 0;
  
  int get currentRowOffset => _currentRowOffset;
  set currentRowOffset(int value) {
    if (value != _currentRowOffset) {
      _currentRowOffset = value;
      
      invokeLaterSingle('_invalidateHighlight', _invalidateHighlight);
      
      notify(
          new FrameworkEvent<int>('currentRowOffsetChanged', relatedObject: value)    
      );
    }
  }
  
  ItemRendererFactory<RowItemRenderer<Row<Cell<dynamic>>>> _itemRendererFactory;
  
  ColumnList() : super() {
    _itemRendererFactory = new ItemRendererFactory<RowItemRenderer<Row<Cell<dynamic>>>>(
        constructorMethod: RowItemRenderer.construct, 
        className: 'row-item-renderer'
    );
  }
  
  List<int> _highlightRange;
  
  List<int> get highlightRange => _highlightRange;
  void set highlightRange(List<int> value) {
    if (_highlightRange != value) {
      _highlightRange = value;
      
      invokeLaterSingle('_invalidateHighlight', _invalidateHighlight);
      
      notify(
          new FrameworkEvent<List<int>>('highlightRangeChanged', relatedObject: value)    
      );
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
  
  void _invalidateHighlight() {
    if (itemRenderers != null && _highlightRange != null) itemRenderers.forEach((RowItemRenderer<Row<Cell<dynamic>>> renderer) {
      renderer.invokeLaterSingle('invalidateData', renderer.invalidateData);
    });
  }
}