import 'dart:convert';

import 'package:dart_rut_validator/dart_rut_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:nuevo_riesgos/src/resources/proveedor_servicio_obras.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nuevo_riesgos/src/resources/constantes.dart' as constantes;

class Login extends StatefulWidget {
  /* final LoginBloc _bloc;  
  Login(this._bloc);  */  

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final urlServicios = constantes.urlBase;

  @override 
  void initState() {          
    super.initState(); 
    getPermission();
    /* initPlatformState(); */
  }   

  getPermission() async {
    Location location = new Location();
    await location.requestPermission();
  }
  

  final _formKey = GlobalKey<FormState>();
  TextEditingController _fechaNacimientoController = TextEditingController();
  TextEditingController _numeroCelular = TextEditingController();  
  TextEditingController _rut = TextEditingController(); 
  FocusNode focusFecha = new FocusNode();
  FocusNode focusCelular = new FocusNode(); 
  bool _isLoading = false;  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).primaryColor,
      backgroundColor: Colors.white,    
      /* appBar: AppBar(
        title: Text(''),
        elevation: 0,
        backgroundColor: Colors.transparent,        
        actions: <Widget>[
          FlatButton(                
            child: Text('Supervisor jose'),           
            color: Colors.white, 
            onPressed: () {
              setState(() {
                _rut.text = '14295811-2';                      
                _fechaNacimientoController.value = TextEditingValue(text: '09/11/1974');
                _numeroCelular.text = '';
              });
            },
          ),
          FlatButton(     
            child: Text('Operario manuel'),       
            color: Colors.white, 
            onPressed: () {
              setState(() {
                _rut.text = '14579701-2';                      
                _fechaNacimientoController.value = TextEditingValue(text: '26/11/1976');
                _numeroCelular.text = '';
              });
            },
            ),
            FlatButton(
              child: Text('Gerente'), 
              color: Colors.white, 
              onPressed: () {
                setState(() {
                  _rut.text = '12140291-2';                      
                  _fechaNacimientoController.value = TextEditingValue(text: '29/08/1980');
                  _numeroCelular.text = '';
                });
              },
              ),
        ],
      ),  */
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: SingleChildScrollView(
            child: Column(          
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(    
                  fit: FlexFit.loose,          
                  flex: 1,
                  child: Column(      
                    mainAxisAlignment: MainAxisAlignment.spaceAround, 
                    crossAxisAlignment: CrossAxisAlignment.start,        
                    children: <Widget>[
                      /* Imagen con "prevencion de riesgo" */
                      Container(
                        /* height: 250.0, */height: 200.0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              alignment: Alignment.center,
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
                      ),                                           
                    ],
                  ),
                ),                  
                Flexible(
                  fit: FlexFit.loose,          
                  flex: 2,
                  child: Column(
                    children: <Widget>[
                      Column(                  
                        children: <Widget>[
                          Container(
                            alignment: Alignment.centerLeft,                        
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Text('Bienvenido', style: TextStyle(fontSize: 30),)
                          ),               
                          Container(
                            margin: EdgeInsets.only(bottom: 15.0),
                            alignment: Alignment.centerLeft,                        
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Text('Ingresa tus datos para continuar', style: TextStyle(color: Theme.of(context).accentColor, fontSize: 20),)
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 0.0),
                        child: Container(
                          padding: EdgeInsets.only(bottom: 30.0),
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.only(left: 5.0, bottom: 5.0),
                                  child: Text('RUT')
                                ),
                                Container(
                                  margin: EdgeInsets.only(bottom: 15.0),
                                  child: Material(
                                    elevation: 5.0,                              
                                    shadowColor: Colors.grey,
                                    borderRadius: BorderRadius.circular(10.0),                            
                                    child: Container(
                                      padding: EdgeInsets.only(top: 7.0, left: 10.0, right: 10.0, bottom: 0.0),                                
                                      child: Focus(
                                        onFocusChange: (hasNotFocus) {
                                          RUTValidator.formatFromTextController(_rut);  
                                        },
                                        child: TextFormField(
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          controller: _rut,                                                                            
                                          onChanged: (text) {                                           
                                            print(_rut.text.split('.').join());                                 
                                          },
                                          onFieldSubmitted: (value) {                   
                                            /* RUTValidator.formatFromTextController(_rut);     */                     
                                            FocusScope.of(context).requestFocus(focusFecha);
                                          },
                                          decoration: new InputDecoration(
                                            contentPadding: EdgeInsets.all(0),
                                            labelText: "ej: 12.345.678-9", 
                                            labelStyle: TextStyle(),                                 
                                            fillColor: Colors.white,                                                                                             
                                            enabledBorder: OutlineInputBorder(borderRadius:BorderRadius.circular(20.0), borderSide: BorderSide(color: Colors.white, width: 3.0),),                                
                                            focusedBorder: OutlineInputBorder(borderRadius:BorderRadius.circular(20.0), borderSide: BorderSide(color: Colors.white, width: 3.0),),
                                            //fillColor: Colors.green
                                          ),
                                          validator: (val) {
                                            if(val.length==0) {
                                              return "Este campo no puede estar vacío";
                                            }else{                                            
                                              return null;
                                            }
                                          },                                  
                                          style: new TextStyle(
                                            fontFamily: "Poppins",
                                          ),
                                        ),
                                      ),
                                    )
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(left: 5.0, bottom: 5.0),
                                  child: Text('Fecha de nacimiento')
                                ),
                                Container(
                                  margin: EdgeInsets.only(bottom: 15.0),
                                  child: Material(
                                    elevation: 5.0,
                                    shadowColor: Colors.grey,
                                    borderRadius: BorderRadius.circular(10.0),                            
                                    child: Container(
                                      padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 3.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          DatePicker.showDatePicker(context,                                      
                                              showTitleActions: true,
                                              locale: LocaleType.es,
                                              minTime: DateTime(1920, 1, 1),
                                              maxTime: DateTime(2010, 1, 1), onChanged: (date) {
                                            print('change $date');
                                          }, onConfirm: (date) {
                                            var formatoFecha = new DateFormat('dd/MM/yyyy');
                                            setState(() {                                      
                                              _fechaNacimientoController.value = TextEditingValue(text: formatoFecha.format(date).toString());
                                            });
                                          }, currentTime: DateTime.now());
            
                                        },
                                        child: AbsorbPointer(
                                          child: TextFormField(
                                            onFieldSubmitted: (value) {
                                              FocusScope.of(context).requestFocus(focusCelular);
                                            },
                                            textInputAction: TextInputAction.next,
                                            controller: _fechaNacimientoController,
                                            decoration: new InputDecoration(
                                              contentPadding: EdgeInsets.all(0),
                                              labelText: "ej: 30/12/2000", 
                                              labelStyle: TextStyle(),                                 
                                              fillColor: Colors.white,                                                                                             
                                              enabledBorder: OutlineInputBorder(borderRadius:BorderRadius.circular(20.0), borderSide: BorderSide(color: Colors.white, width: 3.0),),                                
                                              focusedBorder: OutlineInputBorder(borderRadius:BorderRadius.circular(20.0), borderSide: BorderSide(color: Colors.white, width: 3.0),),
                                              //fillColor: Colors.green
                                            ),                                    
                                            validator: (val) {
                                              if(val.length==0) {
                                                return "Este campo no puede estar vacío";
                                              }else{
                                                return null;
                                              }
                                            },
                                            keyboardType: TextInputType.datetime,
                                            style: new TextStyle(
                                              fontFamily: "Poppins",
                                            ),
                                          ),
                                        ),
                                      )
                                    )
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.only(left: 5.0, bottom: 5.0),
                                  child: Text('Número celular')
                                ),
                                Container(
                                  margin: EdgeInsets.only(bottom: 15.0),
                                  child: Material(
                                    elevation: 5.0,
                                    shadowColor: Colors.grey,
                                    borderRadius: BorderRadius.circular(10.0),                            
                                    child: Container(
                                      padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 3.0),
                                      child: TextFormField(       
                                        /* textInputAction: TextInputAction.next, */
                                        controller: _numeroCelular,   
                                        validator: (val) {
                                          if(val.length == 0) {
                                            return null;
                                          } else {
                                            if(val.length!=9) {
                                              return "Este campo requiere 9 dígitos";
                                            }else{
                                              return null;
                                            }
                                          }                                      
                                        },                       
                                        decoration: new InputDecoration(
                                          contentPadding: EdgeInsets.all(0),
                                          labelText: "ej: 912345678", 
                                          labelStyle: TextStyle(),                                 
                                          fillColor: Colors.white,                                                                                             
                                          enabledBorder: OutlineInputBorder(borderRadius:BorderRadius.circular(20.0), borderSide: BorderSide(color: Colors.white, width: 3.0),),                                
                                          focusedBorder: OutlineInputBorder(borderRadius:BorderRadius.circular(20.0), borderSide: BorderSide(color: Colors.white, width: 3.0),),
                                          //fillColor: Colors.green
                                        ),
                                        /* validator: (val) {
                                          if(val.length==0) {
                                            return "Este campo no puede estar vacío";
                                          }else{
                                            print(_numeroCelular.value.text);
                                            return null;
                                          }
                                        }, */
                                        keyboardType: TextInputType.phone,
                                        style: new TextStyle(
                                          fontFamily: "Poppins",
                                        ),
                                      ),
                                    )
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(                                
                                      width: 250.0,
                                      child: MaterialButton(                        
                                        shape: StadiumBorder(),
                                        textColor: Colors.white,
                                        color: Theme.of(context).accentColor,
                                        elevation: 1.0,
                                        onPressed: () async {
                                          if (_formKey.currentState.validate()) {
                                            setState(() {
                                              _isLoading = true;
                                            });  
                                            SharedPreferences prefs = await SharedPreferences.getInstance();                                      
                                            await ServiciosConectaDio().hacerLogin(_rut.text.split('.').join(), _fechaNacimientoController.text, _numeroCelular.text, 'http://$urlServicios/api/jsonws/vs-bpm-screen-portlet.app/login').then((value) {                                                                                  
                                              if (json.decode(value.body)['code'] == 0) {
                                                OneSignal.shared.setExternalUserId(json.decode(value.body)['body']['userId'].toString());
                                                if (json.decode(value.body)['body']['profile'] == 'TRABAJADOR') {  
                                                  prefs.setString('tipoDeUsuario', 'TRABAJADOR');                                           
                                                  Navigator.pushNamedAndRemoveUntil(context, 'inicio', (route) => false);
                                                } else {
                                                  prefs.setString('tipoDeUsuario', 'AVANZADO');                                           
                                                  Navigator.pushNamedAndRemoveUntil(context, 'mainAvanzado', (route) => false);
                                                }                                                                                      
                                              } else {
                                                setState(() {
                                                  _isLoading = false;
                                                });  
                                              }  
                                              setState(() {
                                                _isLoading = false;
                                              });                                          
                                            });                                                                                                                        
                                          }                                      
                                        },
                                        child: _isLoading == false ? Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(Icons.save_alt),
                                            Padding(
                                              padding: EdgeInsets.only(left: 10.0),
                                              child: Text(
                                                'Ingresar',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 20
                                                  )
                                              ),
                                            )
                                          ],
                                        ) : Center(
                                          child: Container(
                                            width: 20.0,
                                            height: 20.0,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.0,
                                              valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                                            )
                                            ,)
                                          ),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          )
                        )
                      ),
                    ],
                  ),
                )
              ],
            )
          )
        ),
      )
    );
  }
}