import '../resources/repositorio.dart';
import 'package:rxdart/rxdart.dart';
import '../models/incidentes_model.dart';
import 'package:inject/inject.dart';
import 'bloc_base.dart';

class IncidentesBloc extends BlocBase {
  final Repository _repository;
  PublishSubject<IncidentesModel> _incidentesFetcher;

  @provide 
  IncidentesBloc(this._repository);

  init() {
    _incidentesFetcher = PublishSubject<IncidentesModel>();
  }

  Observable<IncidentesModel> get allIncidentes => _incidentesFetcher.stream;

  fetchIncidentes() async {    
    IncidentesModel incidentesModel = await _repository.fetchIncidentes();
    _incidentesFetcher.sink.add(incidentesModel);
  }

  
  @override 
  dispose() {
    _incidentesFetcher.close();    
  }
}

