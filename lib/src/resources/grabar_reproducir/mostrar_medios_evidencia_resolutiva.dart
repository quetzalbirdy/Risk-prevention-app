import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nuevo_riesgos/src/resources/grabar_reproducir/reproductor_video.dart';
import 'package:nuevo_riesgos/src/resources/datos/medios.dart';
import 'package:nuevo_riesgos/src/resources/grabar_reproducir/grabar_sonido.dart';
import 'package:nuevo_riesgos/src/resources/grabar_reproducir/reproductor_audio.dart';
import 'package:nuevo_riesgos/src/resources/grabar_reproducir/reproductor_video_preview.dart';
import 'package:nuevo_riesgos/src/ui/editar_medios.dart';
import 'package:nuevo_riesgos/src/ui/editar_medios_evidencia_resolutiva.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path/path.dart' as path;

class MostrarMediosEvidenciaResolutiva extends StatefulWidget {
  @override
  _MostrarMediosEvidenciaResolutivaState createState() => _MostrarMediosEvidenciaResolutivaState();
}

class _MostrarMediosEvidenciaResolutivaState extends State<MostrarMediosEvidenciaResolutiva> {
  
  void _getImage( _image) {
    setState(() {
      Medios().imageListEvidenciaResolutiva.add(_image);
      print(Medios().imageListEvidenciaResolutiva);
    });
  }

  void _getVideo( _video) {
    setState(() {
      Medios().videoFilesEvidenciaResolutiva.add(_video);      
    });
  }

