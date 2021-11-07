import 'dart:convert';

class IncidentesModel {
  int _code;     
  List<Incidente> _incidentes = [];

  IncidentesModel.fromJson(Map<String, dynamic> parsedJson) {
    print(parsedJson);
    _code = parsedJson['code'];   
    List<Incidente> temp = [];
    for (int i = 0; i < parsedJson['body'].length; i++) {
      Incidente incidente = Incidente(parsedJson['body'][i]);      
      temp.add(incidente);      
    }
    _incidentes = temp;
  }

  List<Incidente> get incidentes => _incidentes;

  int get code => _code;
}

class Incidente {
  List<dynamic> _incidente;
  String _tituloIncidente;
  int _valorTitulo;
  int _incidenteId;
  String _usuarioIncidente;
  String _estadoIncidente;
  String _responsable;
  bool _cerrado;
  int _createDate;  


  Incidente(incidente) {             
    _incidente = json.decode(incidente['data'])['reporteCompleto'];   
    _createDate = incidente['createDate']; 
    _responsable = incidente['userNameTo'];
    _cerrado = incidente['flagCerrado'];
    _incidenteId = incidente['incidenteId'];    
    _valorTitulo = int.parse(_incidente[0]['formPrincipal'][0]['value']);    
    _tituloIncidente = _incidente[0]['formPrincipal'][0]['list'][_valorTitulo-1]['title'];    
    _usuarioIncidente = incidente['userName'];   
    if (incidente['estado'] == 0) {
      _estadoIncidente = 'Pendiente';
    } else if (incidente['estado'] == 1) {
      _estadoIncidente = 'En proceso';
    } else if (incidente['estado'] == 2) {
      _estadoIncidente = 'Resuelto';
    } 
    
  }

  List<dynamic> get incidente => _incidente;
  String get tituloIncidente => _tituloIncidente;
  String get usuarioIncidente => _usuarioIncidente;
  int get incidenteId => _incidenteId;
  String get estadoIncidente => _estadoIncidente;
  int get createDate => _createDate;
  String get responsable => _responsable;
  bool get cerrado => _cerrado;
}
