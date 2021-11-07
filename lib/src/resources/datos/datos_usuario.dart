import 'package:geolocator/geolocator.dart';

class DatosUsuario {
  static DatosUsuario _instance = DatosUsuario._internal();
  factory DatosUsuario() => _instance;
  
  DatosUsuario._internal();
  String userName;
  String userId;
  String password;

  int locationId;
  int gravedad;
  int tipoIncidente;
  String fechaIncidente;

  String nombreObraActual;  
  Position ubicacionActual;  

  bool valorActivos;
  String filtroObra;
  String filtroGravedad;
}
