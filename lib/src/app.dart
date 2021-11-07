import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:location/location.dart';
import 'package:nuevo_riesgos/src/blocs/forms_bloc.dart';
import 'package:nuevo_riesgos/src/blocs/incidentes_bloc.dart';
import 'package:nuevo_riesgos/src/blocs/login_bloc.dart';
import 'package:nuevo_riesgos/src/blocs/medios_bloc.dart';
import 'package:nuevo_riesgos/src/blocs/mensajes_bloc.dart';
import 'package:nuevo_riesgos/src/resources/datos/datos_usuario.dart';
import 'package:nuevo_riesgos/src/resources/proveedor_servicio_obras.dart';
import 'package:nuevo_riesgos/src/ui/reporte_basico.dart';
import 'package:nuevo_riesgos/src/ui/login.dart';
import 'package:nuevo_riesgos/src/ui/obra.dart';
import 'package:nuevo_riesgos/src/ui/reporte_avanzado.dart';
import 'package:nuevo_riesgos/src/ui/reportes_historicos.dart';
import 'package:page_transition/page_transition.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nuevo_riesgos/src/ui/informacion.dart';
import 'package:nuevo_riesgos/src/ui/mensajes_basico.dart';
import 'package:nuevo_riesgos/src/ui/inicio_avanzado.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inject/inject.dart';
import 'package:showcaseview/showcase.dart';
import 'package:showcaseview/showcase_widget.dart';
import 'blocs/obras_bloc.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:nuevo_riesgos/src/resources/constantes.dart' as constantes;


/* void main() => runApp(MyApp()); */

class MyApp extends StatefulWidget {  
  final ObrasBloc obrasBloc;  
  final FormsBloc formsBloc;
  final IncidentesBloc incidentesBloc;
  final LoginBloc loginBloc;
  final MediosBloc mediosBloc;
  final MensajesBloc mensajesBloc;

  @provide
  MyApp(this.obrasBloc, this.formsBloc, this.incidentesBloc, this.loginBloc, this.mediosBloc, this.mensajesBloc): super();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    initPlatformState();
    /* checkUser(); */
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;
    //Remove this method to stop OneSignal Debugging 
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    OneSignal.shared.init(
      "#",
      iOSSettings: {
        OSiOSSettings.autoPrompt: false,
        OSiOSSettings.inAppLaunchUrl: false
      }
    );
    OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);

    // The promptForPushNotificationsWithUserResponse function will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    await OneSignal.shared.promptUserForPushNotificationPermission(fallbackToSettings: true);
  }

  String usuario;     

  @override
  Widget build(BuildContext context) {    
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

    return MaterialApp(             
      /* home: EvaluacionInicio() *//* FutureBuilder(
        future: checkUser(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == 'trabajador') {
              return Inicio();
            } else if (snapshot.data == 'avanzado') {
              return InicioAvanzado(widget.mensajesBloc);
            } else {
              return Login();
            }
          } else {
            return Login();
          }
        },
      ) ,*/
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: [
        const Locale('es', '')
      ],
      initialRoute: '/',
      routes: {    
        '/': (context) => EvaluacionInicio(),
        'obras': (context) => Obras(widget.obrasBloc),
        'reporte': (context) => ReporteAvanzado(widget.formsBloc),
        'reporteBasico': (context) => ReporteBasico(widget.formsBloc),
        'mainAvanzado': (context) => InicioAvanzado(widget.mensajesBloc),
        'inicio': (context) => Inicio(),
        'login': (context) => Login(),        
        'mensajesBasicos': (context) => MensajesBasico(widget.mensajesBloc),
        'reportesHistoricos' : (context) => ReportesHistoricos(widget.incidentesBloc)
        /* 'agregarAvanzado': (context) => AgregarElementosAvanzado(), */
      },
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.red[900],
        accentColor: Colors.red[600],
        canvasColor: Colors.white
      ),
      debugShowCheckedModeBanner: false,
      title: 'Prevención de Riesgos',
      // home: Obra(obra: 'Prevención de Riesgos',),      
    );
  }
}

class EvaluacionInicio extends StatefulWidget {
  @override
  _EvaluacionInicioState createState() => _EvaluacionInicioState();
}

class _EvaluacionInicioState extends State<EvaluacionInicio> {

  @override
  void initState() {
    super.initState();    
    startTime(); 
  }

  startTime() async {        
    return new Timer(Duration(milliseconds: 500), checkUser);
  } 

