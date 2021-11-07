import 'dart:io';
import 'package:flutter/material.dart';
/* import 'package:flutter_sound_lite/flutter_sound.dart'; */
import 'package:flutter_sound_lite/public/flutter_sound_player.dart';
import 'package:flutter_sound_lite/public/flutter_sound_recorder.dart';
import 'package:flutter_sound_lite/public/tau.dart';

import 'package:intl/intl.dart' show DateFormat;
import 'package:intl/date_symbol_data_local.dart';

import 'dart:async';
import 'package:nuevo_riesgos/src/resources/datos/medios.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data' show Uint8List;
import 'package:permission_handler/permission_handler.dart';

class GrabarAudio extends StatefulWidget {
  final onStopGrabar;
  GrabarAudio({Key key, this.onStopGrabar}) : super(key: key);

  @override
  _GrabarAudioState createState() => _GrabarAudioState();
}

class _GrabarAudioState extends State<GrabarAudio> {
  bool _isRecording = false;
  String _path;

  // bool _isPlaying = false;
  StreamSubscription _recorderSubscription;
  StreamSubscription _dbPeakSubscription;
  StreamSubscription _playerSubscription;
  StreamSubscription _recordingDataSubscription;
  double _duration = null;
  StreamController<Food> recordingDataController;
  /* FlutterSound flutterSound; */
  FlutterSoundPlayer _reproductor = FlutterSoundPlayer();
  FlutterSoundRecorder _grabador = FlutterSoundRecorder();
  bool _reproductorIniciado;
  bool _grabadorIniciado;
  bool _isAudioPlayer = false;
  IOSink sink;   

  String _recorderTxt = Platform.isIOS ? 'Grabar' : '00:00:00';
  String _playerTxt = '00:00:00';
  double _dbLevel;

  String audioFileLocal;

  double sliderCurrentPosition = 0.0;
  double maxDuration = 1.0;

  String filePath;  
  Timer _timer;
  bool _show = true;

  @override
  void initState() {    
    _reproductor.openAudioSession().then((value) {
      setState(() {
        _reproductorIniciado = true;
      });
    });
    abrirGrabador().then((value) {
      setState(() {        
        _grabadorIniciado = true;
      });
    });
    recordPermission();
    _timer = Timer.periodic(Duration(milliseconds: 500), (_) {
      setState(() => _show = !_show);
    });
    super.initState();
  }

  @override
  void dispose() {
    _reproductor.closeAudioSession();
    _reproductor = null;
    _grabador.closeAudioSession();
    _grabador = null;
    super.dispose();    
  }  

  recordPermission() async {
    await Permission.microphone.request();
  }

  Future<void> abrirGrabador() async {
    final Directory appDirectory = await getApplicationDocumentsDirectory();
    String audioDirectory = '${appDirectory.path}/Audios';            
    await Directory(audioDirectory).create(recursive: true);
    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    filePath = '$audioDirectory/$currentTime.aac';  
    var outputFile = File(filePath);
    if (outputFile.existsSync()) {
      await outputFile.delete();
    }
    await _grabador.openAudioSession(
      device: AudioDevice.speaker
    );
    setState(() {
      _grabadorIniciado = true;
    });
  }

  void playSonido() async {
    audioFileLocal = _path;
    await _reproductor.startPlayer(
      fromURI: audioFileLocal,
      codec: Codec.aacADTS,
      whenFinished: (){setState((){});}
    );
    setState(() {});
  }

  Future<void> stopSonido() async {
    if (_reproductor != null) {
      await _reproductor.stopPlayer();
    }
  }

