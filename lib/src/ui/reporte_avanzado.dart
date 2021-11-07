import 'dart:convert';
import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:nuevo_riesgos/src/blocs/forms_bloc.dart';
import 'package:nuevo_riesgos/src/blocs/medios_local_bloc.dart';
import 'package:nuevo_riesgos/src/models/forms_model.dart';
import 'package:nuevo_riesgos/src/resources/datos/datos_form.dart';
import 'package:nuevo_riesgos/src/resources/datos/datos_usuario.dart';
import 'package:nuevo_riesgos/src/resources/grabar_reproducir/mostrar_medios.dart';
import 'package:nuevo_riesgos/src/resources/plugins/json_form.dart';
import 'package:nuevo_riesgos/src/resources/proveedor_servicio_obras.dart';
import 'package:http/http.dart' show Client;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nuevo_riesgos/src/resources/constantes.dart' as constantes;
import 'package:intl/intl.dart';

class ReporteAvanzado extends StatefulWidget {    
  final FormsBloc _bloc;  
  ReporteAvanzado(this._bloc);   

  @override
  _ReporteAvanzadoState createState() => _ReporteAvanzadoState();
}

class _ReporteAvanzadoState extends State<ReporteAvanzado> {  

  Future futureJson;
  final _blocVideo = VideosBLoc();
  final urlServicios = constantes.urlBase;

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
  
  var listaAdministradores;
  var listaAdministradoresPreFiltro;
  Client client;
  var estiloTitle = TextStyle(fontSize: 13.0, color: Colors.black, /* fontWeight: FontWeight.w700 */);
    
  getAdministradores() async {
    await ServiciosConecta(client).obtenerAdministradores(DatosUsuario().locationId).then((response) {
      listaAdministradoresPreFiltro = response.supervisores;
      setState(() {
        listaAdministradores = listaAdministradoresPreFiltro.toSet().toList();
      });
      print('lista administradores');
      print(listaAdministradores);
    });
  }

