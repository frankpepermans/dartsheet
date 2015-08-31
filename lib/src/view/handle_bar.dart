part of dartsheet.view;

class HandleBar extends Spacer {
  
  @event Stream<FrameworkEvent> onOrientationChanged;
  
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
  //
  // Constructor
  //
  //---------------------------------
  
  HandleBar() : super() {
    className = 'handle-bar';
  }
  
  @override
  void commitProperties() {
    super.commitProperties();
    
    if (_isOrientationChanged) {
      
    }
  }
}