part of dartsheet.view;

class HandleBar extends Group {
  
  @event Stream<FrameworkEvent> onOrientationChanged;
  @event Stream<FrameworkEvent> onIndicatorSizeChanged;
  @event Stream<FrameworkEvent<int>> onDrag;
  @event Stream<FrameworkEvent<int>> onDragStart;
  @event Stream<FrameworkEvent<int>> onDragEnd;
  
  IItemRenderer indicator, body;
  
  //---------------------------------
  // orientation
  //---------------------------------

  String _orientation;
  bool _isOrientationChanged = false;

  String get orientation => _orientation;
  set orientation(String value) {
    if (value != _orientation) {
      _orientation = value;
      _isOrientationChanged = true;

      notify(
        new FrameworkEvent(
          'orientationChanged'
        )
      );

      invalidateProperties();
    }
  }
  
  //---------------------------------
  // indicatorSize
  //---------------------------------

  int _indicatorSize;

  int get indicatorSize => _indicatorSize;
  set indicatorSize(int value) {
    if (value != _indicatorSize) {
      _indicatorSize = value;

      notify(
        new FrameworkEvent(
          'indicatorSizeChanged'
        )
      );

      invalidateProperties();
    }
  }
  
  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------
  
  HandleBar() : super() {
    className = 'handle-bar';
  }
  
  @override
  void createChildren() {
    super.createChildren();
    
    indicator = new ItemRenderer()..className = 'handle-bar-indicator';
    body = new ItemRenderer()..className = 'handle-bar-body';
    
    streamSubscriptionManager.add(
        'body-mouse-down', 
        body.onMouseDown.listen(_body_mouseDownHandler)
    );
    
    addComponent(indicator);
    addComponent(body);
  }
  
  @override
  void commitProperties() {
    super.commitProperties();
    
    if (_isOrientationChanged) {
      if (_orientation == 'horizontal' && !(layout is HorizontalLayout)) layout = (new HorizontalLayout()..gap = 0);
      if (_orientation == 'vertical' && !(layout is VerticalLayout)) layout = (new VerticalLayout()..gap = 0);
    }
    
    if (indicator != null) {
      if (_orientation == 'horizontal') {
        indicator.width = _indicatorSize;
        indicator.percentHeight = 100.0;
      } else {
        indicator.percentWidth = 100.0;
        indicator.height = _indicatorSize;
      }
    }
    
    if (body != null) {
      body.percentWidth = 100.0;
      body.percentHeight = 100.0;
      
      if (_orientation == 'horizontal') body.reflowManager.invalidateCSS(body.control, 'cursor', 'n-resize');
      else body.reflowManager.invalidateCSS(body.control, 'cursor', 'w-resize');
    }
  }
  
  void _body_mouseDownHandler(FrameworkEvent<MouseEvent> event) {
    streamSubscriptionManager.flushIdent('body-mouse-move');
    streamSubscriptionManager.flushIdent('body-mouse-up');
        
    streamSubscriptionManager.add(
        'body-mouse-move', 
        document.onMouseMove.listen(_body_mouseMoveHandler)
    );
    
    streamSubscriptionManager.add(
        'body-mouse-up', 
        document.onMouseUp.listen(_body_mouseUpHandler)
    );
    
    notify(new FrameworkEvent('dragStart'));
  }
  
  void _body_mouseMoveHandler(MouseEvent event) {
    if (_orientation == 'horizontal') {
      notify(new FrameworkEvent<int>('drag', relatedObject: event.movement.y));
    } else {
      notify(new FrameworkEvent<int>('drag', relatedObject: event.movement.x));
    }
  }
  
  void _body_mouseUpHandler(MouseEvent event) {
    streamSubscriptionManager.flushIdent('body-mouse-move');
    streamSubscriptionManager.flushIdent('body-mouse-up');
    
    notify(new FrameworkEvent('dragEnd'));
  }
}