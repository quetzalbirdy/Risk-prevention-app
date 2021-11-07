import '../resources/repositorio.dart';
import 'package:rxdart/rxdart.dart';
import '../models/obras_model.dart';
import 'package:inject/inject.dart';
import 'bloc_base.dart';

class ObrasBloc extends BlocBase {
  final Repository _repository;
  PublishSubject<ObrasModel> _obrasFetcher;

  @provide 
  ObrasBloc(this._repository);

  init() {
    _obrasFetcher = PublishSubject<ObrasModel>();
  }

  Observable<ObrasModel> get allObras => _obrasFetcher.stream;

  fetchListalObras() async {    
    ObrasModel obrasModel = await _repository.fetchTodasObras();
    _obrasFetcher.sink.add(obrasModel);
  }

  
  @override 
  dispose() {
    _obrasFetcher.close();    
  }
}

