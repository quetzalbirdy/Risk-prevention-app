import 'package:inject/inject.dart';
import 'package:nuevo_riesgos/src/resources/repositorio.dart';
import 'bloc_injector.inject.dart' as g;
import '../app.dart';
import 'bloc_module.dart';

@Injector(const [BlocModule])
abstract class BlocInjector{
  @provide
  MyApp get app;

  @provide
  Repository get repository;

  static final create = g.BlocInjector$Injector.create;
}