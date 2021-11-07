class MediosModel {
  int _code;     
  List<_Medio> _medios = [];
  List _imagenes = [];
  List _videos = [];
  List _audios = [];

  MediosModel.fromJson(Map<String, dynamic> parsedJson) {
    print(parsedJson);
    _code = parsedJson['code'];   
    List<_Medio> temp = [];
    for (int i = 0; i < parsedJson['body'].length; i++) {
      _Medio medio = _Medio(parsedJson['body'][i]);    
      if (medio.extensionMedio == 'jpg') {
        _imagenes.add(medio.urlMedio);
      } else if (medio.extensionMedio == 'aac') {
        _audios.add(medio.urlMedio);
      } else if (medio.extensionMedio == 'mp4') {
        _videos.add(medio.urlMedio);
      }  
      temp.add(medio);      
    }
    _medios = temp;
  }

  List<_Medio> get medios => _medios;
  int get code => _code;
  List get audios => _audios;
  List get videos => _videos;
  List get imagenes => _imagenes;
}

class _Medio {  
  String _url;  
  String _extension;  

  _Medio(medio) {             
    _extension = medio['extension'];    
    _url = medio['url'];        
  }

  String get extensionMedio => _extension;
  String get urlMedio => _url;   
}
