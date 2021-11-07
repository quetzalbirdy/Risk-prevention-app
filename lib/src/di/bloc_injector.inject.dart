import 'bloc_injector.dart' as _i1;
import 'bloc_module.dart' as _i2;
import 'package:http/src/client.dart' as _i3;
import '../resources/proveedor_servicio_obras.dart' as _i4;
import '../resources/repositorio.dart' as _i5;
import 'dart:async' as _i6;
import '../app.dart' as _i7;
import '../blocs/obras_bloc.dart' as _i8;
import '../blocs/forms_bloc.dart' as _i9;
import '../blocs/incidentes_bloc.dart' as _i10;
import '../blocs/login_bloc.dart' as _i11;
import '../blocs/medios_bloc.dart' as _i12;
import '../blocs/mensajes_bloc.dart' as _i13;

class BlocInjector$Injector implements _i1.BlocInjector {
  BlocInjector$Injector._(this._blocModule);

  final _i2.BlocModule _blocModule;

  _i3.Client _singletonClient;

  _i4.ServiciosConecta _singletonServiciosConecta;

  _i5.Repository _singletonRepository;

  static _i6.Future<_i1.BlocInjector> create(_i2.BlocModule blocModule) async {
    final injector = BlocInjector$Injector._(blocModule);

    return injector;
  }

  _i7.MyApp _createMyApp() => _i7.MyApp(
      _createObrasBloc(),
      _createFormsBloc(),
      _createIncidentesBloc(),
      _createLoginBloc(),
      _createMediosBloc(),
      _createMensajesBloc());
  _i8.ObrasBloc _createObrasBloc() => _i8.ObrasBloc(_createRepository());
  _i5.Repository _createRepository() => _singletonRepository ??=
      _blocModule.repository(_createServiciosConecta());
  _i4.ServiciosConecta _createServiciosConecta() =>
      _singletonServiciosConecta ??=
          _blocModule.serviciosConecta(_createClient());
  _i3.Client _createClient() => _singletonClient ??= _blocModule.client();
  _i9.FormsBloc _createFormsBloc() => _i9.FormsBloc(_createRepository());
  _i10.IncidentesBloc _createIncidentesBloc() =>
      _i10.IncidentesBloc(_createRepository());
  _i11.LoginBloc _createLoginBloc() => _i11.LoginBloc(_createRepository());
  _i12.MediosBloc _createMediosBloc() => _i12.MediosBloc(_createRepository());
  _i13.MensajesBloc _createMensajesBloc() =>
      _i13.MensajesBloc(_createRepository());
  @override
  _i7.MyApp get app => _createMyApp();
  @override
  _i5.Repository get repository => _createRepository();
}