  void _mostrarDialogAgregarMedios() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(          
          content: Text('Agrega medios para poder editarlos'),
          actions: <Widget>[            
            MaterialButton(
              minWidth: 90.0,
              child: Text('Ok'),
              shape: StadiumBorder(),
                    textColor: Colors.white,
                    color: Theme.of(context).accentColor,
                    elevation: 1.0,
              onPressed: () {
                Navigator.pop(context);
              },
            ),                        
          ],
        );
      }
    );
  }

  void _mostrarNombre(nombre) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(          
          content: Text(nombre),
          actions: <Widget>[            
            MaterialButton(
              minWidth: 90.0,
              child: Text('Ok'),
              shape: StadiumBorder(),
                    textColor: Colors.white,
                    color: Theme.of(context).accentColor,
                    elevation: 1.0,
              onPressed: () {
                Navigator.pop(context);
              },
            ),                        
          ],
        );
      }
    );
  }

  void _elegirFuenteImagenes() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(          
          content: Text('Selecciona desde donde quieres agregar la imagen'),
          actions: <Widget>[            
            MaterialButton(
              minWidth: 90.0,
              child: Row(
                children: <Widget>[
                  Padding(child: Icon(Icons.folder, color: Colors.white), padding: EdgeInsets.only(right: 5.0),),
                  Text('Desde carpetas')
                ],
              ),                            
              shape: StadiumBorder(),
                    textColor: Colors.white,
                    color: Theme.of(context).accentColor,
                    elevation: 1.0,
              onPressed: () async {
                final picker = ImagePicker();
                final pickedFile = await picker.getImage(
                  /* maxWidth: 1000,
                  maxHeight: 1000, */
                  source: ImageSource.gallery,
                  /* imageQuality: 80,       */                  
                );                
                if (pickedFile != null) {
                  File _image = File(pickedFile.path);
                  _getImage(_image);
                }  
                Navigator.pop(context);
              },
            ),
            MaterialButton(
              minWidth: 90.0,
              child: Row(
                children: <Widget>[
                  Padding(child: Icon(Icons.camera_alt, color: Colors.white), padding: EdgeInsets.only(right: 5.0),),
                  Text('Desde camara')
                ],
              ),
              shape: StadiumBorder(),
                    textColor: Colors.white,
                    color: Theme.of(context).accentColor,
                    elevation: 1.0,
              onPressed: () async {
                final picker = ImagePicker();
                final pickedFile = await picker.getImage(
                 /*  maxWidth: 1000,
                  maxHeight: 1000, */
                  source: ImageSource.camera,
                  /* imageQuality: 80,   */                      
                );                
                if (pickedFile != null) {
                  File _image = File(pickedFile.path);
                  _getImage(_image);
                }  
                Navigator.pop(context);
              },
            ),                        
          ],
        );
      }
    );
  } 
  void _elegirFuenteVideos() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(          
          content: Text('Selecciona desde donde quieres agregar el video'),
          actions: <Widget>[            
            MaterialButton(
              minWidth: 90.0,
              child: Row(
                children: <Widget>[
                  Padding(child: Icon(Icons.folder, color: Colors.white), padding: EdgeInsets.only(right: 5.0),),
                  Text('Desde carpetas')
                ],
              ),                            
              shape: StadiumBorder(),
                    textColor: Colors.white,
                    color: Theme.of(context).accentColor,
                    elevation: 1.0,
              onPressed: () async {
                final picker = ImagePicker();
                final pickedFile = await picker.getVideo(                  
                  source: ImageSource.gallery,                                                          
                );                
                if (pickedFile != null) {  
                  var fileName;        
                  if (pickedFile.path.contains('.mov') || pickedFile.path.contains('.MOV')) {
                    fileName = File(pickedFile.path).renameSync(pickedFile.path.replaceAll('mov', 'mp4').toString());
                  } else {  
                    fileName = File(pickedFile.path);          
                  }                   
                  File _video = fileName;                    
                  _getVideo(_video);
                }  
                Navigator.pop(context);
              },
            ),
            MaterialButton(
              minWidth: 90.0,
              child: Row(
                children: <Widget>[
                  Padding(child: Icon(Icons.videocam, color: Colors.white), padding: EdgeInsets.only(right: 5.0),),
                  Text('Desde camara')
                ],
              ),
              shape: StadiumBorder(),
                    textColor: Colors.white,
                    color: Theme.of(context).accentColor,
                    elevation: 1.0,
              onPressed: () async {
                final picker = ImagePicker();
                final pickedFile = await picker.getVideo(                  
                  source: ImageSource.camera,                                                          
                );                
                if (pickedFile != null) {  
                  var fileName;        
                  if (path.extension(pickedFile.path) == '.mov' || pickedFile.path.contains('.MOV')) {
                    fileName = File(pickedFile.path).renameSync(pickedFile.path.replaceAll('mov', 'mp4').toString());
                    fileName = File(pickedFile.path).renameSync(pickedFile.path.replaceAll('MOV', 'mp4').toString());
                  } else {  
                    fileName = File(pickedFile.path);          
                  }                   
                  File _video = fileName;                            
                  print('file names: $_video');                
                  _getVideo(_video);
                }  
                Navigator.pop(context);
              },
            ),                        
          ],
        );
      }
    );
  }  

  bool descargandoMedioLocal = false;

  @override 
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center, 
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 15.0),
                    child: IconButton(
                      icon: Icon(Icons.add_a_photo, size: 40.0,),
                      color: Theme.of(context).accentColor,
                      onPressed: () async {
                        /* File _image = await ImagePicker.pickImage(
                          maxWidth: 1000,
                          maxHeight: 1000,
                          source: ImageSource.camera,
                          imageQuality: 80,                        
                        );
                        if (_image != null) {
                          _getImage(_image);
                        }      */                                                      
                        _elegirFuenteImagenes();
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20.0, left: 15.0),
                    child: IconButton(
                      padding: EdgeInsets.only(right: 10.0),
                      icon: Icon(Icons.video_call, size: 55.0),
                      color: Theme.of(context).accentColor,
                      onPressed: () async {
                        _elegirFuenteVideos();
                      }
                    ),
                  ),
                  /* Padding(
                    padding: EdgeInsets.only(top: 25.0, left: 10.0),
                    child: IconButton(
                      padding: EdgeInsets.only(right: 0.0),
                      icon: Icon(Icons.mic, size: 40.0,),
                      color: Theme.of(context).accentColor,
                      onPressed: () {                                
                        Navigator.push(
                          context, 
                          PageTransition(type: PageTransitionType.rightToLeft, child: GrabarAudioEvidenciaResolutiva(onStopGrabar: () => {
                            setState(() {})
                          },)),
                        );                                
                      },
                    ),
                  ), */
                ],
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 25.0, left: 10.0),
                    child: IconButton(
                      padding: EdgeInsets.only(right: 0.0),
                      icon: Icon(Icons.photo_library, size: 40.0,),                                    
                      color: Theme.of(context).accentColor,
                      onPressed: () {                                
                        if (Medios().videoFilesEvidenciaResolutiva.length > 0 || Medios().imageListEvidenciaResolutiva.length > 0) {
                          Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: EditarMediosEvidenciaResolutiva(onDelete: () => {
                            setState(() {})
                          },)));
                        } else {
                          _mostrarDialogAgregarMedios();
                        }                               
                      },
                    ),
                  ) 
                ],
              ) 
            ],
          ),
          Container(
            padding: Medios().imageListEvidenciaResolutiva.length < 1 ? EdgeInsets.all(0) : EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: SizedBox(
              height: Medios().imageListEvidenciaResolutiva.length < 1 ? 0.0 : 140.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: Medios().imageListEvidenciaResolutiva.length,
                itemBuilder: (context, index) {
                  return new Stack(     
                    alignment: Alignment.center,                                
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return StatefulBuilder(builder: (context, StateSetter setState) {
                                return SimpleDialog(
                                  backgroundColor: Colors.white,
                                  contentPadding: EdgeInsets.all(0),
                                  children: <Widget>[
                                    Image.file(
                                      Medios().imageListEvidenciaResolutiva[index],
                                    ),                                
                                    ButtonBar(
                                      children: <Widget>[
                                        /* MaterialButton(
                                          minWidth: 90.0,                                                                    
                                          child: descargandoMedioLocal == true ?
                                            Column(
                                              children: <Widget>[
                                                Center(
                                                  child: Container(
                                                    height: 20.0,    
                                                    width: 20.0,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2.0,
                                                      valueColor:  AlwaysStoppedAnimation<Color>(Colors.white),
                                                    ),                                                                 
                                                  )
                                                )
                                              ],
                                            ) :
                                            Row(
                                              children: <Widget>[
                                                Icon(Icons.get_app),
                                                Text('Guardar')
                                              ],
                                            ),
                                          shape: StadiumBorder(),
                                                textColor: Colors.white,
                                                color: Theme.of(context).accentColor,
                                                elevation: 1.0,
                                          onPressed: () async {
                                            var directory = await getApplicationDocumentsDirectory();
                                            var path = directory.path;
                                            File image = File(Medios().imageListEvidenciaResolutiva[index].path);                                          
                                            final File localImage = await image.copy('$path/imagenprueba1.jpg'); 
                                            print(localImage);
                                            /* setState(() {
                                              descargandoMedioLocal = true;
                                            });
                                            GallerySaver.saveImage(Medios().imageListEvidenciaResolutiva[index].path).then((bool success) {
                                              Navigator.pop(context);
                                              setState(() {
                                                descargandoMedioLocal = false;
                                              });
                                            }); */
                                          },
                                        ), */
                                        MaterialButton(
                                          minWidth: 90.0,
                                          child: Text('Cerrar'),
                                          shape: StadiumBorder(),
                                                textColor: Colors.white,
                                                color: Theme.of(context).accentColor,
                                                elevation: 1.0,
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    )
                                  ],
                                );
                              });
                            }
                          );
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Card(
                              color: Colors.grey[800],
                              child: Container(
                                height: 130.0,   
                                width: 130.0,                                            
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: FittedBox(
                                    child: Image.file(File(Medios().imageListEvidenciaResolutiva[index].path)),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Container(   
                              alignment: Alignment.center,                                       
                              child: Opacity(                          
                                child: Icon(Icons.visibility, size: 70.0, color: Theme.of(context).primaryColor,),
                                opacity: 0.6,
                              )
                            )
                          ],
                        ),
                      ),                                        
                    ],
                  );
                }),
            )
          ),                                               
          Medios().videoFilesEvidenciaResolutiva.length > 0 ? Container(
            child: SizedBox(
              height: /* Medios().videoFilesEvidenciaResolutiva.length < 1 ? 0.0 :  */130.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: Medios().videoFilesEvidenciaResolutiva.length,
                itemBuilder: (context, index) {                                
                  return GestureDetector(
                        child: Card(
                          color: Colors.grey[800],
                          child: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[                          
                              ReproductorVideoPreview(videoFile: Medios().videoFilesEvidenciaResolutiva[index], key: new ObjectKey(Medios().videoFilesEvidenciaResolutiva[index]),),
                              Container(   
                                /* alignment: Alignment.center,  */                                      
                                child: Opacity(                          
                                  child: Icon(Icons.play_arrow, size: 70.0, color: Theme.of(context).primaryColor,),
                                  opacity: 0.6,
                                )
                              )
                            ],
                          ),
                        ),
                        onTap: (){
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return StatefulBuilder(builder: (context, StateSetter setState) {
                                return SimpleDialog(                                              
                                  backgroundColor: Colors.white,
                                  contentPadding: EdgeInsets.all(0),                                              
                                  children: <Widget>[
                                    ReproductorVideo(videoFile: Medios().videoFilesEvidenciaResolutiva[index], key: new ObjectKey(Medios().videoFilesEvidenciaResolutiva[index]),),
                                    ButtonBar(
                                      children: <Widget>[
                                       /*  MaterialButton(
                                          minWidth: 90.0,                                                                    
                                          child: descargandoMedioLocal == true ?
                                            Column(
                                              children: <Widget>[
                                                Center(
                                                  child: Container(
                                                    height: 20.0,    
                                                    width: 20.0,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2.0,
                                                      valueColor:  AlwaysStoppedAnimation<Color>(Colors.white),
                                                    ),                                                                 
                                                  )
                                                )
                                              ],
                                            ) :
                                            Row(
                                            children: <Widget>[
                                              Icon(Icons.get_app),
                                              Text('Guardar')
                                            ],
                                          ),
                                          shape: StadiumBorder(),
                                                textColor: Colors.white,
                                                color: Theme.of(context).accentColor,
                                                elevation: 1.0,
                                          onPressed: () {
                                            /* setState(() {
                                              descargandoMedioLocal = true;
                                            });
                                            GallerySaver.saveVideo(Medios().videoFilesEvidenciaResolutiva[index].path).then((bool success) {
                                              Navigator.pop(context);
                                              setState(() {
                                                descargandoMedioLocal = false;
                                              });
                                            }); */
                                          },
                                        ), */
                                        MaterialButton(
                                          minWidth: 90.0,
                                          child: Text('Cerrar'),
                                          shape: StadiumBorder(),
                                                textColor: Colors.white,
                                                color: Theme.of(context).accentColor,
                                                elevation: 1.0,
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    )
                                  ],
                                );
                              });
                            }
                          );
                        },
                      );                            
              }),
            ),
          ) : 
          Container(height:0.0), 
          /* Medios().audioFilesEvidenciaResolutiva.length > 0 ? Container(
            child: SizedBox(
              height: Medios().audioFilesEvidenciaResolutiva.length < 1 ? 0.0 : 110.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: Medios().audioFilesEvidenciaResolutiva.length,
                itemBuilder: (context, index) {                                
                  return new Stack(
                    children: <Widget>[
                      Padding(
                        key:  ObjectKey(Medios().audioFilesEvidenciaResolutiva[index]),
                        padding: Medios().audioFilesEvidenciaResolutiva.length > 1 ? EdgeInsets.only(right: 10.0) : EdgeInsets.only(right: 0),
                        child: ReproductorAudio(audioFile: Medios().audioFilesEvidenciaResolutiva[index], key: UniqueKey(), index: index,),
                      ),                                      
                    ],
                  );
              }),
            ),
          ) : 
          Container(height:0.0), */
        ],
      ),
    );
  }
}