  checkUser() async {
    final urlServicios = constantes.urlBase;
    SharedPreferences prefs = await SharedPreferences.getInstance();   
    print(prefs.getString('rut'));
    print(prefs.getString('fechaNacimiento'));
    if (prefs.getString('rut') != null && prefs.getString('fechaNacimiento') != null) {
      await ServiciosConectaDio().hacerLogin(prefs.getString('rut'), prefs.getString('fechaNacimiento'), '', 'http://$urlServicios/api/jsonws/vs-bpm-screen-portlet.app/login').then((value) {                                                                                  
        if (json.decode(value.body)['code'] == 0) {
          OneSignal.shared.setExternalUserId(json.decode(value.body)['body']['userId'].toString());
          print('trabajador tipo ${json.decode(value.body)['body']['profile']}');
          if (json.decode(value.body)['body']['profile'] == 'TRABAJADOR') {  
            prefs.setString('tipoDeUsuario', 'TRABAJADOR');                                           
            Navigator.pushReplacementNamed(context, 'inicio');
          } else if (json.decode(value.body)['body']['profile'] == 'CAPATAZ') {
            prefs.setString('tipoDeUsuario', 'AVANZADO');                                           
            Navigator.pushReplacementNamed(context, 'mainAvanzado');
          }                                                                                     
        } else {
          Navigator.pushReplacementNamed(context, 'login');       
        }                                        
      });  
    } else {
      Navigator.pushReplacementNamed(context, 'login');
    }                                              
  }  

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          child: Image.asset('imagenes/logo-ebco.png'),
        )
      ),
    );
  }
}

class Inicio extends StatefulWidget {

  @override
  _InicioState createState() => _InicioState();
}

class _InicioState extends State<Inicio> {    

