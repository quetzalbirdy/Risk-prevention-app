import 'dart:async';
import 'package:nuevo_riesgos/src/blocs/medios_local_event.dart';
import 'package:nuevo_riesgos/src/resources/proveedor_servicio_obras.dart';
import 'package:http/http.dart' show Client;

class VideosBLoc{
  Client client;

  List _videoFiles = [];        

  // init and get StreamController
  final _videosStreamController = StreamController<List>();
  StreamSink<List> get videos_sink => _videosStreamController.sink;

  // expose data from stream
  Stream<List> get stream_videos => _videosStreamController.stream;

  final _videosEventController = StreamController<AgregarVideos>();
  // expose sink for input events
  Sink <AgregarVideos> get videos_event_sink => _videosEventController.sink;

  VideosBLoc() {  _videosEventController.stream.listen(_agregarVideos);  }


  _agregarVideos(videoFile) async {
    String archivoVideo = await ServiciosConecta(client).actualizarVideos(videoFile);
    _videoFiles.add(archivoVideo);
    videos_sink.add(_videoFiles);
  }

  dispose(){
    _videosStreamController.close();
    _videosEventController.close();
  }
}