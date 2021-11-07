import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nuevo_riesgos/src/resources/datos/datos_form.dart';
import 'package:nuevo_riesgos/src/resources/grabar_reproducir/mostrar_medios.dart';
import 'package:nuevo_riesgos/src/resources/grabar_reproducir/mostrar_medios_evidencia_resolutiva.dart';
import 'package:nuevo_riesgos/src/resources/grabar_reproducir/reproductor_video.dart';
import 'package:nuevo_riesgos/src/resources/datos/medios.dart';
import 'package:nuevo_riesgos/src/resources/grabar_reproducir/reproductor_audio.dart';
import 'package:nuevo_riesgos/src/resources/grabar_reproducir/reproductor_video_preview.dart';
import 'package:nuevo_riesgos/src/resources/plugins/json_form.dart';
import 'package:nuevo_riesgos/src/resources/plugins/json_incidente.dart';
import 'package:nuevo_riesgos/src/resources/proveedor_servicio_dio.dart';
import 'package:nuevo_riesgos/src/resources/proveedor_servicio_obras.dart';
import 'dart:io';
import 'package:http_auth/http_auth.dart';
import 'package:http/http.dart' show Client;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nuevo_riesgos/src/resources/constantes.dart' as constantes;

class AgregarElementosAvanzado extends StatefulWidget {

  final List<dynamic> incidente;
  final usuarioIncidente;
  final incidentId;
  final nombreObra;
  final threadId;
  final parentMessageId;
  final obraId;
  final mensaje;
  final userIncidenteId;
  final subject;
  final estado;  
  final messageId;
  final userReportadoPor;
  final tituloIncidente;
  final responsable;
  final cerrado;
  final gravedad;
  AgregarElementosAvanzado({Key key, this.cerrado, this.responsable, this.userIncidenteId, this.incidente, this.usuarioIncidente, this.incidentId, this.nombreObra, this.threadId, this.parentMessageId, this.obraId, this.mensaje, this.subject, this.estado, this.messageId, this.userReportadoPor, this.tituloIncidente, this.gravedad}) : super(key: key);   
  
  @override
  _AgregarElementosState createState() => _AgregarElementosState();
}

class _AgregarElementosState extends State<AgregarElementosAvanzado> {  
  bool _complementarInfo = false;
  bool _responder = false;
  bool _infoAvanzada = false;
  dynamic response;  
  Client client;
  final urlServicios = constantes.urlBase;

  List imagenesMediosIncidente;
  List videosMediosIncidente;
  List audiosMediosIncidente;
  var mediosModel;  
  var listaAdministradores;

  var jsonPrincipal;
  var jsonAvanzado;  
  var jsonComplementar;
  var formAvanzado;  

  bool subiendoReporte = false;
  bool reporteSubido = false;

  List usuariosComunicar;
  var informacionComplementada = TextEditingController();
  List administradoresStatus;     