  Future<void> grabar() async {
    /* final Directory appDirectory = await getApplicationDocumentsDirectory();
    String audioDirectory = '${appDirectory.path}/Audios';            
    await Directory(audioDirectory).create(recursive: true);
    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    final String filePath = '$audioDirectory/$currentTime.aac';   */
    if (await Permission.microphone.isDenied) {
      await Permission.microphone.request();
    }    
    assert(_grabadorIniciado && _reproductor.isStopped);
    try {
      await _grabador.startRecorder(        
        toFile: filePath,
        codec: Codec.aacADTS,
      );

      setState(() {
        _isRecording = true;
        _path = filePath;      
      });
      print('esta grabando $_isRecording');      
      _grabador.onProgress.listen((e) {
        print('hola');
        print('evento $e');
        if (e != null && e.duration != null) {
          DateTime date = new DateTime.fromMillisecondsSinceEpoch(
              e.duration.inMilliseconds,
              isUtc: true);
          String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);

          this.setState(() {            
            _recorderTxt = txt.substring(0, 8);
            print('tiempo $_recorderTxt');
            _dbLevel = e.decibels;
          });
        }
      });
    } catch(err) {
      print('startRecorder error: $err');
    }
  }


  Future<void> stopGrabar() async {
    await _grabador.stopRecorder();
    Medios().audioFiles.add(_path);     
    audioFileLocal = _path;      
    print('resultado local $audioFileLocal');
    setState(() {
      _isRecording = false;
    });    
    widget.onStopGrabar();
    Navigator.pop(context);   
  }

  /* void _addListeners() {    
    _playerSubscription = _grabador.onProgress.listen((e) {
      if (e != null) {
        maxDuration = e.duration.inMilliseconds.toDouble();
        if (maxDuration <= 0) maxDuration = 0.0;

        sliderCurrentPosition =
            min(e.position.inMilliseconds.toDouble(), maxDuration);
        if (sliderCurrentPosition < 0.0) {
          sliderCurrentPosition = 0.0;
        }

        DateTime date = new DateTime.fromMillisecondsSinceEpoch(
            e.inMilliseconds,
            isUtc: true);
        String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);
        this.setState(() {
          this._playerTxt = txt.substring(0, 8);
        });
      }
    });
  } */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Grabar '),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 24.0, bottom: 0.0),
                  child: Text(
                    _isRecording && Platform.isIOS ? 'Grabando' : _recorderTxt,
                    style: TextStyle(
                      fontSize: Platform.isIOS ? 30.0 : 48.0,
                      color: Platform.isIOS && _isRecording ? (_show ? Colors.black : Colors.transparent) : Colors.black,
                    ),
                  ),
                ),               
              ],
            ),
            Row(
              children: <Widget>[
                Container(
                  /* width: 56.0,
                  height: 56.0, */
                  child: ClipOval(
                    child: FlatButton(
                      onPressed: () {
                        if (!_isRecording) {
                          return grabar();
                        }
                        stopGrabar();                        
                      },
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        size: 50.0,
                        color: _isRecording ? Colors.red : Colors.black
                      ),
                    ),
                  ),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
            /* Medios().audioFiles.length > 0 ? 
            /* ReproductorAudio(audioFile: audioFileLocal, key: UniqueKey(),)
            : Container(height: 0.0,) */
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: EdgeInsets.only(bottom: 10.0),
              margin: EdgeInsets.only(top: 15.0),
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
                borderRadius: BorderRadius.circular(7.0)
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 56.0,
                        height: 56.0,
                        child: ClipOval(
                          child: FlatButton(
                            onPressed: () {
                              playSonido();
                            },
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.play_arrow, size: 30.0,),
                          ),
                        ),
                      ),
                      Container(
                        width: 56.0,
                        height: 56.0,
                        child: ClipOval(
                          child: FlatButton(
                            onPressed: () {
                              stopSonido();
                            },
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.stop, size: 30.0,),
                          ),
                        ),
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                  ),
                  /* Container(
                    height: 26.0,
                    child: Slider(
                      value: sliderCurrentPosition,
                      min: 0.0,
                      max: maxDuration,
                      onChanged: (double value) async {
                        /* await flutterSound.seekToPlayer(value.toInt()); */
                      },
                      divisions: maxDuration.toInt())
                  ) */
                ],
              ),
            ) : Container(height: 0.0,) */
          ],
        ),
      ),
    );
  }
}
