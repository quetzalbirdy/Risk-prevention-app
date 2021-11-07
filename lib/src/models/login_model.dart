class LoginModel {
  int _code;     
  int _companyId;
  int _groupId;
  int _userId;
  String _name;
  String _userName;

  LoginModel.fromJson(Map<String, dynamic> parsedJson) {    
    _code = parsedJson['code']; 
    _companyId = parsedJson['body']['companyId'];
    _groupId = parsedJson['body']['groupId'];
    _userId = parsedJson['body']['userId'];  
    _name = parsedJson['body']['name'];
    _userName = parsedJson['body']['userName'];
  }

  int get code => _code;
  int get companyId => _companyId;
  int get groupId => _groupId;
  int get userId => _userId;
  String get name => _name;
  String get userName => _userName;
}
