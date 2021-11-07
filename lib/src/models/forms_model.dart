import 'dart:convert';

class FormsModel {
  /* int _code;      */
  dynamic _forms;
  dynamic _formPrincipal; 
  dynamic _formAgregarInformacion;

  FormsModel.fromJson(Map<String, dynamic> parsedJson) {    
    /* _code = parsedJson['code'];      */
    /* print(json.encode(json.decode(parsedJson['body']['data'])['formPrincipal'])); */
    print('parsed');    
    print(parsedJson);
    _forms = parsedJson;    
    _formPrincipal = json.decode(parsedJson['formPrincipal']['body']['data'])['formPrincipal'];        
    _formAgregarInformacion = json.decode(parsedJson['formAgregarInfo']['body']['data'])['formAgregarInfo'];        
    print('principal');
    print(_formPrincipal);    
    print('info');
    print(_formAgregarInformacion);
  }

  dynamic get forms => _forms;
  dynamic get formPrincipal => _formPrincipal;    
  dynamic get formAgregarInformacion => _formAgregarInformacion;

  /* int get code => _code; */
}