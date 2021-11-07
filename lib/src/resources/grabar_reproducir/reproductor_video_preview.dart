import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/* typedef ChangeMediosCallback = void Function(File archivoVideo); */

class ReproductorVideoPreview extends StatefulWidget {

  final videoFile;  
  final videoUrl;      
  final VoidCallback onRemove;
  final index;
  ReproductorVideoPreview({Key key, this.videoFile, this.index, this.onRemove, this.videoUrl}) : super(key: key);   

  @override
  _ReproductorVideoPreviewState createState() => _ReproductorVideoPreviewState();
}

class _ReproductorVideoPreviewState extends State<ReproductorVideoPreview> {    

  
  VoidCallback videoPlayerListener;
  VoidCallback checkVideo;
  VideoPlayerController videoController;
  bool playing = false;      

  @override 
  void initState() {    
    print('videoFile');
    print(widget.videoFile);  
    print(widget.videoUrl);  
    startVideoPlayer();               
    super.initState();
  }  


  @override
  void dispose() {
    super.dispose();   
    videoController.removeListener(() {});
    videoController.dispose();    
  }  

  /* void onChangeMedios(index) {
    Medios().videoFiles.removeAt(index);  
    /* videoController.removeListener(() {});
    videoController.dispose();          
    startVideoPlayer();    */      
  } */

  Future<void> startVideoPlayer() async {
    if (widget.videoFile != null || widget.videoUrl != null) {
      VideoPlayerController vcontroller;
      if (widget.videoFile != null) {
        setState(() {
          vcontroller = VideoPlayerController.file(widget.videoFile);
        });
      } else if (widget.videoUrl != null) {
        setState(() {
          vcontroller = VideoPlayerController.network(widget.videoUrl);
        });
      }
      videoPlayerListener = () {
        if (videoController != null && videoController.value.size != null) {
          // Refreshing the state to update video player with the correct ratio.
          if (mounted) setState(() {});
          videoController.removeListener(videoPlayerListener);
        }
      };    
      checkVideo = () {
        if(vcontroller.value.position == Duration(seconds: 0, minutes: 0, hours: 0)){
              print('video Started');
            }

        if(vcontroller.value.position == vcontroller.value.duration){
          vcontroller.removeListener(checkVideo);
          vcontroller.pause();
          vcontroller.seekTo(Duration(seconds: 0, minutes: 0, hours: 0));
          vcontroller.addListener(checkVideo);  
          setState(() {
            playing = false;
          });
          print('video end');            
        }
      };
      vcontroller.addListener(checkVideo);    
      vcontroller.addListener(videoPlayerListener);
      await vcontroller.setLooping(false);
      await vcontroller.initialize();
      await videoController?.dispose();
      if (mounted) {
        setState(() {            
          videoController = vcontroller;
        });
      }
      print(vcontroller);          
    }       
  }  

  @override 
  Widget build(BuildContext context) {
    return videoController != null ? Container(
      padding: EdgeInsets.only(top: 0.0, bottom: 0.0),
      child: Container(        
        width: 130.0,    
        height: 130.0,            
        child: Card(              
          color: Colors.grey[800],
          child: videoController.value.initialized
            ? FittedBox(
                child: SizedBox(
                  width: videoController.value.aspectRatio,
                  height: 1,
                  child: VideoPlayer(videoController),
                ), 
                fit: BoxFit.cover
              )
            : Container(), 
        ),
      ),
    ) : Container(
      alignment: Alignment.center,
      height: 200.0,
      width: 100.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Container(  
              alignment: Alignment.center,            
              height: 50.0,
              width: 50.0,
              child: CircularProgressIndicator(),
            ),
          )
        ],
      )
    );
  }
}