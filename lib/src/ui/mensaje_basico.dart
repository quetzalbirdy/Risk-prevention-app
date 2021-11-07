import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nuevo_riesgos/src/resources/grabar_reproducir/mostrar_medios.dart';
import 'package:nuevo_riesgos/src/resources/grabar_reproducir/reproductor_video.dart';
import 'package:nuevo_riesgos/src/resources/grabar_reproducir/reproductor_audio.dart';
import 'package:nuevo_riesgos/src/resources/grabar_reproducir/reproductor_video_preview.dart';
import 'package:nuevo_riesgos/src/resources/plugins/json_incidente.dart';
import 'package:nuevo_riesgos/src/resources/proveedor_servicio_dio.dart';
import 'package:nuevo_riesgos/src/resources/proveedor_servicio_obras.dart';
import 'dart:io';
import 'package:http_auth/http_auth.dart';
import 'package:http/http.dart' show Client;
import 'package:path_provider/path_provider.dart';
import 'package:nuevo_riesgos/src/resources/constantes.dart' as constantes;

class AgregarElementosBasico extends StatefulWidget {

  final List<dynamic> incidente;
  final usuarioIncidente;
  final incidentId;
  final nombreObra;
  final cerrado;
  final threadId;
  final parentMessageId;
  final obraId;
  final mensaje;
  final userIncidenteId;
  final userReportadoPor;
  final responsable;
  final messageId;
  final userIdSend;
  final tituloIncidente;
  AgregarElementosBasico({Key key, this.cerrado, this.userIncidenteId, this.incidente, this.responsable, this.usuarioIncidente, this.incidentId, this.nombreObra, this.threadId, this.parentMessageId, this.messageId, this.obraId, this.mensaje, this.userReportadoPor, this.userIdSend, this.tituloIncidente}) : super(key: key);   
  
  @override
  _AgregarElementosState createState() => _AgregarElementosState();
}

class _AgregarElementosState extends State<AgregarElementosBasico> {
  final urlServicios = constantes.urlBase;

  bool _complementarInfo = false;
  bool _responder = false;
  dynamic response;  
  Client client;

  List imagenesMediosIncidente;
  List videosMediosIncidente;
  List audiosMediosIncidente;
  var mediosModel;
  var listaSupervisores;
  var listaAdministradores;    

  getMedios() async {
    print('incident id');   
    print(widget.mensaje) ;
    await ServiciosConecta(client).fetchMedios(widget.incidentId, '$urlServicios', 'http://$urlServicios/api/jsonws/vs-bpm-screen-portlet.incidente/get-file-by-incidente-id').then((response) {
      
      setState(() {
        mediosModel = response;        
        
        /* videosMediosIncidente = mediosModel.videos;
        audiosMediosIncidente = mediosModel.audios; */
      });
      imagenesMediosIncidente = mediosModel.imagenes;
      videosMediosIncidente = mediosModel.videos;
      audiosMediosIncidente = mediosModel.audios;
      print('medios');
      print(imagenesMediosIncidente);
      print(videosMediosIncidente);
      print(audiosMediosIncidente);
    });
  }
  getSupervisores() async {
    await ServiciosConecta(client).obtenerSupervisores(widget.obraId.toString()).then((response) {
      setState(() {
        listaSupervisores = response.supervisores;
      });
      print('lista supervisores');
      print(listaSupervisores);
    });

  }
  getAdministradores() async {
    await ServiciosConecta(client).obtenerAdministradores(widget.obraId.toString()).then((response) {
      setState(() {
        listaAdministradores = response.supervisores;
      });
      print('lista administradores');
      print(listaAdministradores);
    });
  }

  setRead() async {
    /* SharedPreferences prefs = await SharedPreferences.getInstance(); */
    ServiciosConectaDio().setMessageRead(widget.messageId).then((value) {
      /* if (value == 'true') {        
        prefs.setString('unreadMessagesCount', prefs.getString('unreadMessagesCount'));
      } */
    });    
  }