  getMedios() async {    
    await ServiciosConecta(client).fetchMedios(widget.incidentId, '$urlServicios', 'http://$urlServicios/api/jsonws/vs-bpm-screen-portlet.incidente/get-file-by-incidente-id').then((response) {      
      setState(() {
        mediosModel = response;        
        imagenesMediosIncidente = mediosModel.imagenes;
        videosMediosIncidente = mediosModel.videos;
        audiosMediosIncidente = mediosModel.audios;
        /* videosMediosIncidente = mediosModel.videos;
        audiosMediosIncidente = mediosModel.audios; */
      });          
    });
  }  
  getAdministradores() async {
    await ServiciosConecta(client).obtenerAdministradores(widget.obraId.toString()).then((response) {
      List preFiltro = response.supervisores;
      List supervisoresUnicos = preFiltro.toSet().toList();
      List administradoresSeleccionados = List();
      for (var i = 0; supervisoresUnicos.length > i; i++) {
        var user = {'id': supervisoresUnicos[i].userId.toString(), 'status': false};
        administradoresSeleccionados.add(user);
      }      
      setState(() {
        administradoresStatus = administradoresSeleccionados;        
        listaAdministradores = supervisoresUnicos;
        for (var i = 0; listaAdministradores.length > i; i++) {
          usuariosComunicar.add(false);
        }
      });      
    });
  }
  getFormularios() async {
    await ServiciosConecta(client).fetchFormularios('true', 'formPrincipal', 'formAgregarInfo', 'http://$urlServicios/api/jsonws/vs-bpm-screen-portlet.formularioapp/get-form').then((response) {
      setState(() {
        formAvanzado = response;
        print('avanzado');
        print(formAvanzado.formAgregarInformacion);
      });
    });
  }
  extraerIncidentData() {        
    for (var i = 0; widget.incidente.length > i; i++) {   
      if (widget.incidente[i] != null) {
        if (widget.incidente[i]['formPrincipal'] != null) {        
          jsonPrincipal = widget.incidente[i];     
          print(['principal']);
          print(jsonPrincipal);   
        } else if (widget.incidente[i]['formAgregarInfo'] != null) {
          jsonAvanzado = widget.incidente[i];
          print(jsonAvanzado);
        } else if (widget.incidente[i]['formComplementar'] != null) {
          jsonComplementar = widget.incidente[i];
          print(jsonAvanzado);
        }        
      }               
    }
  }  

  setRead() async {
    /* SharedPreferences prefs = await SharedPreferences.getInstance(); */
    ServiciosConectaDio().setMessageRead(widget.messageId).then((value) {
      /* if (value == 'true') {        
        prefs.setString('unreadMessagesCount', prefs.getString('unreadMessagesCount'));
      } */
    });    
  }

 /*  var timestamp;

  generarTimestamp() async {    
    SharedPreferences prefs = await SharedPreferences.getInstance(); 
    var timeNow = DateTime.now().millisecondsSinceEpoch;   
    var tempTime = timeNow.toString() + prefs.getInt('userId').toString();
    setState(() {
      if (tempTime.length <= 19) {
        timestamp = tempTime;
      } else {
        timestamp = tempTime.substring(0, 19);
      }             
    });     
  } */

  @override
  void initState() {       
    super.initState();   
    /* generarTimestamp(); */
    setRead(); 
    extraerIncidentData();    
    getMedios();   
    usuariosComunicar = List();    
    getAdministradores(); 
    getFormularios();
    print('gravedad');
    print(widget.gravedad);    
    setState(() {
      responseEstado = null; 
      responseComunicar1 = null;
      responseComunicar2 = null;
      if (widget.estado == 'Pendiente') {
        _valorEstado = 0.toString();
        _valorEstadoInicial = 0.toString();
      } else if (widget.estado == 'En proceso') {
        _valorEstado = 1.toString();
        _valorEstadoInicial = 1.toString();
      } else if (widget.estado == 'Resuelto') {
        _valorEstado = 2.toString();
        _valorEstadoInicial = 2.toString();
      }
      /* obtenerVideo(); */
      /* obtenerFoto(); */      
      /* obtenerFormularios();   */    
    });        
  }

  @override 
  void dispose() {    
    informacionComplementada.dispose();
    super.dispose();
  }  

