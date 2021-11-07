import 'dart:async';
import 'package:nuevo_riesgos/src/models/incidentes_model.dart';
import 'package:nuevo_riesgos/src/models/mensajes_model.dart';

import '../resources/proveedor_servicio_obras.dart';
import '../models/obras_model.dart';
import '../models/forms_model.dart';
import '../models/medios_model.dart';
import 'package:inject/inject.dart';
import 'package:nuevo_riesgos/src/resources/constantes.dart' as constantes;

class Repository {
  final ServiciosConecta serviciosConecta;    
  final urlServicios = constantes.urlBase; 

  @provide 
  Repository(this.serviciosConecta);

  Future<ObrasModel> fetchTodasObras() => serviciosConecta.fetchListaObras('', 'true', 'http://$urlServicios/api/jsonws/vs-bpm-screen-portlet.customize/get-list-obras');

  Future<FormsModel> fetchFormularios() => serviciosConecta.fetchFormularios('true', 'formPrincipal', 'formAgregarInfo', 'http://$urlServicios/api/jsonws/vs-bpm-screen-portlet.formularioapp/get-form');  
  
  Future<IncidentesModel> fetchIncidentes() => serviciosConecta.fetchIncidentes('false', 'http://$urlServicios/api/jsonws/vs-bpm-screen-portlet.incidente/get-list-by-incidente-user');  
  
  Future<MediosModel> fetchMedios(incidentId) => serviciosConecta.fetchMedios(incidentId, '$urlServicios', 'http://$urlServicios/api/jsonws/vs-bpm-screen-portlet.incidente/get-file-by-incidente-id');  

  Future<MensajesModel> fetchMensajes() => serviciosConecta.fetchMensajes('http://$urlServicios/api/jsonws/vs-bpm-screen-portlet.incidente/get-message-by-user');    

  /* Future<LoginModel> fetchLogin() => serviciosConecta.fetchLogin('223645', '25754', 'false', 'http://$urlServicios/api/jsonws/vs-bpm-screen-portlet.app/login');   */
}