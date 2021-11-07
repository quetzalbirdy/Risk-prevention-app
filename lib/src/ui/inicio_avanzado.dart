import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:nuevo_riesgos/src/blocs/mensajes_bloc.dart';
import 'package:nuevo_riesgos/src/models/mensajes_model.dart';
import 'package:nuevo_riesgos/src/resources/datos/datos_usuario.dart';
import 'package:nuevo_riesgos/src/resources/proveedor_servicio_obras.dart';
import 'package:nuevo_riesgos/src/resources/repositorio.dart';
import 'package:nuevo_riesgos/src/ui/mensaje_avanzado.dart';
import 'package:nuevo_riesgos/src/ui/mensajes_basico.dart';
import 'package:nuevo_riesgos/src/ui/obra.dart';
import 'package:page_transition/page_transition.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nuevo_riesgos/src/ui/informacion.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcase_widget.dart';
import 'package:showcaseview/showcaseview.dart';

class InicioAvanzado extends StatefulWidget {
  final MensajesBloc _bloc;    
  InicioAvanzado(this._bloc,);  

  @override
  _InicioAvanzadoState createState() => _InicioAvanzadoState();
}

class _InicioAvanzadoState extends State<InicioAvanzado> with WidgetsBindingObserver {

  /* String incidentes; 
  var cantIncidentes;

  void evaluarDatosBase() async {       
    var response = await http.get('http://my-json-server.typicode.com/quetzalsa/json-incidentes/db');
    setState(() {
      incidentes = json.encode(json.decode(response.body)['incidentes']);
    });      
    cantIncidentes = json.decode(incidentes).length;
    print(json.decode(json.encode(json.decode(incidentes)[0]['data_'][0][0]['list'][4]['title']))); 
  } */

  GlobalKey _one = GlobalKey();
  GlobalKey _two = GlobalKey();
  GlobalKey _three = GlobalKey();
  GlobalKey _four = GlobalKey();
  GlobalKey _five = GlobalKey();
  BuildContext myContext;

  bool mostrarActivos = false;
  bool valorActivos = false;
  String filtroObra;
  String valorObra;
  int filtroGravedad;  
  String valorGravedad;

  @override
  void initState() {    
    super.initState();         
    getMensajes();
    getUnreadAndAtrasados();              
    showcaseCheck();
    getTipoUsuario(); 
    getPermission();    
    WidgetsBinding.instance.addObserver(this);   
  }

  @override
  void dispose() {
    widget._bloc.dispose();    
    super.dispose();
  }
  