  void _mostrarDialogValidacion() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(          
          content: Text('Para cambiar el estado a "Resuelto", es necesario agregar al menos una evidencia resolutiva'),
          actions: <Widget>[           
            MaterialButton(
              minWidth: 90.0,
              child: Text('Ok'),
              shape: StadiumBorder(),
                textColor: Colors.white,
                color: Theme.of(context).accentColor,
                elevation: 1.0,
              onPressed: () async {                    
                Navigator.pop(context);                                         
              },
            ),                        
          ],
        );
      }
    );
  }

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
             Text('Presione "Ok" para guardar la información y "Cancelar", para seguir editándola') ,
          actions: <Widget>[
            subiendoReporte == false ? 
            MaterialButton(
              minWidth: 90.0,
              child: Text('Cancelar'),
              shape: StadiumBorder(),
                    textColor: Colors.white,
                    color: Theme.of(context).accentColor,
                    elevation: 1.0,
              onPressed: () async {                        
                Navigator.pop(context);                                  
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
                      if (_valorEstado != null) { 
                        if (((_valorEstado == '2' && _valorEstadoInicial != '2') && widget.gravedad == 2) && (Medios().imageListEvidenciaResolutiva.isEmpty && Medios().videoFilesEvidenciaResolutiva.isEmpty)) {
                          Navigator.pop(context);  
                          _mostrarDialogValidacion();
                        } else {
                          await  ServiciosConectaDio().cambiarEstado(widget.incidentId, _valorEstado);
                          setState(() {
                            subiendoReporte = true;
                          });
                          SharedPreferences prefs = await SharedPreferences.getInstance();                
                          if (_infoAvanzada != null || informacionComplementada.text.length > 0 || jsonComplementar.length > 0) {
                            var jsonComplementarNuevo;
                            var reporteCompleto;
                            if (informacionComplementada.text.length > 0) {
                              jsonComplementarNuevo = {'formComplementar' : [{'type': 'TextArea', "placeholder": 'Información agregada por', "response": prefs.getString('userName')}, {'type': 'TextArea', "placeholder": 'Información', "response": informacionComplementada.text}]};                    
                            }              
                              reporteCompleto = {"reporteCompleto" : [jsonPrincipal, DatosForm().formAvanzdo ?? DatosForm().formAvanzdo, jsonAvanzado ?? jsonAvanzado, jsonComplementarNuevo != null ? jsonComplementarNuevo : jsonComplementar != null ? jsonComplementar : null]};                                     
                              await ServiciosConectaDio().crearIncidente(widget.incidentId.toString(), '0', json.encode(reporteCompleto), widget.obraId.toString(), '0', 'http://$urlServicios/api/jsonws/vs-bpm-screen-portlet.incidente/create', '0', '0', '0').then((response) async {                                                                               
                                print('incidente id');
                                print(widget.incidentId.toString());                      
                              }); 
                          } 
                          if (_comunicarCuerpo != null) {
                            for(var administrador in administradoresStatus) {
                              if (administrador['status'] == true) {
                                await ServiciosConectaDio().enviarMensaje(administrador['id'].toString(), widget.threadId.toString(), widget.incidentId.toString(), widget.messageId, '2', _comunicarCuerpo);
                              }                                    
                            }                        
                          }
                          if (_responderCuerpo != null) {
                            ServiciosConectaDio().enviarMensaje(widget.userIncidenteId.toString(), widget.threadId.toString(), widget.incidentId.toString(), widget.messageId, '3', _responderCuerpo);                  
                          }                                     
                          await ServiciosConectaPostDio().subirMedios(widget.incidentId);
                                                
                          setState(() {                        
                            reporteSubido = true;
                          });
                          Future.delayed(Duration(seconds: 2), () {                        
                            Navigator.pushNamed(context, 'mainAvanzado');
                          });
                        }                                        
                      }                       
                    },
                  ) : Container(height: 0.0,),                        
                ],
              );
        });        
      }
    );
  }  

  String jsonEstadoSolucion;
  String jsonComunicar;  
  bool _verComplementarInfo = false; 
  bool descargandoMedioLocal = false;
  

  /* void obtenerFormularios() async {       
    var response = await http.get('http://my-json-server.typicode.com/quetzalsa/json-ejemplos/db');
    setState(() {
      jsonEstadoSolucion = json.encode(json.decode(response.body)['formEstadoSolucion']);  
      jsonComunicar = json.encode(json.decode(response.body)['formComunicar']);  
      jsonAvanzado = json.encode(json.decode(response.body)['formAgregarInfo']);  
     /*  print(json.decode(jsonAvanzado));
      print(json.decode(jsonComunicar)); */
    });          
  } */

  dynamic imagenAuth;
  /* void obtenerFoto() async {
    var client = new DigestAuthClient('pamelasm', '123456');
    var responseImg = await client.get('http://$urlServicios/webdav/guest/document_library/Incidentes/incidente-305/305_upload_00001589.jpg');
    setState(() {
      imagenAuth = responseImg.bodyBytes;
    });    
  } */
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
var usuariosSeleccionadosComunicar = 0;

  var responseEstado;  
  var responseComunicar1;    
  var responseComunicar2;   
  

  var _comunicarValue;
  var _comunicarCuerpo;
  var _valorEstado;
  var _valorEstadoInicial;
  var _responderCuerpo;
  var responseFormAvanzado;
    
  @override
  Widget build(BuildContext context) {    
    return new Scaffold(
      backgroundColor: Colors.grey[350],
      appBar: AppBar(
        backgroundColor: Colors.black87,
        centerTitle: true,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, 'mainAvanzado');
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
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,              
                      children: [                    
                        Container(  
                          padding: EdgeInsets.only(top: 20.0),
                          color: Colors.grey[100],                
                          child: Column(                    
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[                      
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 30.0),
                                width: MediaQuery.of(context).size.width,
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
                                          Text('Reportado por', style: TextStyle(fontSize: 13.0, color: Colors.black, /* fontWeight: FontWeight.w700 */),),
                                          Text(widget.userReportadoPor.toUpperCase(), style: TextStyle(fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.w600),),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(top: 10.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text('Responsable', style: TextStyle(fontSize: 13.0, color: Colors.black, /* fontWeight: FontWeight.w700 */),),
                                          Text(widget.responsable, style: TextStyle(fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.w600),),
                                        ],
                                      ),
                                    ),
                                    JsonIncidente(form: widget.incidente),  
                                  ]
                                )
                              ),
                              (videosMediosIncidente != null || imagenesMediosIncidente != null || audiosMediosIncidente != null) ? Container(
                                height: videosMediosIncidente.length > 0 || imagenesMediosIncidente.length > 0 || audiosMediosIncidente.length > 0 ? 30.0 : 0.0,
                                decoration: new BoxDecoration(
                                  color: Theme.of(context).primaryColor,                                                    
                              ),
                                margin: EdgeInsets.only(top: 20.0),                                                    
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
                                                                            setState(() {
                                                                              descargandoMedioLocal = true;
                                                                            });
                                                                            var downloadImage = await ImageDownloader.downloadImage(imagenesMediosIncidente[index]);
                                                                            Navigator.pop(context);
                                                                            setState(() {
                                                                              descargandoMedioLocal = false;
                                                                            });
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
                                                                    /* Center(
                                                                      child: IconButton(
                                                                        icon: const Icon(Icons.close, color: Colors.black,),
                                                                        tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                                                                        onPressed: () {
                                                                          Navigator.maybePop(context);
                                                                        },
                                                                      ),
                                                                    ) */
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
                                                                          http.Client _client = new http.Client();
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
                                                                          print("Download completed"); 
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
                                          Padding(
                                            padding: EdgeInsets.only(top: 10.0),
                                            child: Center(                                
                                              child: videosMediosIncidente.length > 0 || imagenesMediosIncidente.length > 0 || audiosMediosIncidente.length > 0 ? Divider(
                                                color: Colors.grey[800],
                                              ) : Container(height: 0.0,),
                                            ),
                                          ) : Container(height: 0.0,),  
                                          widget.mensaje != 'Se ha generado un nuevo Incidente' ? Text(
                                            'Comentario', 
                                            style: TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ) : Container(height: 0.0,),
                                          widget.mensaje != 'Se ha generado un nuevo Incidente' ? 
                                          Container(
                                            width: MediaQuery.of(context).size.width * 0.8,
                                            margin: EdgeInsets.only(top: 10.0, bottom: 10.0), 
                                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),  
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],                                          
                                              borderRadius: BorderRadius.all(Radius.circular(10))
                                            ),                                    
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
                                                  margin: EdgeInsets.only(bottom: 10.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      Text(
                                                        'Comentario',
                                                        style: TextStyle(fontSize: 12.0, color: Colors.grey[700]),
                                                      ),
                                                      Text(
                                                        widget.mensaje,
                                                        style: TextStyle(fontSize: 16.0, color: Colors.black),
                                                      ),
                                                    ],
                                                  ),
                                                ),                                        
                                              ],
                                            ),
                                          ) : Container(height: 0.0),
                                        widget.mensaje != 'Se ha generado un nuevo Incidente' ? Divider(
                                          color: Colors.grey[800],
                                        ) : Container(height: 0.0,)    ,                                                     
                                          !widget.cerrado ? Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: <Widget>[                                
                                              Padding(
                                                padding: EdgeInsets.only(top: 10.0),
                                                child: new Stack(
                                                  children: <Widget>[
                                                    /* new Positioned(
                                                      top: -2.0,
                                                      child: new Text(
                                                        'Estado',
                                                        style: new TextStyle(
                                                          color: Colors.grey[800],
                                                        ),
                                                      ),
                                                    ), */
                                                    Theme(
                                                      data: Theme.of(context).copyWith(
                                                        canvasColor: Colors.white
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: <Widget>[
                                                          Padding(
                                                            padding: const EdgeInsets.only(bottom: 5.0, left: 2.0),
                                                            child: Text(
                                                              'Cambia el estado',
                                                              style: TextStyle(fontSize: 13.0, color: Colors.black, /* fontWeight: FontWeight.w700 */),
                                                            ),
                                                          ),
                                                          Container(
                                                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                                            decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors.grey.withOpacity(0.5),
                                                                spreadRadius: 0,
                                                                blurRadius: 4,
                                                                offset: Offset(0, 3), // changes position of shadow
                                                              ),
                                                            ],
                                                            borderRadius: BorderRadius.circular(10)),
                                                            child: DropdownButton<String>( 
                                                              icon: Icon(Icons.keyboard_arrow_down),  
                                                              /* hint: Text('Cambia el estado'), */ 
                                                              isExpanded: true,
                                                              underline: Container(
                                                                height: 0.0,
                                                                color: Colors.black,
                                                              ),                                                                                                 
                                                              value: _valorEstado,
                                                              /* hint: Text('', style: TextStyle(color: Colors.red[100]),), */
                                                              onChanged: (String valorNuevo) {
                                                                this.setState(() {                  
                                                                  print(_valorEstado);
                                                                  _valorEstado = valorNuevo;                                                       
                                                                });
                                                              },
                                                              items: [
                                                                DropdownMenuItem<String>(                                                      
                                                                    value: '0',
                                                                    child: Text('Pendiente', style: TextStyle(color: Colors.black),),
                                                                  ),
                                                                  DropdownMenuItem<String>(
                                                                    value: '1',
                                                                    child: Text('En proceso', style: TextStyle(color: Colors.black),),
                                                                  ),
                                                                  DropdownMenuItem<String>(
                                                                    value: '2',
                                                                    child: Text('Resuelto', style: TextStyle(color: Colors.black),),
                                                                  ),
                                                              ],              
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),                                      
                                                  ]
                                                )
                                              ),
                                              (_valorEstado == '2' && _valorEstadoInicial != '2') && widget.gravedad == 2 ?
                                              Column(
                                                children: [                                                  
                                                  Container(
                                                    margin: EdgeInsets.only(top: 15.0),
                                                    child: Text(
                                                      'Para cambiar el estado a "Resuelto", es necesario incluir evidencias de la resolución del incidente',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w700,                                                        
                                                      ),
                                                    )
                                                  ),                                                  
                                                  Container(
                                                    height: 30.0,
                                                    decoration: new BoxDecoration(
                                                      color: Theme.of(context).primaryColor,                                                    
                                                  ),
                                                    margin: EdgeInsets.only(top: 20.0),                                                    
                                                    width: MediaQuery.of(context).size.width,                          
                                                    alignment: Alignment.center,                
                                                    child: Text(
                                                      'Evidencias resolutivas', 
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w500,
                                                      ),  
                                                    ),
                                                  ),                                                  
                                                  MostrarMediosEvidenciaResolutiva()                                                  
                                                ],
                                              ) : Container(),
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    if (_verComplementarInfo == true) {
                                                      _verComplementarInfo = false;
                                                    } else {
                                                      _verComplementarInfo = true;
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
                                                  borderRadius: !_verComplementarInfo? BorderRadius.circular(10.0) : BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10))),
                                                  child: Row(
                                                    children: <Widget>[
                                                    Checkbox(
                                                      value: _verComplementarInfo,
                                                      onChanged: (bool value) {
                                                        setState(() {
                                                          _verComplementarInfo = value;                                
                                                        });
                                                      }),
                                                    Container(
                                                        child: Text('Comunicar a', style: TextStyle(color: Colors.grey[800]))),                        
                                                  ]),
                                                ),
                                              ),                             
                                              listaAdministradores != null ? 
                                              _verComplementarInfo != false ? Padding(
                                                padding: EdgeInsets.only(top: 0.0),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.only(bottomRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
                                                    color: Colors.grey[400],
                                                  ),                                          
                                                  child: Column(     
                                                    crossAxisAlignment: CrossAxisAlignment.stretch,                                                                                   
                                                    children: <Widget>[
                                                      /* Container(     
                                                        alignment: Alignment.center,                                           
                                                        color: Colors.grey[800],
                                                        padding: EdgeInsets.symmetric(vertical: 5.0),
                                                        child: Text('Usuarios', style: TextStyle(color: Colors.white, fontSize: 20.0),)
                                                      ), */
                                                      ListView.builder(                                        
                                                        physics: NeverScrollableScrollPhysics(),
                                                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                                                        shrinkWrap: true,
                                                        itemCount: listaAdministradores.length,
                                                        itemBuilder: (context, index) {
                                                          return Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: <Widget>[
                                                              Checkbox(                                                        
                                                                value: administradoresStatus[index]['status'], 
                                                                onChanged: (bool value) {    
                                                                  setState(() {
                                                                    administradoresStatus[index]['status'] = value;
                                                                  });                                                      
                                                                  for (var status in administradoresStatus) {
                                                                    if (status['status'] == true) {
                                                                      usuariosSeleccionadosComunicar = usuariosSeleccionadosComunicar + 1;
                                                                    }
                                                                  }                                                          
                                                                  setState(() {                                                            
                                                                      print(usuariosSeleccionadosComunicar);                                                              
                                                                      _comunicarValue = usuariosSeleccionadosComunicar > 0 ? true : null;                                                                                                                            
                                                                      usuariosSeleccionadosComunicar = 0;
                                                                      print(administradoresStatus);
                                                                    });
                                                                }
                                                              ),
                                                              Text(listaAdministradores[index].firstName + ' ' + ((listaAdministradores[index].lastName != null)?listaAdministradores[index].lastName : '' ))
                                                            ],
                                                          );
                                                        }
                                                      ),
                                                      (_comunicarValue != null) ? 
                                                      Container(
                                                        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),             
                                                        child: TextFormField(
                                                          style: TextStyle(
                                                            color: Colors.black
                                                          ),
                                                          controller: null,
                                                          /* initialValue: form_items[count]['response'] != null ? form_items[count]['response'] : null, */
                                                          keyboardType: TextInputType.multiline,
                                                          maxLines: 3,
                                                          decoration: InputDecoration(
                                                            filled: true,
                                                            fillColor: Colors.white,
                                                            hintText: "Comentario",
                                                            hintStyle: TextStyle(color: Colors.grey[700]),                                                  
                                                            enabledBorder: OutlineInputBorder(
                                                              borderSide: BorderSide(color: Colors.transparent, width: 0),
                                                              borderRadius: BorderRadius.circular(10),
                                                            ),
                                                            focusedBorder: OutlineInputBorder(
                                                              borderRadius: BorderRadius.circular(10),
                                                              borderSide: BorderSide(color: Colors.transparent, width: 0),
                                                            ), 
                                                          ),                  
                                                          onChanged: (String value) {
                                                            setState(() {
                                                              _comunicarCuerpo = value;
                                                            });
                                                          },                  
                                                        ),
                                                      )
                                                      :SizedBox(height: 0.0,)
                                                    ],                                            
                                                  ),
                                                )                                                                               
                                              ) :  Container(height: 0.0,) : Container(height: 100.0, child: Center(child: CircularProgressIndicator())),                                                                                                                        
                                            ],
                                          ) : Container(),                                                                                              
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
                                              borderRadius: !_complementarInfo? BorderRadius.circular(10.0) : BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10))),
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
                                                    child: Text('Complementar Información', style: TextStyle(color: Colors.grey[800]))),                        
                                              ]),
                                            ),
                                          ) : Container(),
                                          _complementarInfo ? 
                                          jsonComplementar == null ? 
                                          Container(
                                            padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                                            margin: EdgeInsets.only(bottom: 5.0),                                        
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
                                            child: Padding(
                                              padding: EdgeInsets.only(top: 5.0, bottom: 0.0),
                                              child: TextField(
                                                style: TextStyle(
                                                  color: Colors.black
                                                ),
                                                keyboardType: TextInputType.multiline,
                                                maxLines: 3,
                                                controller: informacionComplementada,
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  hintText: "Complementar Información",
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
                                          ) : Container(height: 0.0,)
                                          : Container(height: 0.0,),
                                          _complementarInfo ?                                      
                                          MostrarMedios() : Container(height: 0.0,),                                   
                                          Medios().audioFiles.length > 0 && Medios().videoFiles.length > 0 && Medios().imageList.length > 0 ? Center(
                                            child: Divider(
                                              color: Colors.grey[800],
                                            ),
                                          ) : Container(height: 0.0,), 
                                          !widget.cerrado ? (widget.subject != 'Responder a' ?
                                          GestureDetector(
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
                                          ) : Container(height: 0.0)) : Container(), 
                                          widget.subject != 'Responder a' ?
                                          _responder ? 
                                          Container(
                                            padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(bottomRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
                                              color: Colors.grey[400],
                                            ),  
                                            child: Column(
                                              children: <Widget>[
                                                Container(
                                                  margin: EdgeInsets.only(bottom: 5.0),                                        
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
                                                  child: Padding(
                                                    padding: EdgeInsets.only(top: 5.0, bottom: 0.0),
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
                                                ),
                                              ],
                                            ),
                                          ): 
                                          Container(height: 0.0,) : Container(height: 0.0,),  
                                          !widget.cerrado ? (jsonAvanzado == null ? 
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                if (_infoAvanzada == true) {
                                                  _infoAvanzada = false;
                                                } else {
                                                  _infoAvanzada = true;
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
                                                borderRadius:(!_infoAvanzada) ? BorderRadius.circular(10.0) : BorderRadius.only(topRight: Radius.circular(10), topLeft: Radius.circular(10))),
                                              child: Row(
                                                children: <Widget>[
                                                Checkbox(
                                                  value: _infoAvanzada,
                                                  onChanged: (bool value) {
                                                    setState(() {
                                                      _infoAvanzada = value;                                
                                                    });
                                                  }),
                                                Container(
                                                    child: Text('Agregar información avanzada', style: TextStyle(color: Colors.grey[800]))),                        
                                              ]),
                                            ),
                                          ) : Container(height: 0.0,)) : Container(),        
                                          _infoAvanzada ? 
                                          Container(
                                            padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
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
                                            child: CoreForm(
                                              form: json.encode(formAvanzado.formAgregarInformacion),
                                              onChanged: (dynamic response) {
                                                responseFormAvanzado = response;    
                                                var jsonAvanzado = {'formAgregarInfo' : responseFormAvanzado};
                                                print(response);
                                                DatosForm().formAvanzdo = jsonAvanzado;
                                              },
                                            ),
                                          ) : 
                                          Container(height: 0.0,),                                                                     
                                          !widget.cerrado ? Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: <Widget>[
                                              Container(
                                                margin: EdgeInsets.only(bottom: 10.0, top: 10.0),
                                                width: 165.0,
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
                                                        padding: EdgeInsets.only(left: 10.0),
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
                                  )
                                )
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
}