  @override
  void initState() {
    super.initState();
    /* evaluarDatosBase(); */
    getPermission();
    getUnreadMessages();   
    showcaseCheck(); 
    getTipoUsuario();    
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

  String tipoUsuario;
  getTipoUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();   
    setState(() {
      tipoUsuario = prefs.getString('tipoDeUsuario');         
    });                          
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

  showReporteDialog(nombreObra) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(          
          content: Text('¿Quieres seguir en "$nombreObra"?'),
          actions: <Widget>[    
            MaterialButton(
              minWidth: 130.0,
              child: Text('Seleccionar nueva'),
              shape: StadiumBorder(),
                    textColor: Colors.white,
                    color: Theme.of(context).accentColor,
                    elevation: 1.0,
              onPressed: () {
                Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: ObraAvanzado()));
              },
            ),         
            MaterialButton(
              minWidth: 130.0,
              child: Text('Seguir en obra'),
              shape: StadiumBorder(),
                    textColor: Colors.white,
                    color: Theme.of(context).accentColor,
                    elevation: 1.0,
              onPressed: () async {
                var prefs = await SharedPreferences.getInstance();
                DatosUsuario().locationId = int.parse(prefs.getString('locationId'));
                DatosUsuario().nombreObraActual = prefs.getString('nombreObraActual');
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

  var unreadMessages;
  
  GlobalKey _one = GlobalKey();
  GlobalKey _two = GlobalKey();
  GlobalKey _three = GlobalKey();
  GlobalKey _four = GlobalKey();  
  BuildContext myContext;

  getUnreadMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance(); 
    if (prefs.getString('unreadMessagesCount') != null) {
      setState(() {
      unreadMessages = prefs.getString('unreadMessagesCount');
    });
    }    
    ServiciosConectaDio().fetchUnreadCount().then((value) {
      setState(() {
        unreadMessages = prefs.getString('unreadMessagesCount');
      });
    });
  }

  @override 
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      builder: Builder(
        builder: (context) {
          myContext = context;
          return Scaffold(
            // backgroundColor: Theme.of(context).primaryColor,
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(''),
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: Padding(
                padding: EdgeInsets.only(left: 10.0, top: 2.0),
                child: IconButton(
                  icon: Icon(Icons.input), 
                  iconSize: 40.0,
                  color: /* Colors.black */Colors.transparent,
                  onPressed: () {
                    /* Navigator.pushNamed(context, 'login'); */
                  },
                  ),
              ),
              actions: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 0.0, right: 5.0),
                  child: Showcase(
                    key: _four,                                
                    title: 'Revisar mensajes',                                  
                    description: 'Revisa y responde tus mensajes',
                    child: Padding(
                      padding: EdgeInsets.only(right: 0.0, top: 2.0),
                      child: Stack(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.mail_outline), 
                            iconSize: 40.0,
                            color: Theme.of(context).accentColor, 
                            onPressed: () {
                              /* Navigator.push(context, PageTransition(type: PageTransitionType.fade, child: Mensajes())); */
                              Navigator.pushNamed(context, 'mensajesBasicos');
                            },
                          ),
                          (unreadMessages != null && unreadMessages != '0') ?
                          Positioned(
                              right: 0.0,
                              top: 0.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).accentColor,
                                  shape: BoxShape.circle,
                                ),                    
                                padding: EdgeInsets.all(5.0),
                                child: Text(unreadMessages)
                              ),
                            ) : Container()
                        ],
                      ),
                    ),
                  ),
                ),          
              ],
            ),
            body: SafeArea(
              child: Container(       
                child: Column(          
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(              
                      flex: 1,
                      child: Column(      
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,          
                        children: <Widget>[
                          /* Imagen con "prevencion de riesgo" */
                          Column(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.topCenter,
                                padding: EdgeInsets.only(top: 20.0),
                                child: Image.asset('imagenes/logo-ebco.png', width: 150.0,)
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 10.0),
                                width: 300.0,
                                child: Text('Prevención de Riesgo', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600, height: 0.5, color: Colors.black), textAlign: TextAlign.center,),
                              ),
                            ],
                          ),                  
                        ],
                      ),
                    ),            
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.only(top: 0.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(top: 20.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Showcase(
                                    key: _one,                                
                                    title: 'Historial de reportes',                                  
                                    description: 'Revisa los incidentes que ya has reportado',
                                    child: Column(
                                      children: <Widget>[
                                        Container(                      
                                          margin: EdgeInsets.only(bottom: 15.0, top: 5.0),          
                                          width: MediaQuery.of(context).size.width * 0.2,
                                          height: MediaQuery.of(context).size.width * 0.2,
                                          /* height: MediaQuery.of(context).size.height * 0.4,                   */
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.rectangle,   
                                            borderRadius: BorderRadius.all(Radius.circular(20.0)), 
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
                                                        iconSize: 55.0,
                                                        icon: Icon(Icons.restore, color: Colors.white, size: 55.0,),
                                                        onPressed: () {
                                                          Navigator.pushNamed(context, 'reportesHistoricos');
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
                                          padding: EdgeInsets.only(top: 5.0, left: 5.0),
                                          child: FittedBox(fit: BoxFit.contain, child: Text('Historial\nReportes', style: TextStyle(color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.w600), textAlign: TextAlign.center,)),
                                        )
                                      ],
                                    ),
                                  ),
                                  Showcase(
                                    key: _two,                                
                                    title: 'Biblioteca Preventiva',                                  
                                    description: 'Busca y aprende información\nsobre prevención de riesgo',
                                    child: Column(
                                      children: <Widget>[
                                        Container(                      
                                          margin: EdgeInsets.only(bottom: 15.0, top: 5.0),          
                                          width: MediaQuery.of(context).size.width * 0.2,
                                          height: MediaQuery.of(context).size.width * 0.2,
                                          /* height: MediaQuery.of(context).size.height * 0.4,                   */
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.rectangle,   
                                            borderRadius: BorderRadius.all(Radius.circular(20.0)), 
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
                                                        icon: Icon(FontAwesomeIcons.info, color: Colors.white, size: 50.0,),
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
                                          padding: EdgeInsets.only(top: 5.0, left: 5.0),
                                          child: FittedBox(fit: BoxFit.contain, child: Text("Documentos\npreventivos", style: TextStyle(color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.w600), textAlign: TextAlign.center,)),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),   
                            Container(
                              padding: EdgeInsets.only(top: 20.0),
                              child: Showcase(
                                key: _three,     
                                disableAnimation: true,                                                                                                                                                   
                                title: 'Reportar incidente',                                  
                                description: 'Genera un reporte',
                                child: Column(
                                  children: <Widget>[
                                    Container(                      
                                      margin: EdgeInsets.only(bottom: 15.0, top: 5.0),          
                                      width: MediaQuery.of(context).size.width * 0.2,
                                      height: MediaQuery.of(context).size.width * 0.2,
                                      /* height: MediaQuery.of(context).size.height * 0.4,                   */
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.rectangle,   
                                        borderRadius: BorderRadius.all(Radius.circular(20.0)), 
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
                                                      Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: ObraAvanzado()));
                                                    }
                                                    
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
                                      padding: EdgeInsets.only(right: 0.0, top: 0),
                                      child: FittedBox(fit: BoxFit.contain, child: Text('Reportar\nincidente', style: TextStyle(color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.w600), textAlign: TextAlign.center,)),
                                    )
                                  ],
                                ),
                              ),
                            ),                                     
                          ]
                        )
                      ),
                    )
                  ],
                ),
              ),
            )
          );
        }
      ),
    );
  }
}





