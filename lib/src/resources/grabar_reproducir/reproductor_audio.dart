import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data' show Uint8List;
import 'dart:io';
import 'package:intl/intl.dart' show DateFormat;

import 'package:path_provider/path_provider.dart';

class ReproductorAudio extends StatefulWidget {       

  final audioFile;
  final audioUrl;
  final int index;
  final VoidCallback onRemove;
  ReproductorAudio({Key key, this.audioFile, this.audioUrl, this.index, this.onRemove}) : super(key: key); 

  @override
  _ReproductorAudioState createState() => _ReproductorAudioState();
}

class _ReproductorAudioState extends State<ReproductorAudio> { 
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
  FlutterSoundPlayer playerModule = FlutterSoundPlayer();
  FlutterSoundRecorder recorderModule = FlutterSoundRecorder();
  bool _isAudioPlayer = false;
  IOSink sink;   
  double sliderCurrentPosition = 0.0;
  double maxDuration = 1.0;

  String _recorderTxt = '00:00:00';
    String _playerTxt = '00:00:00';
  double _dbLevel;

  bool _reproductorIniciado;
  bool _reproduciendo = false;


  @override
  void initState() {
    playerModule.openAudioSession().then((value) {
      setState(() {
        _reproductorIniciado = true;        
      });
    });
    super.initState();             
  }  

  @override
  void dispose() {
    playerModule.closeAudioSession();
    playerModule = null;
    super.dispose();    
  }   

  void playSonido() async {  
    _addListeners();  
    await playerModule.startPlayer(
      fromURI: widget.audioFile,
      codec: Codec.aacADTS,
      whenFinished: (){setState((){
        _reproduciendo = false;
      });}      
    );    
    setState(() {
      _reproduciendo = true;
    });
  }

  Future<void> stopSonido() async {
    if (playerModule != null) {
      await playerModule.stopPlayer();
    }
    setState(() {
      _reproduciendo = false;
    });
  }  

  void _addListeners() {       
    _playerSubscription = playerModule.onProgress.listen((e) {
      if (e != null) {
        maxDuration = e.duration.inMilliseconds.toDouble();
        if (maxDuration <= 0) maxDuration = 0.0;

        setState(() {
          sliderCurrentPosition = min(e.position.inMilliseconds.toDouble(), maxDuration);
        });
        if (sliderCurrentPosition < 0.0) {
          sliderCurrentPosition = 0.0;
        }

        DateTime date = new DateTime.fromMillisecondsSinceEpoch(
            e.position.inMilliseconds,
            isUtc: true);
        String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);
        this.setState(() {
          this._playerTxt = txt.substring(0, 8);
        });
      }
    });
  }
  

  void pauseResumePlayer() async {
    if (playerModule.isPlaying) {
     await  playerModule.pausePlayer();
    } else {
      await playerModule.resumePlayer();
    }
    setState(() {

    });
  }

  void seekToPlayer(int milliSecs) async {
    //print('-->seekToPlayer');
    if (playerModule.isPlaying)
        await playerModule.seekToPlayer(Duration(milliseconds: milliSecs));
    //print('<--seekToPlayer');
  }

  @override 
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(right: 10.0, top: 0.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.7,
            padding: EdgeInsets.only(bottom: 10.0,),
            margin: EdgeInsets.only(top: 15.0),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(7.0)
            ),
            child: Column(        
              children: <Widget>[  
                Container(                
                  child: Row(                
                    children: <Widget>[
                      Container(
                        width: 56.0,
                        height: 56.0,
                        child: ClipOval(
                          child: FlatButton(
                            onPressed: () {
                              playSonido();
                              stopSonido();
                            },
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.play_arrow, size: 30.0, color: _reproduciendo ? Colors.red : Colors.grey[200],),
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
                            child: Icon(Icons.stop, size: 30.0, color: Colors.grey[200],),
                          ),
                        ),
                      ),
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                  ),
                ),                  
              ],
            ),
          ),
        ),
        widget.onRemove != null ? Positioned(
          top: 0,
          right: 0,
          child: SizedBox(
            width: 25.0,
            height: 25.0,
            child: FloatingActionButton(
              heroTag: widget.index,
              backgroundColor: Colors.black,
              child: Icon(Icons.close, size: 15.0, color: Colors.white,),                          
              onPressed: () {
                widget.onRemove();
              }
            ),
          )
        ) : Container(height: 0.0,), 
        widget.index != null ? Positioned(
          top: 15.0,
          left: 0,
          child: Container(
            padding: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
            color: Colors.grey[600],
            borderRadius: BorderRadius.only(topLeft: Radius.circular(7.0)),
          ),                                        
            child: Text((widget.index + 1).toString(), style: TextStyle(color: Colors.white, fontSize: 20.0),),
          ),
        ) : Container(height: 0.0,)  
      ],
    );
  }
}