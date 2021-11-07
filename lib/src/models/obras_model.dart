class ObrasModel {
  int _code;     
  List<_Obra> _obras = [];

  ObrasModel.fromJson(Map<String, dynamic> parsedJson) {
    /* print(parsedJson['body'].length); */      
    _code = parsedJson['code'];   
    List<_Obra> temp = [];
    for (int i = 0; i < parsedJson['body'].length; i++) {
      _Obra obra = _Obra(parsedJson['body'][i]);
      temp.add(obra);
    }
    _obras = temp;
  }

  List<_Obra> get obras => _obras;

  int get code => _code;
}

class _Obra {
  String _nombreObra;
  int _locationIdObra;

  _Obra(obra) {
    _nombreObra = obra['name'];
    _locationIdObra = obra['locationId'];
  }

  String get obra => _nombreObra;
  int get locationIdObra => _locationIdObra;
}
