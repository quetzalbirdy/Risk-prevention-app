import '../resources/repositorio.dart';
import 'package:rxdart/rxdart.dart';
import '../models/login_model.dart';
import 'package:inject/inject.dart';
import 'bloc_base.dart';

class LoginBloc extends BlocBase {
  final Repository _repository;
  PublishSubject<LoginModel> _loginFetcher;

  @provide 
  LoginBloc(this._repository);

  init() {
    _loginFetcher = PublishSubject<LoginModel>();
  }

  Observable<LoginModel> get login => _loginFetcher.stream;

  fetchLogin() async {    
    /* LoginModel loginModel = await _repository.fetchLogin(); */
    /* _loginFetcher.sink.add(loginModel); */
  }

  
  @override 
  dispose() {
    _loginFetcher.close();    
  }
}

