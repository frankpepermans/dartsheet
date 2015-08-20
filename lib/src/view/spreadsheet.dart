part of dartsheet.view;

class Spreadsheet extends DataGrid {
  
  List<int> _highlightRange;
  
  List<int> get highlightRange => _highlightRange;
  void set highlightRange(List<int> value) {
    if (_highlightRange != value) {
      _highlightRange = value;
      
      _invalidateHighlight();
    }
  }
  
  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------
  
  Spreadsheet() : super();
  
  void _invalidateHighlight() {
    if (headerItemRenderers != null && _highlightRange != null) headerItemRenderers.forEach((IHeaderItemRenderer renderer) {
      renderer.highlighted = _highlightRange.contains(renderer.index);
    });
  }
  
}