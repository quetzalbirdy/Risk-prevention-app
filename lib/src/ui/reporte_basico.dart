import 'dart:convert';
import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:nuevo_riesgos/src/blocs/forms_bloc.dart';
import 'package:nuevo_riesgos/src/models/forms_model.dart';
import 'package:nuevo_riesgos/src/resources/datos/datos_form.dart';
import 'package:nuevo_riesgos/src/resources/datos/datos_usuario.dart';
import 'package:nuevo_riesgos/src/resources/grabar_reproducir/mostrar_medios.dart';
import 'package:nuevo_riesgos/src/resources/plugins/json_form.dart';
import 'package:nuevo_riesgos/src/resources/proveedor_servicio_dio.dart';
import 'package:nuevo_riesgos/src/resources/proveedor_servicio_obras.dart';
import 'package:nuevo_riesgos/src/resources/datos/medios.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' show Client;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nuevo_riesgos/src/resources/constantes.dart' as constantes;
import 'package:intl/intl.dart';



class ReporteBasico extends StatefulWidget {
  final FormsBloc _bloc;  
  ReporteBasico(this._bloc);   

  @override
  _ReporteBasicoState createState() => _ReporteBasicoState();
}

class _ReporteBasicoState extends State<ReporteBasico> {
  final urlServicios = constantes.urlBase;
  Future futureJson;
  Client client;
  var listaSupervisores;
  var listaSupervisoresPreFiltro;
  var _comunicarValue;
  bool subiendoReporte = false;
  bool reporteSubido = false;

  buscarForms() async {
    var connectivityResult = await (Connectivity().checkConnectivity());  
    print(connectivityResult);
    if (connectivityResult == ConnectivityResult.none) {
      Fluttertoast.showToast(
        msg: 'No hay conexión a internet, intente nuevamente',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,          
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,                                                       
      );
    } else {      
      widget._bloc.init();  
      widget._bloc.fetchForms(); 
      setState(() {
        
      });
    }
  }
  getSupervisores() async {
    await ServiciosConecta(client).obtenerSupervisores(DatosUsuario().locationId.toString()).then((response) {
      listaSupervisoresPreFiltro = response.supervisores;
      setState(() {
        listaSupervisores = listaSupervisoresPreFiltro.toSet().toList();
      });
      print('lista supervisores');
      print(listaSupervisores);
    });

  }