  @override
  void initState() {       
    super.initState();
    setRead();
    getMedios();   
    getSupervisores();     
    setState(() {
      responseEstado = null; 
      responseComunicar1 = null;
      responseComunicar2 = null;            
      print('incidente');
      print(widget.incidente);       
    });        
  }

  bool subiendoReporte = false;
  bool reporteSubido = false;

  void _mostrarDialogGuardar() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, StateSetter setState) {
          return AlertDialog(          
            content:
            reporteSubido == true ?
            Text('Gracias por tu ayuda a mantener un lugar de trabajo seguro') :
            subiendoReporte == true ?
             Column(
               mainAxisSize: MainAxisSize.min,
               mainAxisAlignment: MainAxisAlignment.center,
               children: <Widget>[
                Center(child: CircularProgressIndicator(),)
              ]
             ) :
            Text('Presione "Ok" para guardar la información y "Cancelar", para seguir editándola'),
            actions: <Widget>[
              subiendoReporte == false ? 
              MaterialButton(
                minWidth: 90.0,
                child: Text('Cancelar'),
                shape: StadiumBorder(),
                      textColor: Colors.white,
                      color: Theme.of(context).accentColor,
                      elevation: 1.0,
                onPressed: () {
                  /* print(_comunicarValue); */                          
                  Navigator.pop(context);
                  /* print(json.decode(widget.incidente)['data_'][0].length/* [1]['type'] *//* ['incidentId'] */); */
                },
              ) : Container(height: 0.0,),
              subiendoReporte == false ?
              MaterialButton(
                minWidth: 90.0,
                child: Text('Ok'),
                shape: StadiumBorder(),
                      textColor: Colors.white,
                      color: Theme.of(context).accentColor,
                      elevation: 1.0,
                onPressed: () async {
                  setState(() {
                    subiendoReporte = true;
                  });
                  if (_comunicarCuerpo != null) {
                    ServiciosConectaDio().enviarMensaje(widget.userIncidenteId.toString(), widget.threadId.toString(), widget.incidentId.toString(), widget.messageId, '2', _comunicarCuerpo);                  
                  }
                  if (_responderCuerpo != null) {
                    ServiciosConectaDio().enviarMensaje(widget.userIdSend, widget.threadId.toString(), widget.incidentId.toString(), widget.messageId, '0', _responderCuerpo);                  
                  }
                  if (_valorEstado != null) {                  
                    await  ServiciosConectaDio().cambiarEstado(widget.incidentId, _valorEstado);
                  }
                  await ServiciosConectaPostDio().subirMedios(widget.incidentId);                  
                  setState(() {
                    reporteSubido = true;
                  });
                  Future.delayed(Duration(seconds: 2), () {                        
                    Navigator.pushNamed(context, 'inicio');
                  });
                },
              ) : Container(height: 0.0,) ,                        
            ],
          );
        });
      }
    );
  }  

  String jsonEstadoSolucion;
  String jsonComunicar;
  String jsonAvanzado;
  bool descargandoMedioLocal = false;
  dynamic imagenAuth; 
  dynamic videoAuth;
  void obtenerVideo() async {
    Future<void> writeToFile(Uint8List data, String path) {      
      return new File(path).writeAsBytes(data);
    }

    var client = new DigestAuthClient('pamelasm', '123456');
    var responseVid = await client.get('http://$urlServicios/webdav/guest/document_library/Incidentes/incidente-305/305_upload_00001629.mp4');       

    final Directory appDirectory = await getApplicationDocumentsDirectory();

    final String videoDirectory = '${appDirectory.path}/Videos';

    await Directory(videoDirectory).create(recursive: true);

    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();

    final String filePath = '$videoDirectory/$currentTime.mp4';

    await writeToFile(responseVid.bodyBytes, filePath);

    setState(() {
      videoAuth = filePath;      
    });    
  }

  var responseEstado;  
  var responseComunicar1;    
  var responseComunicar2;   
  
  var _comunicarCuerpo;
  var _valorEstado;
  var _responderCuerpo;
    
  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      backgroundColor: Colors.grey[350],
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, 'mensajesBasicos');
          },
        ),
        title: Padding(
          padding: EdgeInsets.only(left: 0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(widget.tituloIncidente.toUpperCase(), style: TextStyle(fontSize: 15.0),),
              Text(widget.nombreObra, style: TextStyle(fontSize: 13.0),),
            ],
          ),
        )
      ),      
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: LayoutBuilder(builder: (builder, constraints) {
            return Container(
              decoration: widget.cerrado ? BoxDecoration(
                border: Border(
                  left: BorderSide(
                    width: 10,
                    color: Colors.grey
                  ),
                  right: BorderSide(
                    width: 10,
                    color: Colors.grey
                  ),
                  bottom: BorderSide(
                    width: 10,
                    color: Colors.grey
                  ),
                  top: BorderSide(
                    width: 10,
                    color: Colors.grey
                  )
                ),
              ) : BoxDecoration(border: Border.all(width: 0.0)), 
              child: Column(
                children: <Widget>[
                  widget.cerrado ? Container(
                    height: 30.0,
                    decoration: new BoxDecoration(
                      color: Colors.black,                                                    
                  ),
                    /* margin: EdgeInsets.only(bottom: 10.0),   */                                                  
                    /* width: MediaQuery.of(context).size.width,  */                         
                    alignment: Alignment.center,                
                    child: Text(
                      'Incidente cerrado', 
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),  
                    ),
                  ) : Container(),
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.vertical,   
                      shrinkWrap: true,           
                      children: [
                        Container(
                          padding: EdgeInsets.only(top: 20.0),
                          color: Colors.grey[100],
                         /*  margin: const EdgeInsets.symmetric(horizontal: 30.0),
                          width: MediaQuery.of(context).size.width * 0.5,
                          alignment: FractionalOffset.center, */
                          child: Column(
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 30.0),
                                width: MediaQuery.of(context).size.width * 0.9,
                                alignment: FractionalOffset.center,
                                child: Column(                        
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text('Id incidente', style: TextStyle(fontSize: 13.0, color: Colors.black, /* fontWeight: FontWeight.w700 */),),
                                      Text(widget.incidentId.toString(), style: TextStyle(fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.w600),),
                                    ],
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(top: 10.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text('Reportado por', style: TextStyle(fontSize: 12.0, color: Colors.black),),
                                        Text(widget.userReportadoPor.toString().toUpperCase(), style: TextStyle(fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.w600),),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(top: 10.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text('Responsable', style: TextStyle(fontSize: 12.0, color: Colors.black),),
                                        Text(widget.responsable, style: TextStyle(fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.w600),),
                                      ],
                                    ),
                                  ),
                                  JsonIncidente(form: widget.incidente),                                                                                                                   
                                  ],
                                ),
                              ),
                                (videosMediosIncidente != null || imagenesMediosIncidente != null || audiosMediosIncidente != null) ? Container(
                                  height: videosMediosIncidente.length > 0 || imagenesMediosIncidente.length > 0 || audiosMediosIncidente.length > 0 ? 30.0 : 0.0,
                                  decoration: new BoxDecoration(
                                    color: Theme.of(context).primaryColor,                                                    
                                ),
                                  margin: EdgeInsets.only(top: 20.0),                          
                                  /* height: videosMediosIncidente.length > 0 || imagenesMediosIncidente.length > 0 || audiosMediosIncidente.length > 0 ? 30.0 : 0.0,     */
                                  width: MediaQuery.of(context).size.width,  
                                  alignment: Alignment.center,                
                                  child: Text(
                                    'Evidencias', 
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),  
                                  ),
                                ) : Container(margin: EdgeInsets.only(top: 20.0, bottom: 20.0), child: Center(child: CircularProgressIndicator(),),),
                                Container(
                                  color: Colors.grey[350],
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 30.0),
                                    width: MediaQuery.of(context).size.width * 0.9,
                                    alignment: FractionalOffset.center,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[                                                                 
                                        Container(
                                          padding: EdgeInsets.symmetric(vertical: 10.0),
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[              
                                              imagenesMediosIncidente != null ?          
                                              imagenesMediosIncidente.length > 0 ?    
                                              Container(
                                                padding: imagenesMediosIncidente.length < 1 ? EdgeInsets.all(0) : EdgeInsets.only(top: 10.0, bottom: 10.0),
                                                child: SizedBox(
                                                  height: imagenesMediosIncidente.length < 1 ? 0.0 : 140.0,
                                                  child: ListView.builder(
                                                    scrollDirection: Axis.horizontal,
                                                    itemCount: imagenesMediosIncidente.length,
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
                                                                        Image.network(
                                                                          imagenesMediosIncidente[index],
                                                                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                                                                            if (loadingProgress == null) return child;
                                                                            return Container(
                                                                              height: 100.0,
                                                                              child: Center(
                                                                                child: CircularProgressIndicator(                                                                          
                                                                                  value: loadingProgress.expectedTotalBytes != null
                                                                                      ? loadingProgress.cumulativeBytesLoaded /
                                                                                          loadingProgress.expectedTotalBytes
                                                                                      : null,
                                                                                ),
                                                                              ),
                                                                            );
                                                                          },
                                                                        ),   
                                                                        ButtonBar(
                                                                          children: <Widget>[                                                                    
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
                                                                        child: Image.network(imagenesMediosIncidente[index]),
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
                                              ) : Container(height: 0.0,) : Container(height: 0.0,),                                               
                                              videosMediosIncidente != null ? 
                                              videosMediosIncidente.length > 0 ?
                                              Container(
                                                child: SizedBox(
                                                  height: /* Medios().videoFiles.length < 1 ? 0.0 :  */130.0,
                                                  child: ListView.builder(
                                                    scrollDirection: Axis.horizontal,
                                                    itemCount: videosMediosIncidente.length,
                                                    itemBuilder: (context, index) {                                
                                                      return new GestureDetector(
                                                        child: Card(
                                                          color: Colors.grey[800],
                                                          child: Stack(
                                                            alignment: Alignment.center,
                                                            children: <Widget>[
                                                              ReproductorVideoPreview(videoUrl: videosMediosIncidente[index], key: new ObjectKey(videosMediosIncidente[index]),),
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
                                                                    ReproductorVideo(videoUrl: videosMediosIncidente[index], key: new ObjectKey(videosMediosIncidente[index]),),
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
                                                                              /* http.Client _client = new http.Client();
                                                                              setState(() {
                                                                                descargandoMedioLocal = true;
                                                                              });                                                                                                                                   
                                                                              try {
                                                                                var dir = (await DownloadsPathProvider.downloadsDirectory).path;
                                                                                var nombreVideo = videosMediosIncidente[index].split('/').last;                                                                    
                                                                                var req = await _client.get(videosMediosIncidente[index]);
                                                                                var bytes = req.bodyBytes;
                                                                                File file = new File("$dir/$nombreVideo");
                                                                                await file.writeAsBytes(bytes);
                                                                                print("$dir/$nombreVideo");
                                                                              } catch (e) {
                                                                                print(e);
                                                                              }
                                                                              setState(() {
                                                                                descargandoMedioLocal =false;
                                                                              }); 
                                                                              Navigator.pop(context);
                                                                              print("Download completed");  */                                                          
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
                                                              }
                                                              );
                                                            }
                                                          );
                                                        },
                                                      );                            
                                                  }),
                                                ),
                                              ) : 
                                              Container(height:0.0) : Container(height:0.0), 
                                              audiosMediosIncidente != null ? Container(
                                                child: SizedBox(
                                                  height: audiosMediosIncidente.length < 1 ? 0.0 : 110.0,
                                                  child: ListView.builder(
                                                    scrollDirection: Axis.horizontal,
                                                    itemCount: audiosMediosIncidente.length,
                                                    itemBuilder: (context, index) {                                
                                                      return Stack(
                                                        children: <Widget>[
                                                          Padding(
                                                            key: UniqueKey(),
                                                            padding: audiosMediosIncidente.length > 1 ? EdgeInsets.only(right: 10.0) : EdgeInsets.only(right: 0),
                                                            child: ReproductorAudio(audioFile: audiosMediosIncidente[index], key: UniqueKey(), index: index,),
                                                          ),                                      
                                                        ],
                                                      );
                                                  }),
                                                ),
                                              ) : 
                                              Container(height:0.0), 
                                              videosMediosIncidente != null || imagenesMediosIncidente != null || audiosMediosIncidente != null ?
                                              Center(                                        
                                                child: videosMediosIncidente.length > 0 || imagenesMediosIncidente.length > 0 || audiosMediosIncidente.length > 0 ? 
                                                Padding(
                                                  padding: EdgeInsets.only(top: 15.0),
                                                  child: Divider(
                                                    color: Colors.grey[800],
                                                  ),
                                                ) : Container(height: 0.0,), 
                                              ) : Container(height: 0.0,), 
                                              Text(
                                                'Respuesta', 
                                                style: TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[200],                                          
                                                  borderRadius: BorderRadius.all(Radius.circular(10))
                                                ),
                                                width: MediaQuery.of(context).size.width * 0.8,
                                                margin: EdgeInsets.only(top: 10.0, bottom: 10.0), 
                                                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),                                        
                                                child: widget.mensaje != 'Se ha generado un nuevo Incidente' ? Container(
                                                  padding: EdgeInsets.only(top: 0.0),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      Container(
                                                        margin: EdgeInsets.only(bottom: 10.0),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: <Widget>[
                                                            Text(
                                                              'Mensaje enviado por',
                                                              style: TextStyle(fontSize: 12.0, color: Colors.grey[700]),
                                                            ),
                                                            Text(
                                                              widget.usuarioIncidente,
                                                              style: TextStyle(fontSize: 16.0, color: Colors.black),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: <Widget>[
                                                            Text(
                                                              'Mensaje',
                                                              style: TextStyle(fontSize: 12.0, color: Colors.grey[700]),
                                                            ),
                                                            Text(
                                                              widget.mensaje,
                                                              style: TextStyle(fontSize: 16.0, color: Colors.black),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ) : Container(height: 0.0),
                                              ),    
                                              Center(
                                                child: Divider(
                                                  color: Colors.grey[800],
                                                ),
                                              ),                                                                                                                                              
                                              !widget.cerrado ? GestureDetector(
                                                onTap: () { 
                                                  setState(() {
                                                    if (_complementarInfo == true) {
                                                      _complementarInfo = false;
                                                    } else {
                                                      _complementarInfo = true;
                                                    }   
                                                  });
                                                },
                                                child: Container(
                                                  margin: EdgeInsets.only(top: 10, bottom: 0),
                                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                                  decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey.withOpacity(0.5),
                                                      spreadRadius: 0,
                                                      blurRadius: 4,
                                                      offset: Offset(0, 3), // changes position of shadow
                                                    ),
                                                  ],
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(10.0),),
                                                  child: Row(
                                                    children: <Widget>[
                                                    Checkbox(
                                                      value: _complementarInfo,
                                                      onChanged: (bool value) {
                                                        setState(() {
                                                          _complementarInfo = value;                                
                                                        });
                                                      }),
                                                    Container(
                                                        child: Text('Agregar Medios', style: TextStyle(color: Colors.grey[800]))),                        
                                                  ]),
                                                ),
                                              ) : Container(),                            
                                              _complementarInfo ?                                          
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 10.0),
                                                child: MostrarMedios(),
                                              ) : 
                                              Container(height:0.0),                                       
                                              !widget.cerrado ? GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    if (_responder == true) {
                                                      _responder = false;
                                                    } else {
                                                      _responder = true;
                                                    }                            
                                                  });
                                                },
                                                child: Container(
                                                  margin: EdgeInsets.only(top: 10, bottom: 0),
                                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                                  decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey.withOpacity(0.5),
                                                      spreadRadius: 0,
                                                      blurRadius: 4,
                                                      offset: Offset(0, 3), // changes position of shadow
                                                    ),
                                                  ],
                                                  color: Colors.white,
                                                  borderRadius: !_responder? BorderRadius.circular(10.0) : BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10))),
                                                  child: Row(
                                                    children: <Widget>[
                                                    Checkbox(
                                                      value: _responder,
                                                      onChanged: (bool value) {
                                                        setState(() {
                                                          _responder = value;                                
                                                        });
                                                      }),
                                                    Container(
                                                        child: Text('Responder', style: TextStyle(color: Colors.grey[800]))),                        
                                                  ]),
                                                ),
                                              ) : Container(),  
                                              _responder ? 
                                              Container(
                                                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
                                                  color: Colors.grey[400],
                                                ),                                        
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    /* Padding(
                                                      padding: const EdgeInsets.only(bottom: 5.0, left: 2.0),
                                                      child: Text(
                                                        'Agregar respuesta',
                                                        style: TextStyle(fontSize: 13.0, color: Colors.black),
                                                      ),
                                                    ), */
                                                    Container(      
                                                      margin: EdgeInsets.only(bottom: 5.0, top: 5.0),                                        
                                                      decoration: BoxDecoration(
                                                        boxShadow: [
                                                          BoxShadow(
                                                              color: Colors.grey.withOpacity(0.5),
                                                              spreadRadius: 0,
                                                              blurRadius: 4,
                                                              offset: Offset(0, 3), // changes position of shadow
                                                            ),
                                                        ],
                                                        borderRadius: BorderRadius.only(bottomRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
                                                        color: Colors.grey[400],
                                                      ),
                                                      child: TextField(
                                                        onChanged: (String value) {
                                                          setState(() {
                                                            _responderCuerpo = value;
                                                          });
                                                        }, 
                                                        style: TextStyle(
                                                          color: Colors.black
                                                        ),
                                                        keyboardType: TextInputType.multiline,
                                                        maxLines: 3,
                                                        
                                                        decoration: InputDecoration(
                                                          filled: true,
                                                          fillColor: Colors.white,
                                                          hintText: "Agregar respuesta",
                                                          hintStyle: TextStyle(color: Colors.grey[700]),
                                                          enabledBorder: OutlineInputBorder(
                                                            borderSide: BorderSide(color: Colors.transparent, width: 0),
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(10),
                                                            borderSide: BorderSide(color: Colors.transparent, width: 0),
                                                          ), 
                                                        )
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ): 
                                              Container(height: 0.0,),  
                                              !widget.cerrado ?                                                                                                
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: <Widget>[
                                                  Container(
                                                    width: 165.0,
                                                    margin: EdgeInsets.only(top: 10.0),
                                                    child: MaterialButton(                        
                                                      shape: StadiumBorder(),
                                                      textColor: Colors.white,
                                                      color: Theme.of(context).accentColor,
                                                      elevation: 1.0,
                                                      onPressed: () {
                                                        _mostrarDialogGuardar();
                                                      },
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: <Widget>[
                                                          Icon(Icons.save_alt),
                                                          Padding(
                                                            padding: EdgeInsets.only(left: 10.0,),
                                                            child: Text(
                                                              'Guardar',
                                                              style: TextStyle(
                                                                fontWeight: FontWeight.w400,
                                                                fontSize: 20
                                                                )
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ) : Container(),                      
                                            ],
                                          )
                                        )
                                      ],
                                    ),
                                  ),
                                )
                            ],
                          )
                        ),           
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        )
      ))
    );
  }  

  @override 
  void dispose() {    
    super.dispose();
  }  
}
