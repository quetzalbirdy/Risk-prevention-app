import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/* typedef ChangeMediosCallback = void Function(File archivoVideo); */

class ReproductorVideo extends StatefulWidget {

  final videoFile;    
  final videoUrl;  
  final VoidCallback onRemove;
  final index;
  ReproductorVideo({Key key, this.videoFile, this.videoUrl, this.index, this.onRemove}) : super(key: key);   

  @override
  _ReproductorVideoState createState() => _ReproductorVideoState();
}

class _ReproductorVideoState extends State<ReproductorVideo> {    

  
  VoidCallback videoPlayerListener;
  VoidCallback checkVideo;
  VideoPlayerController videoController;
  bool playing = false;      

  @override 
  void initState() {     
    startVideoPlayer();  
    print('videoFile');
    print(widget.videoFile);             
    super.initState();
  }  


  @override
  void dispose() {
    videoController.removeListener(() {});
    videoController.dispose();
    super.dispose(); 
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
        width: 105.0,                
        child: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 7.0, right: 7.0, left: 7.0),
              child: Card(              
                color: Colors.grey[800],
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    videoController.value.initialized
                  ? AspectRatio(
                      aspectRatio:videoController.value.aspectRatio,
                      child: VideoPlayer(videoController),
                    )
                  : Container(),
                    Center(
                      child: IconButton(
                        color: Colors.grey[200],
                        icon: Icon(
                        playing ? Icons.pause : Icons.play_arrow,
                        ),
                        onPressed: () {
                          videoController.value.isPlaying ?videoController.pause() :videoController.play();                                                                               
                          print(videoController.value.isPlaying);
                            setState(() {
                              videoController.value.isPlaying ? playing = true : playing = false;
                            });                       
                        },
                      ),
                    )
                  ],
                )
              ),
            ),
            widget.index != null ? Positioned(
              top: 0,
              right: 0,
              child: SizedBox(
                width: 25.0,
                height: 25.0,
                child: FloatingActionButton(
                  heroTag: widget.index,
                  backgroundColor: Colors.black,
                  child: Icon(Icons.close, size: 15.0, color: Colors.white,),                          
                  onPressed: () => widget.onRemove(),
                ),
              )
            ) : Container(height: 0.0,)
          ],
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