  setObraApp() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString('locationId', DatosUsuario().locationId.toString());
    prefs.setString('nombreObraActual', DatosUsuario().nombreObraActual);
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
    getAdministradores();    
    buscarForms();  
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
    _blocVideo.dispose();
    super.dispose();
  }

  var responseForm;      
  var responseFormAvanzado;
  var responseComunicar1;
  var responseComunicar2;
  var responseEstado;
  List formularioCompleto = [];    
  bool _infoAvanzada = false;  

  String tipoRiesgo;
  String gravedad;
  var resultadoGrabacion;  
  var videoFile;  

  bool subiendoReporte = false;
  bool reporteSubido = false;

  List<String> formValido = List<String>();

  void _mostrarDialogValidacion(texto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(          
          content: Text(texto),
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
        return StatefulBuilder(builder: (context, StateSetter setState) {
          return SizedBox(            
            child: Material(  
              color: Colors.transparent,
              child: Center(
                child: Container(                    
                  decoration: BoxDecoration(
                    color: Colors.white,   
                    borderRadius: BorderRadius.all(Radius.circular(5.0))
                  ),
                  width: 270,
                  height: 135.0,                      
                  padding: EdgeInsets.all(10.0),                             
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,                    
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
                                setState(() {
                                  subiendoReporte = true;
                                });
                                /* Validacion */
                                for(var i = 0; DatosForm().formPrincipal['formPrincipal'].length > i; i++) {                      
                                  if (DatosForm().formPrincipal['formPrincipal'][i]['type'] == 'Dropdown') {
                                    if (DatosForm().formPrincipal['formPrincipal'][i]['value'] == '') {
                                      Navigator.pop(context);
                                      _mostrarDialogValidacion('Por favor rellena todos los campos del formulario');
                                      setState(() {
                                        subiendoReporte = false;
                                      });
                                      formValido.add('false');                                      
                                    }
                                  } else {
                                    if (DatosForm().formPrincipal['formPrincipal'][i]['response'] == '') {
                                      Navigator.pop(context);
                                      _mostrarDialogValidacion('Por favor rellena todos los campos del formulario');
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
                                        _mostrarDialogValidacion('Asegúrate que la fecha y hora sean anterior o igual al momento actual');
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
                                  _mostrarDialogValidacion('Por favor selecciona una persona a quien comunicar el incidente');
                                  setState(() {
                                    subiendoReporte = false;
                                  });
                                  formValido.add('false'); 
                                } 
                                if (_valorEstado == null) {
                                  Navigator.pop(context);
                                  _mostrarDialogValidacion('Por favor selecciona un estado de incidente');
                                  setState(() {
                                    subiendoReporte = false;
                                  });
                                  formValido.add('false'); 
                                }                 
                                if (formValido.length == 0) {
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
                                    var reporteCompleto = {"reporteCompleto" : [DatosForm().formPrincipal, DatosForm().formAvanzdo ?? DatosForm().formAvanzdo]};                        
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
                                    .then((response) async {
                                      /* print('response interno ${response.body}');   */
                                      if (response != null) {
                                        DatosUsuario().gravedad = null;
                                        DatosUsuario().tipoIncidente = null;
                                        DatosUsuario().fechaIncidente = null;
                                        if (json.decode(response.body)['message'] == 'java.lang.Exception: usuario desactivado') {
                                          Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
                                        } else {
                                          if (_valorEstado != null) {                  
                                            await  ServiciosConectaDio().cambiarEstado(json.decode(response.body)['body']['incidenteId'], _valorEstado);
                                          }
                                          /* if (_comunicarCuerpo != null) {
                                            ServiciosConectaPost().enviarMensaje(_comunicarValue, widget.threadId, json.decode(response.body)['body']['incidenteId'], widget.parentMessageId, '2', _comunicarCuerpo);                  
                                          } */
                                          setState(() {
                                            reporteSubido = true;
                                          });   
                                          Future.delayed(Duration(seconds: 2), () {  
                                            DatosUsuario().valorActivos = null;
                                            DatosUsuario().filtroGravedad = null;
                                            DatosUsuario().filtroObra = null;                      
                                            Navigator.pushNamed(context, 'mainAvanzado');
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
                  )                                
                  ),
              ),
            ),
          );
        });
      }
    );
  }         

  var _comunicarValue;
  var _valorEstado;
      
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
                        form: json.encode(snapshot.data.formPrincipal),
                        onChanged: (dynamic response) {                                                    
                          responseForm = response; 
                          var jsonPrincipal = {'formPrincipal' : responseForm};
                          DatosForm().formPrincipal = jsonPrincipal;                          
                        },                        
                      ),   
                      Padding(
                        padding: EdgeInsets.only(top: 5.0),
                        child: new Stack(
                          children: <Widget>[
                            /* new Positioned(
                              top: -2.0,
                              child: new Text(
                                'Comunicar a',
                                style: new TextStyle(fontSize: 13.0, color: Colors.black),
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
                                    child: FittedBox(child: Text('Comunicar a'), fit: BoxFit.contain),
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
                                      underline: Container(
                                        height: 0.0,
                                        color: Colors.black,
                                      ),
                                      isExpanded: true,
                                      hint: FittedBox(child: Text('Selecciona una opción'), fit: BoxFit.contain),
                                      value: _comunicarValue,
                                      /* hint: Text('', style: TextStyle(color: Colors.red[100]),), */
                                      onChanged: (String valorNuevo) {
                                        this.setState(() {                  
                                          /* _dropValue = valorNuevo; */
                                          _comunicarValue = valorNuevo;       
                                        });
                                      },
                                      items: [
                                        for (var i = 0; i<listaAdministradores.length; i++) 
                                          DropdownMenuItem<String>(
                                            value: listaAdministradores[i].userId.toString(),
                                            child: Text(listaAdministradores[i].firstName + ' ' + ((listaAdministradores[i].lastName != null)?listaAdministradores[i].lastName : '' ), style: TextStyle(fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.w600),),
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
                            Padding(
                              padding: EdgeInsets.only(top: 15.0),
                              child: Center(
                                child: Divider(
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),                            
                            Padding(
                              padding: EdgeInsets.only(top: 5.0),
                              child: new Stack(
                                children: <Widget>[
                                  /* new Positioned(
                                    top: -2.0,
                                    child: new Text(
                                      'Estado',
                                      style: new TextStyle(fontSize: 13.0, color: Colors.black),
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
                                          child: FittedBox(child: Text('Estado'), fit: BoxFit.contain),
                                        ),
                                        Container(
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
                                          borderRadius: BorderRadius.circular(10)),
                                          child: DropdownButton<String>(
                                            icon: Icon(Icons.keyboard_arrow_down),  
                                            isExpanded: true,       
                                            hint: FittedBox(child: Text('Selecciona una opción'), fit: BoxFit.contain),
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
                                                  child: Text('Pendiente', style: TextStyle(fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.w600),),
                                                ),
                                                DropdownMenuItem<String>(
                                                  value: '1',
                                                  child: Text('En proceso', style: TextStyle(fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.w600),),
                                                ),
                                                DropdownMenuItem<String>(
                                                  value: '2',
                                                  child: Text('Resuelto', style: TextStyle(fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.w600),),
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
                            /* Padding(
                              padding: EdgeInsets.only(top: 25.0),
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  canvasColor: Colors.red[800]
                                ),
                                child: Stack(
                                  children: <Widget>[
                                    Positioned(
                                  top: -3.0,
                                  child: Text(
                                    'Comunicar a',
                                    style: TextStyle(
                                      color: Colors.red[100],
                                    ),
                                  ),
                                ),
                                DropdownButton<String>(
                                  value: _comunicar1,
                                  hint: Text('', style: TextStyle(color: Colors.white),),
                                  onChanged: (String valorNuevo) {
                                    setState(() {
                                      _comunicar1 = valorNuevo;
                                    });
                                  },
                                  items: <String>['Usuario', 'Supervisor de Obra', 'Administrador de Obra']
                                    .map<DropdownMenuItem<String>>((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text('$value', style: TextStyle(color: Colors.white),),
                                      );
                                    })
                                    .toList(),
                                ),
                                  ],
                                ),
                              ),
                            ),
                            (_comunicar1 != null) ? (
                              Column( 
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(top: 5.0, bottom: 10.0),
                                    child: TextField(
                                      style: TextStyle(
                                        color: Colors.white
                                      ),
                                      keyboardType: TextInputType.multiline,
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                        hintText: "Comentario",
                                        hintStyle: TextStyle(color: Colors.red[100]),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Theme.of(context).accentColor)
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Theme.of(context).accentColor)
                                        ), 
                                      )
                                    ),
                                  ),
                                  Theme(
                                  data: Theme.of(context).copyWith(
                                    canvasColor: Colors.red[800]
                                  ),
                                  child: Stack(
                                    children: <Widget>[
                                      Positioned(
                                    top: -3.0,
                                    child: Text(
                                      'Comunicar a',
                                      style: TextStyle(
                                        color: Colors.red[100],
                                      ),
                                    ),
                                  ),
                                  DropdownButton<String>(
                                    value: _comunicar2,
                                    hint: Text('', style: TextStyle(color: Colors.white),),
                                    onChanged: (String valorNuevo) {
                                      setState(() {
                                        _comunicar2 = valorNuevo;
                                      });
                                    },
                                    items: <String>['Usuario', 'Supervisor de Obra', 'Administrador de Obra']
                                      .map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text('$value', style: TextStyle(color: Colors.white),),
                                        );
                                      })
                                      .toList(),
                                  ),
                                    ],
                                  ),
                                ),
                                _comunicar2 != null ? 
                                Padding(
                                    padding: EdgeInsets.only(top: 5.0, bottom: 10.0),
                                    child: TextField(
                                      style: TextStyle(
                                        color: Colors.white
                                      ),
                                      keyboardType: TextInputType.multiline,
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                        hintText: "Comentario",
                                        hintStyle: TextStyle(color: Colors.red[100]),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Theme.of(context).accentColor)
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Theme.of(context).accentColor)
                                        ), 
                                      )
                                    ),
                                  )
                                :
                                Text('')
                                ],
                              )
                            ) : (Text('')),  */                                             
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
                                      child: Text('Agregar información avanzada', style: TextStyle(color: Colors.black))),                        
                                ]),
                              ),
                            ),        
                            (_infoAvanzada) ? 
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
                                form: /* DatosForm().formAvanzdo != null ? DatosForm().formAvanzdo :  */json.encode(snapshot.data.formAgregarInformacion),
                                onChanged: (dynamic response) {
                                  responseFormAvanzado = response;    
                                  var jsonAvanzado = {'formAgregarInfo' : responseFormAvanzado};
                                  print(response);
                                  DatosForm().formAvanzdo = jsonAvanzado;
                                },
                              ),
                            ) : 
                            Container(height: 0.0,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(bottom: 20.0, top: 10.0),
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