  getPermission() async {
    Location location = new Location();
    PermissionStatus _permissionGranted;
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }
  }

  getMensajes() async {
    widget._bloc.init();    
    await widget._bloc.fetchListaMensajes();      
    if (DatosUsuario().valorActivos != null) {
      setState(() {
        valorActivos = DatosUsuario().valorActivos;
        mostrarActivos = valorActivos;
      });
    } 
    if (DatosUsuario().filtroGravedad != null) {
      setState(() {
        valorGravedad = DatosUsuario().filtroGravedad;
         if (valorGravedad == 'Baja') {
            filtroGravedad = 0;
          } else if (valorGravedad == 'Media') {
            filtroGravedad = 1;
          } else if (valorGravedad == 'Alta') {
            filtroGravedad = 2;
          }
      });
    }
    if (DatosUsuario().filtroObra != null) {
      setState(() {
        filtroObra = DatosUsuario().filtroObra;
      });
    }
  }

  List listaObras = [];

  String tipoUsuario;
  getTipoUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();   
    setState(() {
      tipoUsuario = prefs.getString('tipoDeUsuario');    
    });                            
  }

  showReporteDialog(nombreObra) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(          
          content: Text('¿Quieres seguir en "$nombreObra"?'),
          actions: <Widget>[    
            MaterialButton(
              minWidth: 90.0,
              child: Text('Seleccionar nueva'),
              shape: StadiumBorder(),
                    textColor: Colors.white,
                    color: Theme.of(context).accentColor,
                    elevation: 1.0,
              onPressed: () {
                DatosUsuario().valorActivos = null;
                DatosUsuario().filtroGravedad = null;
                DatosUsuario().filtroObra = null;
                Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: ObraAvanzado()));
              },
            ),         
            MaterialButton(
              minWidth: 90.0,
              child: Text('Seguir en obra'),
              shape: StadiumBorder(),
                    textColor: Colors.white,
                    color: Theme.of(context).accentColor,
                    elevation: 1.0,
              onPressed: () async {
                var prefs = await SharedPreferences.getInstance();
                DatosUsuario().locationId = int.parse(prefs.getString('locationId'));
                DatosUsuario().nombreObraActual = prefs.getString('nombreObraActual');
                DatosUsuario().valorActivos = null;
                DatosUsuario().filtroGravedad = null;
                DatosUsuario().filtroObra = null;
                Navigator.pushNamed(
                  context, 
                  tipoUsuario == 'AVANZADO' ? 'reporte' : 'reporteBasico',
                );
              },
            ),                        
          ],
        );
      }
    );
  }

  showIncidenteAtrasado() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(          
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.report_problem, color: Colors.red, size: 100.0),
              Text('Tienes al menos un incidente grave que no ha sido resuelto en las últimas 24 horas')
            ],
          ),
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

  showFiltros(listaMensajes) {
    for (var mensaje in listaMensajes) {
      /* print(mensaje.nombreObra); */
      if (!(listaObras.contains(mensaje.nombreObra))) {
        listaObras.add(mensaje.nombreObra);
      }      
    }    
    print(listaObras);
    showDialog(      
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(          
          backgroundColor: Colors.grey[300],
          /* title: Text('Filtrar por', style: TextStyle(fontSize: 20.0),), */
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {                      
                      setState(() {                        
                        valorActivos = !valorActivos;                                
                        DatosUsuario().valorActivos = valorActivos;
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
                          value: valorActivos,
                          onChanged: (bool value) {
                            setState(() {                              
                              valorActivos = value;                                 
                            });
                          }),
                        Container(
                            child: Text('Reportes pendientes', style: TextStyle(color: Colors.black))),                        
                      ]),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Filtrar por Obra'),
                        Container(
                          margin: EdgeInsets.only(top: 5.0),
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
                            isExpanded: true,                
                            hint: FittedBox(child: Text('Selecciona una opción', style: TextStyle(fontSize: 15.0),), fit: BoxFit.contain,),                                                
                            underline: Container(height: 0.0),                            
                            value: filtroObra,                                                
                            onChanged: (String valorNuevo) {
                              setState(() {
                                filtroObra = valorNuevo;                                                            
                              });
                            },
                            
                            items: [
                              for (var obra in listaObras) 
                                DropdownMenuItem<String>(                                                    
                                  value: obra,
                                  child: Text(obra),
                                )                              
                            ],              
                          ),
                        )
                      ],
                    )
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Filtrar por Gravedad'),
                        Container(
                          margin: EdgeInsets.only(top: 5.0),
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
                            isExpanded: true,                
                            hint: FittedBox(child: Text('Selecciona una opción', style: TextStyle(fontSize: 15.0),), fit: BoxFit.contain,),                                                
                            underline: Container(height: 0.0),                            
                            value: valorGravedad,                                                
                            onChanged: (String valorNuevo) {
                              setState(() {                                                                
                                valorGravedad = valorNuevo;                                                           
                              });
                            },
                            
                            items: [
                              DropdownMenuItem<String>(                                                    
                                value: 'Baja',
                                child: Text('Baja'),
                              ),
                              DropdownMenuItem<String>(                                                    
                                value: 'Media',
                                child: Text('Media'),
                              ),
                              DropdownMenuItem<String>(                                                    
                                value: 'Alta',
                                child: Text('Alta'),
                              )
                            ],              
                          ),
                        )
                      ],
                    )
                  )
                ],
              );
            }
          ),
          actions: <Widget>[    
            /* MaterialButton(
              minWidth: 90.0,
              child: Text('Cancelar'),
              shape: StadiumBorder(),
                    textColor: Colors.white,
                    color: Theme.of(context).accentColor,
                    elevation: 1.0,
              onPressed: () {
                Navigator.pop(context);
              },
            ),  */        
            MaterialButton(
              minWidth: 90.0,
              child: Text('Aplicar'),
              shape: StadiumBorder(),
                    textColor: Colors.white,
                    color: Theme.of(context).accentColor,
                    elevation: 1.0,
              onPressed: () async {
                setState(() {
                  DatosUsuario().valorActivos = valorActivos;    
                  DatosUsuario().filtroObra = filtroObra;         
                  DatosUsuario().filtroGravedad = valorGravedad;                         
                  if (valorGravedad == 'Baja') {
                    filtroGravedad = 0;
                  } else if (valorGravedad == 'Media') {
                    filtroGravedad = 1;
                  } else if (valorGravedad == 'Alta') {
                    filtroGravedad = 2;
                  }
                  mostrarActivos = valorActivos;
                });
                Navigator.of(context).pop();
                
              },
            ),                        
          ],
        );
      }
    );
  }
  
  showcaseCheck() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();    
    if (prefs.getString('firstLaunch') == null) {
      prefs.setString('firstLaunch', 'true');
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          Future.delayed(Duration(milliseconds: 200), () =>
              ShowCaseWidget.of(myContext).startShowCase([_one, _two, _three, _four])
          );
        }
      );
    }
    /* WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          Future.delayed(Duration(milliseconds: 200), () =>
              ShowCaseWidget.of(myContext).startShowCase([_one, _two, _three, _four])
          );
        }
      ); */                      
  }

  formatDate(fechaMilisegundos) {
    return DateFormat('dd/MM/yyyy – kk:mm').format(DateTime.fromMillisecondsSinceEpoch(fechaMilisegundos));
  }

  getUnreadAndAtrasados() {
    ServiciosConectaDio().fetchUnreadCount();
    ServiciosConectaDio().fetchIncidentesAtrasados().then((response) {
      print('atrasados');
      print(json.decode(response)['body']);
      if (json.decode(response)['body'] == true) {
        showIncidenteAtrasado();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {      
      widget._bloc.fetchListaMensajes(); 
    }        
  }

  @override 
  Widget build(BuildContext context) {    
    return ShowCaseWidget(
      builder: Builder(
        builder: (context) {
          myContext = context;
          return Scaffold(      
            backgroundColor: Colors.white,
            /* appBar: AppBar(
              title: Text(''),
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: Padding(
                padding: EdgeInsets.only(left: 10.0, top: 2.0),
                child: IconButton(
                  icon: Icon(Icons.input), 
                  iconSize: 40.0,
                  color: /* Theme.of(context).accentColor */Colors.transparent, 
                  onPressed: () {
                    /* Navigator.pushNamed(context, 'login'); */
                  },
                  ),
              ),       
            ), */
            body: SafeArea(
              child: Container(  
                    margin: EdgeInsets.only(top: 20.0),    
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Container(
                              alignment: Alignment.topCenter,
                              padding: EdgeInsets.only(top: 0.0),
                              child: GestureDetector(
                                onDoubleTap: () {
                                  // Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: SeleccionObra()));
                                },
                                child: Image.asset('imagenes/logo-ebco.png', width: 130.0,),
                              ),
                            ),
                            /* Container(
                              padding: EdgeInsets.only(top: 10.0),
                              width: 300.0,
                              child: Text('Prevención de Riesgo', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600, height: 0.5, color: Colors.black), textAlign: TextAlign.center,),
                            ), */                
                          ],
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Showcase(
                                  key: _one,                                
                                  title: 'Reportar incidente',                                  
                                  description: 'Genera un reporte',
                                  child: Column(
                                    children: <Widget>[
                                      Container(                      
                                        margin: EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0),          
                                        width: MediaQuery.of(context).size.width * 0.2,
                                        height: MediaQuery.of(context).size.width * 0.2,
                                        /* height: MediaQuery.of(context).size.height * 0.4,                   */
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.rectangle,   
                                          borderRadius: BorderRadius.all(Radius.circular(10.0)), 
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey,
                                              offset: Offset(0.0, 1.0),
                                              blurRadius: 10.0,
                                            ),
                                          ],                                
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.max,
                                              children: <Widget>[
                                                Material(
                                                  type: MaterialType.circle,
                                                  color: Colors.red,
                                                  child: IconButton(
                                                    padding: EdgeInsets.all(0),
                                                    alignment: Alignment.center,
                                                    iconSize: 60.0,
                                                    icon: Image.asset('imagenes/post_add.png')/* Icon(Icons.add_box, color: Colors.white,) */, 
                                                    onPressed: () async {
                                                      var prefs = await SharedPreferences.getInstance();
                                                      if (prefs.getString('nombreObraActual') != null) {
                                                        var nombreObraActual = prefs.getString('nombreObraActual');       
                                                        showReporteDialog(nombreObraActual);                                             
                                                      } else {
                                                        DatosUsuario().valorActivos = null;
                                                        DatosUsuario().filtroGravedad = null;
                                                        DatosUsuario().filtroObra = null;
                                                        Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: ObraAvanzado()));
                                                      }
                                                      /* Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: ObraAvanzado()));                               */
                                                    },
                                                  ),                          
                                                ),                                
                                                // Text('Informar Riesgo', style: TextStyle(color: Colors.white),)
                                              ],
                                            ),                        
                                          ],
                                        ), 
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(right: 0.0, top: 10, bottom: 0.0),
                                        child: Text('Reportar\nincidente', style: TextStyle(color: Colors.black, fontSize: 15.0, fontWeight: FontWeight.w600), textAlign: TextAlign.center,),
                                      )
                                    ],
                                  )
                                ),  
                                Showcase(
                                  key: _two,
                                  title: "Documentos\npreventivos",                                  
                                  description: 'Busca y aprende información\nsobre prevención de riesgo',
                                  child: Column(
                                    children: <Widget>[
                                      Container(                      
                                        margin: EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0),          
                                        width: MediaQuery.of(context).size.width * 0.2,
                                        height: MediaQuery.of(context).size.width * 0.2,
                                        /* height: MediaQuery.of(context).size.height * 0.4,                   */
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.rectangle,   
                                          borderRadius: BorderRadius.all(Radius.circular(10.0)), 
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey,
                                              offset: Offset(0.0, 1.0),
                                              blurRadius: 10.0,
                                            ),
                                          ],                                
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[                        
                                            Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                Material(
                                                  color: Colors.red,
                                                  child: Padding(
                                                    padding: EdgeInsets.only(top: 0.0),
                                                    child: IconButton(
                                                      padding: EdgeInsets.only(top: 0.0),
                                                      iconSize: 50.0,
                                                      icon: Icon(FontAwesomeIcons.info, color: Colors.white,),
                                                      onPressed: () {
                                                        Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: InformacionPrevencionTest()));
                                                      },
                                                    ),
                                                  )
                                                ),                                
                                              ],
                                            ),
                                          ],
                                        ), 
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 10.0, left: 5.0),
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Text('Documentos\npreventivos', style: TextStyle(color: Colors.black, fontSize: 15.0, fontWeight: FontWeight.w600), textAlign: TextAlign.center,)
                                        ),
                                      ),                                
                                    ],
                                  )
                                ),                                            
                                Showcase(
                                  key: _three,
                                  title: 'Historial de reportes',                                  
                                  description: 'Revisa los incidentes que ya has reportado',
                                  child: Column(
                                    children: <Widget>[
                                      Container(                      
                                        margin: EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0),        
                                        width: MediaQuery.of(context).size.width * 0.2,
                                        height: MediaQuery.of(context).size.width * 0.2,
                                        /* height: MediaQuery.of(context).size.height * 0.4,                   */
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.rectangle,   
                                          borderRadius: BorderRadius.all(Radius.circular(10.0)), 
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey,
                                              offset: Offset(0.0, 1.0),
                                              blurRadius: 10.0,
                                            ),
                                          ],                                
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.max,
                                              children: <Widget>[
                                                Material(
                                                  type: MaterialType.circle,
                                                  color: Colors.red,
                                                  child: IconButton(
                                                    padding: EdgeInsets.all(0),
                                                    alignment: Alignment.center,
                                                    iconSize: 60.0,
                                                    icon: Icon(Icons.history, color: Colors.white,), 
                                                    onPressed: () {
                                                      Navigator.pushNamed(context, 'reportesHistoricos');                            
                                                    },
                                                  ),                          
                                                ),                                
                                                // Text('Informar Riesgo', style: TextStyle(color: Colors.white),)
                                              ],
                                            ),                        
                                          ],
                                        ), 
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(right: 0.0, top: 10),
                                        child: Text('Historial\nreportes', style: TextStyle(color: Colors.black, fontSize: 15.0, fontWeight: FontWeight.w600), textAlign: TextAlign.center,),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width ,
                          decoration: BoxDecoration(                
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(5.0),
                              topRight: Radius.circular(5.0)
                            ), 
                            color: Colors.black,               
                          ), 
                          margin: EdgeInsets.symmetric(horizontal: 10.0),              
                          padding: EdgeInsets.symmetric(vertical: 5.0),
                          child: Text(
                            'Notificaciones', 
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.white
                            ),),
                        ),
                        Expanded(              
                          flex: 2,
                          
                          child: Container(                          
                            margin: EdgeInsets.only(top: 0.0, left: 10.0, right: 10.0, bottom: 10.0),
                            decoration: BoxDecoration(
                              /* border: Border.all(width: 2.0, color: Colors.red),  */
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10.0),
                                bottomRight: Radius.circular(10.0)
                              ), 
                              color: Colors.grey[400],                 
                            ),                
                            padding: EdgeInsets.only(top: 0.0, bottom: 5.0, left: 5.0, right: 5.0),
                            child: Stack(
                              children: <Widget>[
                                StreamBuilder(
                                  stream: widget._bloc.allMensajes,
                                  builder: (context, AsyncSnapshot<MensajesModel> snapshot) {
                                    if (snapshot.hasData) {                      
                                      return snapshot.data.mensajes.length > 0 ? buildIncidentes(snapshot) : Center(child: Text('No tienes mensajes', style: TextStyle(fontSize: 20.0)),);
                                    } else if (snapshot.hasError) {
                                      return Text(snapshot.error.toString());
                                    }
                                    return Center(child: CircularProgressIndicator(),);
                                  },
                                ),                              
                              ],
                            )
                            /* ) */                                                                      
                          ),                                                                        
                        )                                            
                      ],
                    ),
                  ),
            )
          );
        }
      )
    );
  }


  Widget buildIncidentes(AsyncSnapshot<MensajesModel> snapshot) {
    List mensajesOrdenados = snapshot.data.mensajes.reversed.toList();
    return Stack(
      children: <Widget>[        
        ListView.builder(                                  
          itemCount: snapshot.data.mensajes.length,
          itemBuilder: (context, index) {             
            if (filtroObra != null || filtroGravedad != null || mostrarActivos == true) {                                                        
              return               
              /* (((filtroObra != null && mensajesOrdenados[index].nombreObra == filtroObra) && (filtroGravedad != null && mensajesOrdenados[index].gravedad == filtroGravedad) && (mostrarActivos == true && mensajesOrdenados[index].estadoIncidente != 'Resuelto')) || (((filtroObra != null && mensajesOrdenados[index].nombreObra == filtroObra) && (filtroGravedad != null && mensajesOrdenados[index].gravedad == filtroGravedad)) || ((filtroObra != null && mensajesOrdenados[index].nombreObra == filtroObra) && (mostrarActivos == true && mensajesOrdenados[index].estadoIncidente != 'Resuelto')) || ((filtroGravedad != null && mensajesOrdenados[index].gravedad == filtroGravedad) && (mostrarActivos == true && mensajesOrdenados[index].estadoIncidente != 'Resuelto'))) || ((filtroObra != null && mensajesOrdenados[index].nombreObra == filtroObra) || (filtroGravedad != null && mensajesOrdenados[index].gravedad == filtroGravedad) || (mostrarActivos == true && mensajesOrdenados[index].estadoIncidente != 'Resuelto'))) ?         */      
              (mensajesOrdenados[index].nombreObra == filtroObra || filtroObra == null) && (mensajesOrdenados[index].gravedad == filtroGravedad || filtroGravedad == null) && (mensajesOrdenados[index].estadoIncidente != 'Resuelto' || mostrarActivos == false) ?
              Card(
                /* color: mensajesOrdenados[index].body == 'Se ha generado un nuevo Incidente' ? Theme.of(context).accentColor : Colors.white, */
                color: mensajesOrdenados[index].isAtrasado == true ? Colors.yellow[300] : Colors.white,
                elevation: 2.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,            
                  children: <Widget>[                    
                    mensajesOrdenados[index].estadoMensaje == 9 ?
                    Container(
                      margin: EdgeInsets.only(left: 10.0),
                      width: 10.0,
                      height: 10.0,
                      decoration: new BoxDecoration(
                        color: Colors.lightBlue[300],
                        shape: BoxShape.circle,
                      ),
                    ) : Container(),                            
                    Expanded(
                      child: index != 0 ?                       
                      Opacity(
                        opacity: mensajesOrdenados[index].cerrado ? 0.6 : 1.0,
                        child: ListTile(                                    
                          /* title: Text(mensajesOrdenados[index].tituloIncidente, style: TextStyle(color: mensajesOrdenados[index].body == 'Se ha generado un nuevo Incidente' ? Colors.black : Theme.of(context).accentColor, fontWeight: FontWeight.w600),), */
                          title: Text(mensajesOrdenados[index].tituloIncidente, style: TextStyle(color: !mensajesOrdenados[index].cerrado ? Theme.of(context).accentColor : Colors.black, fontWeight: FontWeight.w600),),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              /* obra */
                              Row(
                                children: <Widget>[
                                  /* Text('Estado: ', style: TextStyle(color: mensajesOrdenados[index].body == 'Se ha generado un nuevo Incidente' ? Colors.white : Colors.black, fontWeight: FontWeight.w600)), */
                                  Text('Estado: ', style: TextStyle(color:Colors.black, fontWeight: FontWeight.w600)),
                                  /* Text(mensajesOrdenados[index].estadoIncidente, style: TextStyle(color: mensajesOrdenados[index].body == 'Se ha generado un nuevo Incidente' ? Colors.white : Colors.black)), */
                                  Text(mensajesOrdenados[index].estadoIncidente, style: TextStyle(color: Colors.black)),
                                ],
                              ),
                              /* Text(mensajesOrdenados[index].body, style: TextStyle(color: mensajesOrdenados[index].body == 'Se ha generado un nuevo Incidente' ? Colors.white : Colors.black)), */
                              Text(mensajesOrdenados[index].body, style: TextStyle(color: Colors.black)),
                              /* usuario */
                              /* Text(mensajesOrdenados[index].userSend, style: TextStyle(color: mensajesOrdenados[index].body == 'Se ha generado un nuevo Incidente' ? Colors.white : Colors.black)),                       */
                              Text(formatDate(mensajesOrdenados[index].createDate), style: TextStyle(color: Colors.black)),                      
                              Text(mensajesOrdenados[index].userSend, style: TextStyle(color: Colors.black)),                      
                            ],
                          ),
                          selected: true,
                          // leading: Icon(Icons.priority_high, size: 40.0,),
                          /* trailing: json.decode(incidentes)[index]['estadoIncidente'].toString() == 'pendiente' ? Icon(Icons.input) : (json.decode(incidentes)[index]['estadoIncidente'].toString() == 'resuelto' ? Icon(Icons.assignment_turned_in) : Icon(Icons.loop)), */
                          /* trailing: mensajesOrdenados[index].body == 'Se ha generado un nuevo Incidente' ? Icon(Icons.assignment_late, size: 40.0, color: Colors.white,) : Icon(Icons.assignment, size: 40.0, color: Colors.yellow[700]), */
                          trailing: mensajesOrdenados[index].estadoIncidente == 'Resuelto' ? Icon(Icons.assignment_turned_in, size: 40.0, color: Colors.grey,) : (mensajesOrdenados[index].subject == 'Nuevo Incidente' ? Icon(Icons.notification_important, size: 40.0, color: Theme.of(context).accentColor,) : mensajesOrdenados[index].subject == 'Responder a' ? Icon(Icons.question_answer, size: 40.0, color: Colors.yellow[900]) : Icon(Icons.chat, size: 40.0, color: Colors.yellow[700])),
                          onTap: () {                            
                            Navigator.push(context, 
                            MaterialPageRoute(builder: (context) => AgregarElementosAvanzado(cerrado: mensajesOrdenados[index].cerrado, responsable: mensajesOrdenados[index].responsable, mensaje: mensajesOrdenados[index].body, incidente: mensajesOrdenados[index].incidente, usuarioIncidente: mensajesOrdenados[index].userSend, incidentId: mensajesOrdenados[index].incidentId, nombreObra: mensajesOrdenados[index].nombreObra, threadId: mensajesOrdenados[index].threadId, parentMessageId:  mensajesOrdenados[index].parentMessageId, obraId: mensajesOrdenados[index].locationId, userIncidenteId: mensajesOrdenados[index].userId, subject: mensajesOrdenados[index].subject, estado: mensajesOrdenados[index].estadoIncidente, messageId: mensajesOrdenados[index].messageId, userReportadoPor: mensajesOrdenados[index].userReportadoPor, tituloIncidente: mensajesOrdenados[index].tituloIncidente, gravedad: mensajesOrdenados[index].gravedad)));                                       
                          },
                        ),
                      ) : Showcase(
                        key: _four,                                
                        title: 'Notificaciones',                                                    
                        description: 'Revisa tus notificaciones,\nagrega información, responde el incidente\no comunícaselo a otro usuario',
                        child: Opacity(
                          opacity: mensajesOrdenados[index].cerrado ? 0.6 : 1.0,
                          child: ListTile(                                    
                            /* title: Text(mensajesOrdenados[index].tituloIncidente, style: TextStyle(color: mensajesOrdenados[index].body == 'Se ha generado un nuevo Incidente' ? Colors.black : Theme.of(context).accentColor, fontWeight: FontWeight.w600),), */
                            title: Text(mensajesOrdenados[index].tituloIncidente, style: TextStyle(color: !mensajesOrdenados[index].cerrado ? Theme.of(context).accentColor : Colors.black, fontWeight: FontWeight.w600),),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                /* obra */
                                Row(
                                  children: <Widget>[
                                    /* Text('Estado: ', style: TextStyle(color: mensajesOrdenados[index].body == 'Se ha generado un nuevo Incidente' ? Colors.white : Colors.black, fontWeight: FontWeight.w600)), */
                                    Text('Estado: ', style: TextStyle(color:Colors.black, fontWeight: FontWeight.w600)),
                                    /* Text(mensajesOrdenados[index].estadoIncidente, style: TextStyle(color: mensajesOrdenados[index].body == 'Se ha generado un nuevo Incidente' ? Colors.white : Colors.black)), */
                                    Text(mensajesOrdenados[index].estadoIncidente, style: TextStyle(color: Colors.black)),
                                  ],
                                ),
                                /* Text(mensajesOrdenados[index].body, style: TextStyle(color: mensajesOrdenados[index].body == 'Se ha generado un nuevo Incidente' ? Colors.white : Colors.black)), */
                                Text(mensajesOrdenados[index].body, style: TextStyle(color: Colors.black)),
                                /* usuario */
                                /* Text(mensajesOrdenados[index].userSend, style: TextStyle(color: mensajesOrdenados[index].body == 'Se ha generado un nuevo Incidente' ? Colors.white : Colors.black)),                       */
                                Text(formatDate(mensajesOrdenados[index].createDate), style: TextStyle(color: Colors.black)),                      
                                Text(mensajesOrdenados[index].userSend, style: TextStyle(color: Colors.black)),                      
                              ],
                            ),
                            selected: true,
                            // leading: Icon(Icons.priority_high, size: 40.0,),
                            /* trailing: json.decode(incidentes)[index]['estadoIncidente'].toString() == 'pendiente' ? Icon(Icons.input) : (json.decode(incidentes)[index]['estadoIncidente'].toString() == 'resuelto' ? Icon(Icons.assignment_turned_in) : Icon(Icons.loop)), */
                            /* trailing: mensajesOrdenados[index].body == 'Se ha generado un nuevo Incidente' ? Icon(Icons.assignment_late, size: 40.0, color: Colors.white,) : Icon(Icons.assignment, size: 40.0, color: Colors.yellow[700]), */
                            trailing: mensajesOrdenados[index].estadoIncidente == 'Resuelto' ? Icon(Icons.assignment_turned_in, size: 40.0, color: Colors.grey,) : (mensajesOrdenados[index].subject == 'Nuevo Incidente' ? Icon(Icons.notification_important, size: 40.0, color: Theme.of(context).accentColor,) : mensajesOrdenados[index].subject == 'Responder a' ? Icon(Icons.question_answer, size: 40.0, color: Colors.yellow[900]) : Icon(Icons.chat, size: 40.0, color: Colors.yellow[700])),
                            onTap: () {
                              Navigator.push(context, 
                              MaterialPageRoute(builder: (context) => AgregarElementosAvanzado(cerrado: mensajesOrdenados[index].cerrado, responsable: mensajesOrdenados[index].responsable, mensaje: mensajesOrdenados[index].body, incidente: mensajesOrdenados[index].incidente, usuarioIncidente: mensajesOrdenados[index].userSend, incidentId: mensajesOrdenados[index].incidentId, nombreObra: mensajesOrdenados[index].nombreObra, threadId: mensajesOrdenados[index].threadId, parentMessageId:  mensajesOrdenados[index].parentMessageId, obraId: mensajesOrdenados[index].locationId, userIncidenteId: mensajesOrdenados[index].userId, subject: mensajesOrdenados[index].subject, estado: mensajesOrdenados[index].estadoIncidente, messageId: mensajesOrdenados[index].messageId, userReportadoPor: mensajesOrdenados[index].userReportadoPor, tituloIncidente: mensajesOrdenados[index].tituloIncidente, gravedad: mensajesOrdenados[index].gravedad)));                                       
                            },
                          ),
                        ),
                      )
                    ),
                  ],
                ),
              ) : Container(); 
            } else {
              return Card(
                /* color: mensajesOrdenados[index].body == 'Se ha generado un nuevo Incidente' ? Theme.of(context).accentColor : Colors.white, */
                color: mensajesOrdenados[index].isAtrasado == true ? Colors.yellow[300] : Colors.white,
                elevation: 2.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,            
                  children: <Widget>[                    
                    mensajesOrdenados[index].estadoMensaje == 9 ?
                    Container(
                      margin: EdgeInsets.only(left: 10.0),
                      width: 10.0,
                      height: 10.0,
                      decoration: new BoxDecoration(
                        color: Colors.lightBlue[300],
                        shape: BoxShape.circle,
                      ),
                    ) : Container(),                            
                    Expanded(
                      child: index != 0 ? 
                      Opacity(
                        opacity: mensajesOrdenados[index].cerrado ? 0.5 : 1.0,
                        child: ListTile(                                    
                          /* title: Text(mensajesOrdenados[index].tituloIncidente, style: TextStyle(color: mensajesOrdenados[index].body == 'Se ha generado un nuevo Incidente' ? Colors.black : Theme.of(context).accentColor, fontWeight: FontWeight.w600),), */
                          title: Text(mensajesOrdenados[index].tituloIncidente, style: TextStyle(color: !mensajesOrdenados[index].cerrado ? Theme.of(context).accentColor : Colors.black, fontWeight: FontWeight.w600),),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              /* obra */
                              Row(
                                children: <Widget>[
                                  /* Text('Estado: ', style: TextStyle(color: mensajesOrdenados[index].body == 'Se ha generado un nuevo Incidente' ? Colors.white : Colors.black, fontWeight: FontWeight.w600)), */
                                  Text('Estado: ', style: TextStyle(color:Colors.black, fontWeight: FontWeight.w600)),
                                  /* Text(mensajesOrdenados[index].estadoIncidente, style: TextStyle(color: mensajesOrdenados[index].body == 'Se ha generado un nuevo Incidente' ? Colors.white : Colors.black)), */
                                  Text(mensajesOrdenados[index].estadoIncidente, style: TextStyle(color: Colors.black)),
                                ],
                              ),
                              /* Text(mensajesOrdenados[index].body, style: TextStyle(color: mensajesOrdenados[index].body == 'Se ha generado un nuevo Incidente' ? Colors.white : Colors.black)), */
                              Text(mensajesOrdenados[index].body, style: TextStyle(color: Colors.black)),
                              /* usuario */
                              /* Text(mensajesOrdenados[index].userSend, style: TextStyle(color: mensajesOrdenados[index].body == 'Se ha generado un nuevo Incidente' ? Colors.white : Colors.black)),                       */
                              Text(formatDate(mensajesOrdenados[index].createDate), style: TextStyle(color: Colors.black)),                      
                              Text(mensajesOrdenados[index].userSend, style: TextStyle(color: Colors.black)),                      
                            ],
                          ),
                          selected: true,
                          // leading: Icon(Icons.priority_high, size: 40.0,),
                          /* trailing: json.decode(incidentes)[index]['estadoIncidente'].toString() == 'pendiente' ? Icon(Icons.input) : (json.decode(incidentes)[index]['estadoIncidente'].toString() == 'resuelto' ? Icon(Icons.assignment_turned_in) : Icon(Icons.loop)), */
                          /* trailing: mensajesOrdenados[index].body == 'Se ha generado un nuevo Incidente' ? Icon(Icons.assignment_late, size: 40.0, color: Colors.white,) : Icon(Icons.assignment, size: 40.0, color: Colors.yellow[700]), */
                          trailing: mensajesOrdenados[index].estadoIncidente == 'Resuelto' ? Icon(Icons.assignment_turned_in, size: 40.0, color: Colors.grey,) : (mensajesOrdenados[index].subject == 'Nuevo Incidente' ? Icon(Icons.notification_important, size: 40.0, color: Theme.of(context).accentColor,) : mensajesOrdenados[index].subject == 'Responder a' ? Icon(Icons.question_answer, size: 40.0, color: Colors.yellow[900]) : Icon(Icons.chat, size: 40.0, color: Colors.yellow[700])),
                          onTap: () {
                            Navigator.push(context, 
                            MaterialPageRoute(builder: (context) => AgregarElementosAvanzado(cerrado: mensajesOrdenados[index].cerrado, responsable: mensajesOrdenados[index].responsable, mensaje: mensajesOrdenados[index].body, incidente: mensajesOrdenados[index].incidente, usuarioIncidente: mensajesOrdenados[index].userSend, incidentId: mensajesOrdenados[index].incidentId, nombreObra: mensajesOrdenados[index].nombreObra, threadId: mensajesOrdenados[index].threadId, parentMessageId:  mensajesOrdenados[index].parentMessageId, obraId: mensajesOrdenados[index].locationId, userIncidenteId: mensajesOrdenados[index].userId, subject: mensajesOrdenados[index].subject, estado: mensajesOrdenados[index].estadoIncidente, messageId: mensajesOrdenados[index].messageId, userReportadoPor: mensajesOrdenados[index].userReportadoPor, tituloIncidente: mensajesOrdenados[index].tituloIncidente,  gravedad: mensajesOrdenados[index].gravedad)));                                       
                          },
                        ),
                      ) : Showcase(
                        key: _four,                                
                        title: 'Notificaciones',                                                    
                        description: 'Revisa tus notificaciones,\nagrega información, responde el incidente\no comunícaselo a otro usuario',
                        child: Opacity(
                          opacity: mensajesOrdenados[index].cerrado ? 0.5 : 1.0,
                          child: ListTile(                                    
                            /* title: Text(mensajesOrdenados[index].tituloIncidente, style: TextStyle(color: mensajesOrdenados[index].body == 'Se ha generado un nuevo Incidente' ? Colors.black : Theme.of(context).accentColor, fontWeight: FontWeight.w600),), */
                            title: Text(mensajesOrdenados[index].tituloIncidente, style: TextStyle(color: !mensajesOrdenados[index].cerrado ? Theme.of(context).accentColor : Colors.black, fontWeight: FontWeight.w600),),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                /* obra */
                                Row(
                                  children: <Widget>[
                                    /* Text('Estado: ', style: TextStyle(color: mensajesOrdenados[index].body == 'Se ha generado un nuevo Incidente' ? Colors.white : Colors.black, fontWeight: FontWeight.w600)), */
                                    Text('Estado: ', style: TextStyle(color:Colors.black, fontWeight: FontWeight.w600)),
                                    /* Text(mensajesOrdenados[index].estadoIncidente, style: TextStyle(color: mensajesOrdenados[index].body == 'Se ha generado un nuevo Incidente' ? Colors.white : Colors.black)), */
                                    Text(mensajesOrdenados[index].estadoIncidente, style: TextStyle(color: Colors.black)),
                                  ],
                                ),
                                /* Text(mensajesOrdenados[index].body, style: TextStyle(color: mensajesOrdenados[index].body == 'Se ha generado un nuevo Incidente' ? Colors.white : Colors.black)), */
                                Text(mensajesOrdenados[index].body, style: TextStyle(color: Colors.black)),
                                /* usuario */
                                /* Text(mensajesOrdenados[index].userSend, style: TextStyle(color: mensajesOrdenados[index].body == 'Se ha generado un nuevo Incidente' ? Colors.white : Colors.black)),                       */
                                Text(formatDate(mensajesOrdenados[index].createDate), style: TextStyle(color: Colors.black)),                      
                                Text(mensajesOrdenados[index].userSend, style: TextStyle(color: Colors.black)),                      
                              ],
                            ),
                            selected: true,
                            // leading: Icon(Icons.priority_high, size: 40.0,),
                            /* trailing: json.decode(incidentes)[index]['estadoIncidente'].toString() == 'pendiente' ? Icon(Icons.input) : (json.decode(incidentes)[index]['estadoIncidente'].toString() == 'resuelto' ? Icon(Icons.assignment_turned_in) : Icon(Icons.loop)), */
                            /* trailing: mensajesOrdenados[index].body == 'Se ha generado un nuevo Incidente' ? Icon(Icons.assignment_late, size: 40.0, color: Colors.white,) : Icon(Icons.assignment, size: 40.0, color: Colors.yellow[700]), */
                            trailing: mensajesOrdenados[index].estadoIncidente == 'Resuelto' ? Icon(Icons.assignment_turned_in, size: 40.0, color: Colors.grey,) : (mensajesOrdenados[index].subject == 'Nuevo Incidente' ? Icon(Icons.notification_important, size: 40.0, color: Theme.of(context).accentColor,) : mensajesOrdenados[index].subject == 'Responder a' ? Icon(Icons.question_answer, size: 40.0, color: Colors.yellow[900]) : Icon(Icons.chat, size: 40.0, color: Colors.yellow[700])),
                            onTap: () {
                              Navigator.push(context, 
                              MaterialPageRoute(builder: (context) => AgregarElementosAvanzado(cerrado: mensajesOrdenados[index].cerrado, responsable: mensajesOrdenados[index].responsable, mensaje: mensajesOrdenados[index].body, incidente: mensajesOrdenados[index].incidente, usuarioIncidente: mensajesOrdenados[index].userSend, incidentId: mensajesOrdenados[index].incidentId, nombreObra: mensajesOrdenados[index].nombreObra, threadId: mensajesOrdenados[index].threadId, parentMessageId:  mensajesOrdenados[index].parentMessageId, obraId: mensajesOrdenados[index].locationId, userIncidenteId: mensajesOrdenados[index].userId, subject: mensajesOrdenados[index].subject, estado: mensajesOrdenados[index].estadoIncidente, messageId: mensajesOrdenados[index].messageId, userReportadoPor: mensajesOrdenados[index].userReportadoPor, tituloIncidente: mensajesOrdenados[index].tituloIncidente,  gravedad: mensajesOrdenados[index].gravedad)));                                       
                            },
                          ),
                        ),
                      )
                    ),
                  ],
                ),
              );
            }                 
          },
        ),
        Positioned(
          bottom: 30.0,
          left: (MediaQuery.of(context).size.width / 2) - 125,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
              color: Colors.black,
              borderRadius: BorderRadius.circular(40.0)
            ),                                
            width: 230.0,                                
            height: 45.0,
            child: Row(                                  
              children: <Widget>[
                Expanded(
                  flex: 1,                  
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeIn,
                    height: 45.0,
                    decoration: BoxDecoration(                      
                      color: (DatosUsuario().valorActivos != null || DatosUsuario().filtroGravedad != null || DatosUsuario().filtroObra != null) ? Colors.red : Colors.black,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40.0),
                        bottomLeft: Radius.circular(40.0)
                      ), 
                    ),                     
                    child: GestureDetector(
                      onTap: () {
                        showFiltros(snapshot.data.mensajes);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.tune, color: Colors.white),
                          Text('Filtrar', style: TextStyle(color: Colors.white))
                        ],
                      ),
                    ),
                  ),
                ),
                /* VerticalDivider(
                  thickness: 1.0,
                  color: Colors.grey,
                ), */
                Container(
                  height: 45.0,
                  width: 1.0,
                  color: Colors.grey,
                ),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        filtroGravedad = null;
                        valorGravedad = null;
                        valorObra = null;
                        filtroObra = null;
                        mostrarActivos = false; 
                        valorActivos = false; 
                        DatosUsuario().valorActivos = null;
                        DatosUsuario().filtroGravedad = null;
                        DatosUsuario().filtroObra = null;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.view_list, color: Colors.white),
                        Text('Ver todos', style: TextStyle(color: Colors.white),)
                      ],
                    ),
                  ),
                ),                                    
              ],
            ),
          )
        )
      ],
    );
  }
}