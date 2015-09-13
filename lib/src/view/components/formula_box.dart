part of dartsheet.view;

class FormulaBox extends Component {
  
  @event Stream<FrameworkEvent> onTextChanged;
  
  PreElement input;
  Element code;
  
  //---------------------------------
  // text
  //---------------------------------
  
  String _text;

  String get text => _text;
  set text(String value) {
    if (value != _text) {
      _text = value;

      notify('textChanged');

      _commitText();
    }
  }
  
  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  FormulaBox({String elementId: null}) : super(elementId: elementId) {
    className = 'formula-box';
  }
  
  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  @override
  void createChildren() {
    super.createChildren();
    
    input = new PreElement();
    
    code = document.createElement('code')
    ..contentEditable = 'true'
    ..onFocus.listen((_) => invokeLaterSingle('runHighlight', _runHighlight))
    ..onBlur.listen((_) => invokeLaterSingle('runHighlight', _runHighlight))
    ..onPaste.listen((_) {
      _text = code.text;
          
      invokeLaterSingle('runHighlight', _runHighlight);
      
      notify('textChanged');
    });
    
    input.append(code);
    
    code.onKeyUp.listen(_inputHandler);

    setControl(input);
    
    _commitText();
  }
  
  void _commitText() {
    if (control != null) invokeLaterSingle('commitTextOnReflow', _commitTextOnReflow);
  }
  
  void _commitTextOnReflow() {
    final String newText = (_text != null) ? _text : '';
    
    if (newText == code.innerHtml) return;
    
    code.text = newText;
    
    invokeLaterSingle('runHighlight', _runHighlight);
  }
  
  void _inputHandler(KeyboardEvent event) {
    _text = code.text;
    
    notify('textChanged');
  }
  
  void _runHighlight() {
    if (code != null) context['hljs'].callMethod('highlightBlock', [code]);
  }
}