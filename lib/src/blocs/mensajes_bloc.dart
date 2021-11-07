import '../resources/repositorio.dart';
import 'package:rxdart/rxdart.dart';
import '../models/mensajes_model.dart';
import 'package:inject/inject.dart';
import 'bloc_base.dart';

class MensajesBloc extends BlocBase {
  final Repository _repository;
  PublishSubject<MensajesModel> _mensajesFetcher;

  @provide 
  MensajesBloc(this._repository);

  init() {
    _mensajesFetcher = PublishSubject<MensajesModel>();
  }

  Observable<MensajesModel> get allMensajes => _mensajesFetcher.stream;

  fetchListaMensajes() async {    
    MensajesModel mensajesModel = await _repository.fetchMensajes();
    _mensajesFetcher.sink.add(mensajesModel);
  }

  
  @override 
  dispose() {
    _mensajesFetcher.close();    
  }
}

