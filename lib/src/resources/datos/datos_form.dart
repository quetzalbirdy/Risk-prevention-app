class DatosForm {
  static DatosForm _instance = DatosForm._internal();
  factory DatosForm() => _instance;
  
  DatosForm._internal();
  Map<String, dynamic> formPrincipal;
  Map<String, dynamic> formAvanzdo;
  Map<String, dynamic> agregarInformacion;
  Map<String, dynamic> formEstado;
  Map<String, dynamic> formComunicar1;
  Map<String, dynamic> formComunicar2;
  List formCompleto;
}
