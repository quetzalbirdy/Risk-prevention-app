import '../resources/repositorio.dart';
import 'package:rxdart/rxdart.dart';
import '../models/medios_model.dart';
import 'package:inject/inject.dart';
import 'bloc_base.dart';

class MediosBloc extends BlocBase {
  final Repository _repository;
  PublishSubject<MediosModel> _mediosFetcher;
  

  @provide 
  MediosBloc(this._repository);

  init() {
    _mediosFetcher = PublishSubject<MediosModel>();
  }

  Observable<MediosModel> get allMedios => _mediosFetcher.stream;

  fetchMedios(incidentId) async {    
    MediosModel mediosModel = await _repository.fetchMedios(incidentId.toString());
    _mediosFetcher.sink.add(mediosModel);
  }

  
  @override 
  dispose() {
    _mediosFetcher.close();    
  }
}

