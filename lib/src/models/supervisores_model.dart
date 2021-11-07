class SupervisoresModel {
  int _code;     
  List<_Supervisor> _supervisores = [];

  SupervisoresModel.fromJson(Map<String, dynamic> parsedJson) {
    /* print(parsedJson['body'].length); */      
    _code = parsedJson['code'];   
    List<_Supervisor> temp = [];
    for (int i = 0; i < parsedJson['body'].length; i++) {            
      _Supervisor supervisor = _Supervisor(parsedJson['body'][i]);
      temp.add(supervisor);
    }
    _supervisores = temp;
  }

  List<_Supervisor> get supervisores => _supervisores;

  int get code => _code;
}

class _Supervisor {
  String _firstName;
  String _lastName;  
  int _userId;  


  _Supervisor(supervisor) {
    _firstName = supervisor['firstName'];
    _lastName = supervisor['lastName'];
    _userId = supervisor['userId'];    
  }

  String get firstName => _firstName;
  String get lastName => _lastName;  
  int get userId => _userId; 
}
