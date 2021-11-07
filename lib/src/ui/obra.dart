import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
/* import 'package:geolocator/geolocator.dart'; */
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:nuevo_riesgos/src/resources/proveedor_servicio_obras.dart';
import 'package:nuevo_riesgos/src/ui/cargador.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'my_flutter_app_icons.dart';
import 'package:nuevo_riesgos/src/models/obras_model.dart';
import 'package:nuevo_riesgos/src/blocs/obras_bloc.dart';
import 'package:nuevo_riesgos/src/resources/datos/datos_usuario.dart';


/* class Obra extends StatefulWidget {   
  final obra;  
  Obra({Key key, @required this.obra}) : super(key: key);  

  @override
  _ObraState createState() => _ObraState();
}

class _ObraState extends State<Obra> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.obra),
        centerTitle: true,
        actions: <Widget>[
          Stack(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 10.0, top: 2.0),
                child: IconButton(
                  icon: Icon(Icons.mail_outline), 
                  iconSize: 40.0,
                  color: Colors.white, 
                  onPressed: () {
                    Navigator.pushNamed(context, 'mensajesBasicos');
                  },
                  ),
              ),
              Positioned(
                top: 3.0,
                child: Container(
                  color: Colors.red,
                  child: Text('1')
                ),
              )
            ],
          ),          
        ],
      ),
      body: Mapa(widget.obra)
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     Navigator.push(
      //       context, 
      //       MaterialPageRoute(builder: (context) => AgregarElementos()),
      //     );
      //   },
      //   icon: Icon(Icons.add),
      //   label: Text('Agregar Riesgo'),
      //   backgroundColor: Theme.of(context).accentColor,
      // ),
    );
  }
} */

class ObraAvanzado extends StatefulWidget {
  final obra;
  ObraAvanzado({Key key, this.obra}) : super(key: key);

  @override
  _ObraAvanzadoState createState() => _ObraAvanzadoState();
}

class _ObraAvanzadoState extends State<ObraAvanzado> {
  Completer<GoogleMapController> _controller = Completer();

  LatLng _center ;
  LocationData currentLocation;
  List<Marker> allMarkers = []; 
  bool loading = false;
  var nombreObra;
  String tipoUsuario;
  var unreadMessages;

  @override
  void initState() {
    super.initState();   
    getPermission();
    getTipoUsuario();     
    getUnreadMessages();  
  }

  getTipoUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();   
    tipoUsuario = prefs.getString('tipoDeUsuario');                                   
  }

  getUnreadMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance(); 
    setState(() {
      unreadMessages = prefs.getString('unreadMessagesCount');
    });
    ServiciosConectaDio().fetchUnreadCount().then((value) {
      setState(() {
        unreadMessages = prefs.getString('unreadMessagesCount');
      });
    });
  }

  void _mostrarDialogAgregarMedios() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(          
          content: Text('No se encontró ninguna obra cerca, por favor selecciona una manualmente'),
          actions: <Widget>[    
            MaterialButton(
              minWidth: 90.0,
              child: Text('Intentar de nuevo'),
              shape: StadiumBorder(),
                    textColor: Colors.white,
                    color: Theme.of(context).accentColor,
                    elevation: 1.0,
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  loading = true;
                });
                getUserLocation();

              },
            ),         
            MaterialButton(
              minWidth: 90.0,
              child: Text('Seleccionar obra'),
              shape: StadiumBorder(),
                    textColor: Colors.white,
                    color: Theme.of(context).accentColor,
                    elevation: 1.0,
              onPressed: () {
                Navigator.pushNamed(context, 'obras');
              },
            ),                        
          ],
        );
      }
    );
  } 

  void _mostrarDialogSeleccionarObra() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(          
          content: Text('No se pudo encontrar la ubicación, por favor selecciona una obra manualmente'),
          actions: <Widget>[                         
            MaterialButton(
              minWidth: 90.0,
              child: Text('Seleccionar obra'),
              shape: StadiumBorder(),
                    textColor: Colors.white,
                    color: Theme.of(context).accentColor,
                    elevation: 1.0,
              onPressed: () {
                Navigator.pushNamed(context, 'obras');
              },
            ),                        
          ],
        );
      }
    );
  } 

  bool permisoUbicacionConcedido = false;

  void _mostrarDialogUbicacion() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(          
              content: Text('Por favor activa tu servicio de ubicación'),
              actions: <Widget>[   
                permisoUbicacionConcedido ?
                Container(height: 0.0,) :                    
                MaterialButton(
                  minWidth: 90.0,
                  child: Text('Seleccionar obra'),
                  shape: StadiumBorder(),
                        textColor: Colors.white,
                        color: Theme.of(context).accentColor,
                        elevation: 1.0,
                  onPressed: () {
                    Navigator.pushNamed(context, 'obras');
                  },
                ),  
                MaterialButton(
                  minWidth: 90.0,
                  child: permisoUbicacionConcedido ? Text('Encontrar Ubicación') : Text('Activar ubicación'),
                  shape: StadiumBorder(),
                        textColor: Colors.white,
                        color: Theme.of(context).accentColor,
                        elevation: 1.0,
                  onPressed: () async {      
                    if (permisoUbicacionConcedido == true) {
                      getUserLocation();
                      Navigator.pop(context);
                    } else {
                      Location location = new Location();                                  
                      await location.requestService(); 
                      setState(() {                      
                        permisoUbicacionConcedido = true;
                      }); 
                    }                                          
                  },
                ),                       
              ],
            );
          },
        );
      }
    );
  }

  void _mostrarDialogSinUbicacionIos() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(          
              content: Text('No esta activo el permiso para acceder a la ubicación'),
              actions: <Widget>[   
                permisoUbicacionConcedido ?
                Container(height: 0.0,) :                    
                MaterialButton(
                  minWidth: 90.0,
                  child: Text('Seleccionar obra'),
                  shape: StadiumBorder(),
                        textColor: Colors.white,
                        color: Theme.of(context).accentColor,
                        elevation: 1.0,
                  onPressed: () {
                    Navigator.pushNamed(context, 'obras');
                  },
                ),                                        
              ],
            );
          },
        );
      }
    );
  }  

  /* Future<Position> locateUser() async {    
    Geolocator geolocator = Geolocator()..forceAndroidLocationManager = true;
    
    print(await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low))  ;
    return await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
  } */

  getPermission() async {
    Location location = new Location();
    PermissionStatus _permissionGranted;
    _permissionGranted = await location.hasPermission();
    print('permission $_permissionGranted');
    if (_permissionGranted == PermissionStatus.denied) {
      print('permissiones denegado');
      if (Platform.isAndroid) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return null;
        }
      } else if (Platform.isIOS) {
        _mostrarDialogSinUbicacionIos();
      }      
    } else {
      checkLocationActive(); 
      print('permissiones no denegado');
    }
  }

  Future<LocationData> locateUserLocation() async {    
    Location location = new Location();

   /*  bool _serviceEnabled;
    PermissionStatus _permissionGranted; */
    LocationData _locationData;

    /* _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      /* if (!_serviceEnabled) {
        return null;
      } */
    } */

    /* _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    } */

    _locationData = await location.getLocation();
    return _locationData;
  }

  checkLocationActive() async {    
    if (widget.obra == null) {      
      Location location = new Location();      
      if (await location.serviceEnabled() == false) {
        _mostrarDialogUbicacion();
      } else {               
        getUserLocation();
      }  
    } else {
      getUserLocation();
    } 
  }

  getUserLocation() async {
    currentLocation = await locateUserLocation();         
    if (currentLocation.latitude == null) {
      _mostrarDialogSeleccionarObra();
    }
    if (widget.obra == null) {
      await ServiciosConectaDio().obtenerObraCoordenadas(currentLocation.latitude, currentLocation.longitude).then((response) {
      print('response');        
      List body = jsonDecode(response.body)['body'];    
      if (body.length < 1) {          
        setState(() {
          _mostrarDialogAgregarMedios();
          nombreObra = 'Selecciona una obra';       
        });        
      } else {      
        DatosUsuario().nombreObraActual = jsonDecode(response.body)['body'][0]['locationName'];
        DatosUsuario().locationId = jsonDecode(response.body)['body'][0]['locationId'];
        setState(() {
          loading = false;
          nombreObra = jsonDecode(response.body)['body'][0]['locationName'];
           _center = LatLng(currentLocation.latitude, currentLocation.longitude);
            allMarkers.add(Marker(
              markerId: MarkerId('valor'),
              position: _center,
            ));            
        });        
      }       
    });  
    } else {
      setState(() {
        loading = false;        
          _center = LatLng(currentLocation.latitude, currentLocation.longitude);
          allMarkers.add(Marker(
            markerId: MarkerId('valor'),
            position: _center,
          ));        
      });
    }        
    /* setState(() {
      if (_center == null) {
        _center = LatLng(currentLocation.latitude, currentLocation.longitude);
        allMarkers.add(Marker(
          markerId: MarkerId('valor'),
          position: _center,
        ));
        loading = false;
      } else {
        loading = false;
      }
    }); */
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text(nombreObra != null ? nombreObra : widget.obra != null ? widget.obra : 'Buscando obra'),
        backgroundColor: Colors.black,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {            
            Navigator.pushNamed(context, tipoUsuario == 'AVANZADO' ? 'mainAvanzado' : 'inicio');
          },
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 10.0, top: 2.0),
            child: Stack(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.mail_outline), 
                  iconSize: 40.0,
                  color: Colors.white, 
                  onPressed: () {
                    Navigator.pushNamed(context, tipoUsuario == 'AVANZADO' ? 'mainAvanzado' : 'mensajesBasicos');
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
        ],
      ),
      body: (_center == null || loading == true) ?  Cargando() : 
        Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: 
              CameraPosition(
                target: _center,
                zoom: 17,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);                
              },
              markers: Set.from(allMarkers),
            ),
          ),
          Expanded(
            child: ListView(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                child: Row(
                  children: <Widget>[
                    Icon(MyFlutterApp.commerical_building, color: Theme.of(context).accentColor,size: 35.0,),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Text(nombreObra != null ? nombreObra : widget.obra != null ? widget.obra : 'Selecciona una obra', style: TextStyle(fontWeight: FontWeight.w500,)),
                        Container(
                          height: 20.0,
                          width: 150.0,
                          child: MaterialButton(
                            elevation: 1,
                            color: Theme.of(context).accentColor,
                            textColor: Colors.white,
                            child: Text('Cambiar Obra'),
                            onPressed: () {
                              Navigator.pushNamed(context, 'obras');
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Center(
                child: Container(
                  padding: EdgeInsets.only(top: 80.0),
                  width: 250.0,
                  height: 130.0,
                  child: MaterialButton(
                    shape: StadiumBorder(),
                    elevation: 3.0,
                    textColor: Colors.white,
                    color: Theme.of(context).accentColor,
                    onPressed: () {
                      Navigator.pushNamed(
                        context, 
                        tipoUsuario == 'AVANZADO' ? 'reporte' : 'reporteBasico',
                      );
                    },
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.add, size: 35.0,),
                        Padding(
                          padding: EdgeInsets.only(left: 10.0),
                          child: Text(tipoUsuario == 'AVANZADO' ? 'Reportar incidente' : 'Reportar incidente', style: TextStyle(fontSize: 20.0),),
                        )
                      ],
                    ),
                  ),
                )
              )
            ],
          ),
          )
        ],
      )
    );
  }
}

