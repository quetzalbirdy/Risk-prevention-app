import 'dart:convert';

class MensajesModel {
  int _code;     
  List<_Mensaje> _mensajes = [];

  MensajesModel.fromJson(Map<String, dynamic> parsedJson) {
    /* print(parsedJson['body'].length); */      
    _code = parsedJson['code'];   
    List<_Mensaje> temp = [];
    for (int i = 0; i < parsedJson['body'].length; i++) {
      _Mensaje mensaje = _Mensaje(parsedJson['body'][i]);
      temp.add(mensaje);
    }
    _mensajes = temp;
  }

  List<_Mensaje> get mensajes => _mensajes;

  int get code => _code;
}

class _Mensaje {
  String _body;
  List _incidente;
  int _userId;
  int _incidenteId;
  int _threadId;
  int _locationId;
  int _parentMessageId;
  int _createDate;
  int _gravedad;
  String _subject;
  String _asunto;
  String _tituloIncidente;
  int _valorTitulo;
  String _userSend;
  String _nombreObra;
  String _estadoIncidente;
  int _messageId;
  String _userReportadoPor;
  int  _userIdSend;
  int _estadoMensaje;
  bool _isAtrasado;
  String _responsable;
  bool _cerrado;

  _Mensaje(mensaje) {
    _body = mensaje['body'];
    _userId = mensaje['incidente']['userId'];
    _cerrado = mensaje['incidente']['flagCerrado'];
    _incidenteId = mensaje['incidente']['incidenteId'];
    _locationId = mensaje['incidente']['locationId'];
    if (mensaje['incidente']['estado'] == 0) {
      _estadoIncidente = 'Pendiente';
    } else if (mensaje['incidente']['estado'] == 1) {
      _estadoIncidente = 'En proceso';
    } else if (mensaje['incidente']['estado'] == 2) {
      _estadoIncidente = 'Resuelto';
    }
    _threadId = mensaje['threadId'];
    _estadoMensaje = mensaje['status'];
    _parentMessageId = mensaje['parentMessageId'];    
    _createDate = mensaje['incidente']['createDate'];
    _gravedad = mensaje['incidente']['gravedad'];
    _messageId = mensaje['messageId'];
    _subject = mensaje['subject'];
    _userSend = mensaje['userNameSend'];
    _userIdSend = mensaje['userIdSend'];
    _userReportadoPor = mensaje['incidente']['userName'];
    _responsable = mensaje['incidente']['userNameTo'];
    _nombreObra = mensaje['obraName'];
    _asunto = mensaje['subject'];
    _incidente = json.decode(mensaje['incidente']['data'])['reporteCompleto']; 
    print(_incidente[0]['formPrincipal'][0]['value']);
    _valorTitulo = int.parse(_incidente[0]['formPrincipal'][0]['value']);    
    _tituloIncidente = _incidente[0]['formPrincipal'][0]['list'][_valorTitulo-1]['title'];     
    _isAtrasado = mensaje['isAtrasado'];
  }

  String get body => _body;
  List get incidente => _incidente;
  int get userId => _userId;
  int get incidentId => _incidenteId;
  int get threadId => _threadId;
  int get estadoMensaje => _estadoMensaje;
  int get parentMessageId => _parentMessageId;
  int get createDate => _createDate;
  int get gravedad => _gravedad;
  String get userSend => _userSend;
  String get asunto => _asunto;
  String get tituloIncidente => _tituloIncidente;
  String get responsable => _responsable;
  String get nombreObra => _nombreObra;
  int get locationId => _locationId;
  String get estadoIncidente => _estadoIncidente;
  String get subject => _subject;
  int get messageId => _messageId;
  String get userReportadoPor => _userReportadoPor;
  int get  userIdSend =>  _userIdSend;
  bool get cerrado => _cerrado;
  bool get isAtrasado => _isAtrasado;

}
