class Medios {
  static Medios _instance = Medios._internal();
  factory Medios() => _instance;
  
  Medios._internal() {
    _instance = this;
  }
  List imageList = [];  
  List videoFiles = [];      
  List audioFiles = [];

  List imageListEvidenciaResolutiva = [];  
  List videoFilesEvidenciaResolutiva = [];        
}