class Obras extends StatefulWidget {
  final ObrasBloc _bloc;

  Obras(this._bloc);

  @override
  _ObrasState createState() => _ObrasState();
}

class _ObrasState extends State<Obras> {  

  dynamic respuestaServicio;
  dynamic listaObras;
  int cantidadObras;    
  String tipoUsuario;
  TextEditingController controller = new TextEditingController();
  String filter;
  
  @override 
  void initState() {         
    super.initState(); 
    widget._bloc.init();
    widget._bloc.fetchListalObras();       
    getTipoUsuario();            
    controller.addListener(() {
      setState(() {
        filter = controller.text;
      });
    });
  }   

  @override
  void dispose() {
    widget._bloc.dispose();
    controller.dispose();
    super.dispose();
  }

  getTipoUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();   
    tipoUsuario = prefs.getString('tipoDeUsuario');                                   
  }

  @override 
  Widget build(BuildContext context) {    
    return new Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text('Selecciona una Obra'),
          centerTitle: true,
        ),
        body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: StreamBuilder(
            stream: widget._bloc.allObras,
            builder: (context, AsyncSnapshot<ObrasModel> snapshot) {
              if (snapshot.hasData) {
                return buildList(snapshot);
              } else if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }
              return Center(child: CircularProgressIndicator(),);
            },
          ),
        ),        
       /*  listaObras != null ? ListView.builder(
          itemCount: cantidadObras,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                listaObras[index]['name'].toString(),
              ),
              onTap: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => Obra(obra: listaObras[index]['name'],)),
                );
              },
              trailing: Icon(Icons.keyboard_arrow_right),
            );
          },
        ) :
        Center(child: CircularProgressIndicator(),), */
      );
  }
  Widget buildList(AsyncSnapshot<ObrasModel> snapshot) {   
        
    return Column(
      children: <Widget>[
        new TextFormField(                
          decoration: new InputDecoration(
            contentPadding: EdgeInsets.only(left: 0.0, top: 15.0),
            prefixIcon: Icon(Icons.search, color: Colors.red,),
            hintText: "Buscar obra",   
            enabledBorder: UnderlineInputBorder(      
              borderSide: BorderSide(color: Colors.red),   
            ),  
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
          controller: controller,
        ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data.obras.length,
            itemBuilder: (context, index) {
              return filter == null || filter == "" ? ListTile(
                title: Text(
                  snapshot.data.obras[index].obra,
                ),
                onTap: () {
                  DatosUsuario().locationId = snapshot.data.obras[index].locationIdObra;
                  DatosUsuario().nombreObraActual = snapshot.data.obras[index].obra;
                  /* Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) =>ObraAvanzado(obra: snapshot.data.obras[index].obra)
                  )); */
                  Navigator.pushNamed(
                    context, 
                    tipoUsuario == 'AVANZADO' ? 'reporte' : 'reporteBasico',
                  );
                },
                trailing: Icon(Icons.keyboard_arrow_right),
              ) :
              snapshot.data.obras[index].obra.toLowerCase().contains(filter.toLowerCase()) ? 
              ListTile(
                title: Text(
                  snapshot.data.obras[index].obra,
                ),
                onTap: () {
                  DatosUsuario().locationId = snapshot.data.obras[index].locationIdObra;
                  DatosUsuario().nombreObraActual = snapshot.data.obras[index].obra;
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) =>ObraAvanzado(obra: snapshot.data.obras[index].obra)
                  ));
                },
                trailing: Icon(Icons.keyboard_arrow_right),
              ) : Container();
            },
          ),
        ),
      ],
    );
  } 
}

