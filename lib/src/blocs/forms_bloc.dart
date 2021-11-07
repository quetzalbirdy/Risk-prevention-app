import '../resources/repositorio.dart';
import 'package:rxdart/rxdart.dart';
import '../models/forms_model.dart';
import 'package:inject/inject.dart';
import 'bloc_base.dart';

class FormsBloc extends BlocBase {
  final Repository _repository;
  PublishSubject<FormsModel> _formsFetcher;

  @provide 
  FormsBloc(this._repository);

  init() {
    _formsFetcher = PublishSubject<FormsModel>();
  }

  Observable<FormsModel> get allForms => _formsFetcher.stream;

  fetchForms() async {    
    FormsModel formsModel = await _repository.fetchFormularios();
    _formsFetcher.sink.add(formsModel);
  }

  
  @override 
  dispose() {
    _formsFetcher.close();    
  }
}

