import 'package:inject/inject.dart';
import 'package:nuevo_riesgos/src/blocs/bloc_base.dart';
import 'package:nuevo_riesgos/src/blocs/forms_bloc.dart';
import 'package:nuevo_riesgos/src/blocs/incidentes_bloc.dart';
import 'package:nuevo_riesgos/src/blocs/medios_bloc.dart';
import 'package:nuevo_riesgos/src/blocs/mensajes_bloc.dart';
import '../blocs/obras_bloc.dart';
import '../resources/repositorio.dart';
import '../resources/proveedor_servicio_obras.dart';
import 'package:http/http.dart' show Client;

@module
class BlocModule{

  @provide
  @singleton
  Client client() => Client();

  @provide
  @singleton
  ServiciosConecta serviciosConecta(Client client) => ServiciosConecta(client);

  @provide
  @singleton
  Repository repository(ServiciosConecta serviciosConecta) => Repository(serviciosConecta);

  @provide
  BlocBase obraBloc(Repository repository) => ObrasBloc(repository);

  @provide
  BlocBase formsBloc(Repository repository) => FormsBloc(repository);

  @provide
  BlocBase incidentesBloc(Repository repository) => IncidentesBloc(repository);
  
  @provide
  BlocBase mediosBloc(Repository repository) => MediosBloc(repository);

  @provide
  BlocBase mensajesBloc(Repository repository) => MensajesBloc(repository);
  
}