  setObraApp() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('locationId', DatosUsuario().locationId.toString());
    prefs.setString('nombreObraActual', DatosUsuario().nombreObraActual);
    print('obra acutal');
    print(prefs.getString('nombreObraActual'));
  }

  var timestamp;

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
  }

  @override 
  void initState() {   
    generarTimestamp();
    buscarForms();   
    getSupervisores();          
    setObraApp(); 
    setState(() {
      videoFile = null;
      resultadoGrabacion = null;
      responseForm = null;      
      responseFormAvanzado = null;
      responseComunicar1 = null;
      responseComunicar2 = null;
      responseEstado = null;    
      /* getJson(); */
    }); 
    /* print(jsonAgregarInfo); */
    super.initState();   
  }   

  @override
  void dispose() {
    widget._bloc.dispose();
    super.dispose();
  }

  var responseForm;      
  var responseFormAvanzado;
  var responseComunicar1;
  var responseComunicar2;
  var responseEstado;
  List formularioCompleto = [];   
  
  String tipoRiesgo;
  String gravedad;
  var resultadoGrabacion;
  var videoFile;    

  List<String> formValido = List<String>();

  void _mostrarDialogValidacion() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(          
          content: Text('Por favor rellena todos los campos del formulario'),
          actions: <Widget>[           
            MaterialButton(
              minWidth: 90.0,
              child: Text('Ok'),
              shape: StadiumBorder(),
                textColor: Colors.white,
                color: Theme.of(context).accentColor,
                elevation: 1.0,
              onPressed: () async {   
                formValido = [];  
                Navigator.pop(context);                                         
              },
            ),                        
          ],
        );
      }
    );
  } 
  void _mostrarDialogFecha() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(          
          content: Text('Asegúrate que la fecha sea anterior o igual al momento actual'),
          actions: <Widget>[           
            MaterialButton(
              minWidth: 90.0,
              child: Text('Ok'),
              shape: StadiumBorder(),
                textColor: Colors.white,
                color: Theme.of(context).accentColor,
                elevation: 1.0,
              onPressed: () async {   
                formValido = [];  
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
        return 
         StatefulBuilder(builder: (context, StateSetter setState) {
           return Material(      
            color: Colors.transparent,
            child:
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,   
                  borderRadius: BorderRadius.all(Radius.circular(5.0))
                ),
                width: 270,
                height: 135.0,                      
                padding: EdgeInsets.all(10.0), 
                child: Column(
                  children: [
                    reporteSubido == true ?
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Gracias por tu ayuda a mantener un lugar de trabajo seguro'),
                    ) :
                     subiendoReporte == true ?
                     Column(
                       mainAxisSize: MainAxisSize.min,
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: <Widget>[
                        Center(child: CircularProgressIndicator(),)
                      ]
                     ) :
                     Padding(
                       padding: const EdgeInsets.all(8.0),
                       child: Text('Presione "Ok" para guardar la información y "Cancelar", para seguir editándola'),
                     ),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
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
                              /* Partir Loading */
                              setState(() {
                                subiendoReporte = true;
                              });
                              /* Validacion */
                              for(var i = 0; DatosForm().formPrincipal['formPrincipal'].length > i; i++) {
                                if (DatosForm().formPrincipal['formPrincipal'][i]['type'] == 'Dropdown') {
                                  if (DatosForm().formPrincipal['formPrincipal'][i]['value'] == '') {
                                    Navigator.pop(context);
                                    _mostrarDialogValidacion();
                                    setState(() {
                                      subiendoReporte = false;
                                    });
                                    formValido.add('false');                                      
                                  }
                                } else {
                                  if (DatosForm().formPrincipal['formPrincipal'][i]['response'] == '') {
                                    Navigator.pop(context);
                                    _mostrarDialogValidacion();
                                    setState(() {
                                      subiendoReporte = false;
                                    });
                                    formValido.add('false');                                     
                                  }
                                  if (DatosForm().formPrincipal['formPrincipal'][i]['type'] == 'FechaHora') {                          
                                    var fechaInput = (DatosUsuario().fechaIncidente);
                                    var fechaActual = DateTime.now();                           
                                    if (fechaActual.difference(DateFormat("dd-MM-yyyy - HH:mm").parse(fechaInput)).isNegative) {                                
                                      Navigator.pop(context);
                                      _mostrarDialogFecha();
                                      setState(() {
                                        subiendoReporte = false;
                                      });
                                      formValido.add('false'); 
                                    }                                                                                                         
                                  }
                                }                         
                              }     
                              if (_comunicarValue == null) {
                                Navigator.pop(context);
                                _mostrarDialogValidacion();
                                setState(() {
                                  subiendoReporte = false;
                                });
                                formValido.add('false'); 
                              }         
                              if (formValido.length == 0) {
                                /* Servicios */
                                var connectivityResult = await (Connectivity().checkConnectivity());  
                                if (connectivityResult == ConnectivityResult.none) {
                                  Fluttertoast.showToast(
                                    msg: 'No hay conexión a internet, intente nuevamente',
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.CENTER,          
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0,                                                       
                                  );
                                  setState(() {
                                    subiendoReporte = false;
                                  });
                                } else {
                                  var reporteCompleto = {"reporteCompleto" : [DatosForm().formPrincipal, DatosForm().formAvanzdo ?? DatosForm().formAvanzdo, DatosForm().formEstado ?? DatosForm().formEstado, DatosForm().formComunicar1 ?? DatosForm().formComunicar1, DatosForm().formComunicar2 ?? DatosForm().formComunicar2]};                                  
                                  await ServiciosConectaDio().crearIncidente('0', DatosUsuario().tipoIncidente.toString(), json.encode(reporteCompleto), DatosUsuario().locationId.toString(), _comunicarValue, 'http://$urlServicios/api/jsonws/vs-bpm-screen-portlet.incidente/create', DatosUsuario().gravedad.toString(), (DateFormat("dd/MM/yyyy-HH:mm").format(DateFormat("dd-MM-yyyy - HH:mm").parse(DatosUsuario().fechaIncidente)).toString()), timestamp)
                                  .timeout(
                                    Duration(seconds: 20),
                                    onTimeout: () {
                                      Fluttertoast.showToast(
                                        msg: 'Conexión inestable, intente nuevamente',
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.CENTER,          
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 16.0,                                                       
                                      );
                                      setState(() {
                                        subiendoReporte = false;
                                      });   
                                      return null; 
                                    }
                                  )
                                  .then((response)async {   
                                    print('response interno ${response.body}');   
                                    if (response != null) {
                                      DatosUsuario().gravedad = null;       
                                      DatosUsuario().tipoIncidente = null;         
                                      DatosUsuario().fechaIncidente = null;  
                                      if (json.decode(response.body)['message'] == 'java.lang.Exception: usuario desactivado') {
                                        Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
                                      } else {
                                        setState(() {
                                          reporteSubido = true;
                                        });  
                                        Future.delayed(Duration(seconds: 2), () {                        
                                          Navigator.pushNamedAndRemoveUntil(context, 'inicio', (route) => false);
                                        });
                                      }                                                                             
                                    }                                                                       
                                  });                                                                                              
                                }                                 
                              }                                                               
                            },
                          ) : Container(height: 0.0,), 
                       ],
                     )
                  ],
                ),
              ),
            ),            
          );
         });
      }
    );
  } 

  Future<void> subirMedios(incidenteId) async {
    if (Medios().imageList != null) {
      for (var count = 0; count < Medios().imageList.length; count++) {
        await ServiciosConectaPostDio().subirMediosArchivo(incidenteId, '25728', '223645', '25754', 'http://$urlServicios/api/jsonws/vs-bpm-screen-portlet.incidente/add-file-entry', Medios().imageList[count].path); 
        if (count == Medios().imageList.length-1) {
          Fluttertoast.showToast(
              msg: 'se subieron las imagenes',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,          
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0
          );
        }
      }                   
    } 
    if (Medios().audioFiles != null) {
      for (var count = 0; count < Medios().audioFiles.length; count++) {
        await ServiciosConectaPostDio().subirMediosArchivo(incidenteId, '25728', '223645', '25754', 'http://$urlServicios/api/jsonws/vs-bpm-screen-portlet.incidente/add-file-entry', Medios().audioFiles[count]); 
        if (count == Medios().audioFiles.length-1) {
          Fluttertoast.showToast(
              msg: 'se subieron los audios',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,          
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0
          );
        }
      } 
    } 
    if (Medios().videoFiles != null) {
      for (var count = 0; count < Medios().videoFiles.length; count++) {
        await ServiciosConectaPostDio().subirMediosArchivo(incidenteId, '25728', '223645', '25754', 'http://$urlServicios/api/jsonws/vs-bpm-screen-portlet.incidente/add-file-entry', Medios().videoFiles[count].path); 
        if (count == Medios().videoFiles.length-1) {
          Fluttertoast.showToast(
              msg: 'se subieron los videos',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,          
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0
          );
        }
      } 
    }      
  }    
  
  String jsonComunicar;
  String jsonEstadoSolucion;
  String jsonAgregarInfo;

  Future<String> getJson() async {
    var response = await http.get('http://my-json-server.typicode.com/quetzalsa/json-ejemplos/db');
    setState(() {        
      jsonComunicar = json.encode(json.decode(response.body)['formComunicar']);  
      jsonEstadoSolucion = json.encode(json.decode(response.body)['formEstadoSolucion']);  
      jsonAgregarInfo = json.encode(json.decode(response.body)['formAgregarInfo']);                             
    });
    return 'succesufull';
  } 
      
  @override  
  Widget build(BuildContext context) {          
    return new Scaffold(
      backgroundColor: Colors.grey[300],
      /* backgroundColor: Colors.yellow, */
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Padding(
          padding: EdgeInsets.only(left: 0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Generando Reporte en:', style: TextStyle(fontSize: 15.0),),
              Text(DatosUsuario().nombreObraActual, style: TextStyle(fontSize: 15.0),),
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
          child: StreamBuilder(
            stream: widget._bloc.allForms,
            builder: (context, AsyncSnapshot<FormsModel> snapshot) {
              if (snapshot.hasData) {
                return buildForms(snapshot);
              } else if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }
              return Center(child: CircularProgressIndicator(),);
            },
          ),
      )));        
    
  }
  Widget buildForms(AsyncSnapshot<FormsModel> snapshot) {
    return LayoutBuilder(builder: (builder, constraints) {
      return ListView(
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.only(top: 20.0),
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30.0),
            width: MediaQuery.of(context).size.width * 0.5,
            alignment: FractionalOffset.center,
            child: 
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                CoreForm(
                  form: /* (DatosForm().formPrincipal != null) ? DatosForm().formPrincipal :  */json.encode(snapshot.data.formPrincipal),
                  onChanged: (dynamic response) {                                                    
                    responseForm = response; 
                    var jsonPrincipal = {'formPrincipal' : responseForm};
                    DatosForm().formPrincipal = jsonPrincipal;                          
                  },                                                           
                ), 
                listaSupervisores != null ? Padding(
                        padding: EdgeInsets.only(top: 5.0),
                        child: new Stack(
                          children: <Widget>[
                            /* new Positioned(
                              top: -2.0,
                              child: new Text(
                                'Reportar a',
                                style: TextStyle(fontSize: 13.0, color: Colors.black, /* fontWeight: FontWeight.w700 */),
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
                                    child: FittedBox(child: Text('Reportar a'), fit: BoxFit.contain),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 7,
                                          offset: Offset(0, 5), // changes position of shadow
                                        ),
                                      ],
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10)),
                                    child: DropdownButton<String>(
                                      icon: Icon(Icons.keyboard_arrow_down),  
                                      isExpanded: true,
                                      underline: Container(
                                        height: 0.0,
                                        color: Colors.black,
                                      ),
                                      hint: FittedBox(child: Text('Selecciona una opción', style: TextStyle(fontSize: 15.0)), fit: BoxFit.contain),
                                      value: _comunicarValue,
                                      /* hint: Text('', style: TextStyle(color: Colors.red[100]),), */
                                      onChanged: (String valorNuevo) {
                                        this.setState(() {                  
                                          /* _dropValue = valorNuevo; */
                                          _comunicarValue = valorNuevo;       
                                        });
                                      },
                                      items: [
                                        for (var i = 0; i<listaSupervisores.length; i++) 
                                          DropdownMenuItem<String>(
                                            value: listaSupervisores[i].userId.toString(),
                                            child: Text(listaSupervisores[i].firstName + ' ' + listaSupervisores[i].lastName, style: TextStyle(fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.w600),),
                                          ),
                                      ],              
                                    ),
                                  ),
                                ],
                              ),
                            ), 
                          ]
                        )
                      ) : Container(height: 100.0, child: Center(child: CircularProgressIndicator())), 
                       Container(
                        height: 30.0,
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
                      ) ,                   
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 0.0,),
                        alignment: Alignment.centerLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[                                                                                                                                                                     
                            MostrarMedios(),                                                                                                                                                                                                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Container(
                                  width: 165.0,
                                  margin: EdgeInsets.only(bottom: 20.0, top: 10.0),
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
                            )
                          ],
                        )
                      )
                    ],
                  ) ,                                          
                ),
                // Container(
                //   padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                //   child: SizedBox(
                //     height: _imageList.length < 1 ? 0.0 : 200.0,
                //     child: ListView.builder(
                //     scrollDirection: Axis.horizontal,
                //     itemCount: _imageList.length,
                //     itemBuilder: (context, index) {
                //       return new InkWell(
                //           onTap: () {
                //             return null;
                //           },
                //           child: Card(
                //             color: Theme.of(context).accentColor,
                //             child: Container(
                //               child: Padding(
                //                 padding: const EdgeInsets.all(8.0),
                //                 child: Image.file(File(_imageList[index].path)),
                //               ),
                //             ),
                //           ));
                //     }),
                //   )
                // ),
                /* myController.text == '' ? Text('') : 
                InkWell(
                  onTap: () {
                    _showDialog();
                  },
                  child: Card(
                    color: Theme.of(context).accentColor,
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(myController.text),
                      ),
                    ),
                  )), */
              ],);
          },
        );
   }  
}