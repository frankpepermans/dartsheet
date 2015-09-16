part of dartsheet.view;

class ScriptValidationRenderer<D extends Formula> extends ItemRenderer<Formula> {
  
  //---------------------------------
  // data
  //---------------------------------
  
  set data(D value) {
    streamSubscriptionManager.flushIdent('validation-listener');
    
    super.data = value;
    
    if (value != null) streamSubscriptionManager.add('validation-listener', value.onValidationChanged.listen((_) => invalidateData()));
  }
  
  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  ScriptValidationRenderer() : super() {
    className = 'script-validation-renderer';
  }

  static ScriptValidationRenderer construct() => new ScriptValidationRenderer();
  
  @override
  void invalidateData() {
    if (control == null || data == null) return;
    
    if (data.isValid) reflowManager.invalidateCSS(control, 'background-color', '#6c6');
    else reflowManager.invalidateCSS(control, 'background-color', '#f90');
  }
  
}