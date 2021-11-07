import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' show Client, Response;
import 'package:http/http.dart' as http;
import 'package:nuevo_riesgos/src/models/incidentes_model.dart';
import 'package:nuevo_riesgos/src/models/mensajes_model.dart';
import 'package:nuevo_riesgos/src/models/supervisores_model.dart';
import 'package:nuevo_riesgos/src/resources/datos/datos_form.dart';
import 'package:nuevo_riesgos/src/resources/datos/medios.dart';
import 'package:nuevo_riesgos/src/resources/proveedor_servicio_dio.dart';
import 'package:retry/retry.dart';
import 'dart:convert';
import '../models/obras_model.dart';
import '../models/forms_model.dart';
import '../models/medios_model.dart';
import 'package:inject/inject.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nuevo_riesgos/src/resources/constantes.dart' as constantes;

class ServiciosConecta {
  final Client client;
  final token = constantes.token;
  final urlServicios = constantes.urlBase;

  @provide 
  ServiciosConecta(this.client);

  Future<ObrasModel> fetchListaObras(keywords, active, url) async {
    print("entered " + token);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Response response = await client.post(url,
              body: {'keywords': keywords, 'active': active, 'companyId': prefs.getInt('companyId').toString(), 'groupId': prefs.getInt('groupId').toString(), 'userId': prefs.getInt('userId').toString()},
              headers: {HttpHeaders.authorizationHeader: token},);                  
    /* print(response.body); */
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      return ObrasModel.fromJson(json.decode(response.body));
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }  

  Future<FormsModel> fetchFormAvanzado(active) async {
    print("entered " + token);
    SharedPreferences prefs = await SharedPreferences.getInstance();    
    Response responseAgregar = await client.post('http://$urlServicios/api/jsonws/vs-bpm-screen-portlet.formularioapp/get-form',
              body: {'activo': active, 'groupId': prefs.getInt('groupId').toString(), 'name': 'formAgregarInfo'},
              headers: {HttpHeaders.authorizationHeader: token},);                                          
    /* print(response.body); */
    if (responseAgregar.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      var formularioAvanzado = '{"formAgregarInfo": ${responseAgregar.body}}';      
      return FormsModel.fromJson(json.decode(formularioAvanzado));
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }
  
  Future<FormsModel> fetchFormularios(active, nombrePrincipal, nombreAgregar, url) async {
    print("entered " + token);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Response responsePrincipal = await http.post(url,
              body: {'activo': active, 'groupId': prefs.getInt('groupId').toString(), 'name': nombrePrincipal},
              headers: {HttpHeaders.authorizationHeader: token},); 
    /* Response responseComunicar = await client.post(url,
              body: {'activo': active, 'groupId': prefs.getInt('groupId').toString(), 'name': nombreComunicar},
              headers: {HttpHeaders.authorizationHeader: token},);  */
    /* Response responseEstado = await client.post(url,
              body: {'activo': active, 'groupId': prefs.getInt('groupId').toString(), 'name': nombreEstado},
              headers: {HttpHeaders.authorizationHeader: token},);  */
    Response responseAgregar = await http.post(url,
              body: {'activo': active, 'groupId': prefs.getInt('groupId').toString(), 'name': nombreAgregar},
              headers: {HttpHeaders.authorizationHeader: token},);                                          
    /* print(response.body); */
    if (responsePrincipal.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      var todosFormularios = '{"formPrincipal" : ${responsePrincipal.body}, "formAgregarInfo": ${responseAgregar.body}}';      
      return FormsModel.fromJson(json.decode(todosFormularios));
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }  

  Future<IncidentesModel> fetchIncidentes(flagEliminado, url) async {
    /* print("entered " + token); */
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Response response = await client.post(url,
              body: {'userId': prefs.getInt('userId').toString(), 'groupId': prefs.getInt('groupId').toString(), 'flagEliminado': flagEliminado},
              headers: {HttpHeaders.authorizationHeader: token},);                  
    /* print(response.body); */
    /* print(json.decode(json.decode(json.decode(response.body)['body'][0]['data']))['formPrincipal'][0]['list'][6]);     */
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      return IncidentesModel.fromJson(json.decode(response.body));
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }   

  Future<MediosModel> fetchMedios(incidenteId, pathHost, url) async {
    /* print("entered " + token); */
    Response response = await http.post(url,
              body: {'incidenteId': incidenteId.toString(), 'pathHost': pathHost},
              headers: {HttpHeaders.authorizationHeader: token},);                  
    /* print(response.body); */
    /* print(json.decode(json.decode(json.decode(response.body)['body'][0]['data']))['formPrincipal'][0]['list'][6]);     */
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      if ( json.decode(response.body)['body'] != null) {
        return MediosModel.fromJson(json.decode(response.body));  
      } else {
        return null;
      }       
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  } 

  Future<String> actualizarVideos(videoFile) {
    return videoFile;
  } 

  Future<SupervisoresModel> obtenerSupervisores(obraId) async {
    /* print("entered " + token); */
    Response response = await http.post('http://$urlServicios/api/jsonws/vs-bpm-screen-portlet.incidente/get-lista-supervisor-by-obra/',
              body: {'obraId': obraId.toString()},
              headers: {HttpHeaders.authorizationHeader: token},);                  
    /* print(response.body); */
    /* print(json.decode(json.decode(json.decode(response.body)['body'][0]['data']))['formPrincipal'][0]['list'][6]);     */
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON      
      return SupervisoresModel.fromJson(json.decode(response.body));      
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }   

  Future<SupervisoresModel> obtenerAdministradores(obraId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    /* print("entered " + token); */
    Response response = await http.post('http://$urlServicios/api/jsonws/vs-bpm-screen-portlet.incidente/get-lista-administradores-by-obra/',
              body: {'obraId': obraId.toString(), 'groupId': prefs.getInt('groupId').toString() },
              headers: {HttpHeaders.authorizationHeader: token},);                  
    /* print(response.body); */
    /* print(json.decode(json.decode(json.decode(response.body)['body'][0]['data']))['formPrincipal'][0]['list'][6]);     */
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON            
      return SupervisoresModel.fromJson(json.decode(response.body));      
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }  

  Future<MensajesModel> fetchMensajes(url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    /* print("entered " + token); */
    Response response = await http.post(url,
              body: {'userId': prefs.getInt('userId').toString()},
              headers: {HttpHeaders.authorizationHeader: token},);                  
    /* print(response.body); */
    /* print(json.decode(json.decode(json.decode(response.body)['body'][0]['data']))['formPrincipal'][0]['list'][6]);     */
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON      
      return MensajesModel.fromJson(json.decode(response.body));      
    } else {
      // If that call was not successful, throw an error.
      Fluttertoast.showToast(
            msg: 'No se logró establecer conexión',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            /* timeInSecForIos: 1, */
            backgroundColor: Colors.red,
            textColor: Colors.white);
      throw Exception('Failed to load post');
    }
  }  

  /* Future<LoginModel> fetchLogin(rut, birthday, fono, url) async {
    /* print("entered " + token); */
    Response response = await client.post(url,
              body: {'rut': rut, 'birthday': birthday, 'fono': fono},
              headers: {HttpHeaders.authorizationHeader: token},);                  
    /* print(response.body); */
    /* print(json.decode(json.decode(json.decode(response.body)['body'][0]['data']))['formPrincipal'][0]['list'][6]);     */
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      return LoginModel.fromJson(json.decode(response.body));
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }   */    
}

class ServiciosConectaDio {  
  final urlServicios = constantes.urlBase;
  final token = constantes.token;

  Future<http.Response> hacerLogin(rut, birthday, fono, url) async {
    /* print("entered " + token); */
    Response response = await retry(
      () => http.post(url,
                      body: {'rut': rut, 'birthday': birthday, 'fono': fono},
                      headers: {HttpHeaders.authorizationHeader: token},)  
    );              
    /* print(response.body); */
    /* print(json.decode(json.decode(json.decode(response.body)['body'][0]['data']))['formPrincipal'][0]['list'][6]);     */
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      if (json.decode(response.body)['code'] == 0) {
        var body = json.decode(response.body)['body'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt('companyId', body['companyId']);
        prefs.setInt('groupId', body['groupId']);
        prefs.setInt('userId', body['userId']);        
        prefs.setString('name', body['name']);
        prefs.setString('userName', body['userName']);
        prefs.setString('rut', rut);
        prefs.setString('fechaNacimiento', birthday);
        print('ids');
        print(prefs.getInt('companyId'));
        print(prefs.getInt('groupId'));
        print(prefs.getInt('userId'));
        print(prefs.getString('name'));
        print(prefs.getString('userName'));
      } else {
        Fluttertoast.showToast(
          msg: 'Los datos no corresponden a un usuario válido',          
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,          
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
        );
      }
      print(response.body);
      return response;
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  } 

  Future<http.Response> obtenerObraCoordenadas(latitude, longitude) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();    
    Response response = await retry(
      () => http.post('http://$urlServicios/api/jsonws/vs-bpm-screen-portlet.app/list-obras-by-coordinates/',
                      body: {'latitude': latitude.toString(), 'longitude': longitude.toString(), 'perimetro': '100', 'userId': prefs.getInt('userId').toString(), 'groupId': prefs.getInt('groupId').toString(), 'companyId': prefs.getInt('companyId').toString()},
                      headers: {HttpHeaders.authorizationHeader: token},)  
    );              
    /* print(response.body); */
    /* print(json.decode(json.decode(json.decode(response.body)['body'][0]['data']))['formPrincipal'][0]['list'][6]);     */
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      if (json.decode(response.body)['code'] == 0) {
        var body = json.decode(response.body)['body'];     
        print(body);           
      } else {
        Fluttertoast.showToast(
          msg: 'No se encontró una obra',          
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,          
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      }      
      return response;
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }  

  Future<http.Response> enviarMensaje(userId, threadId, incidenteId, parentMessageId, asunto, cuerpo) async {
    /* print("entered " + token); */    
    Response response = await http.post('http://$urlServicios/api/jsonws/vs-bpm-screen-portlet.incidente/send-message/',
      body: {'userId': userId.toString(), 'incidenteId': incidenteId.toString(),'threadId': threadId.toString(), 'parentMessageId': parentMessageId.toString(), 'subject': asunto, 'body': cuerpo},
      headers: {HttpHeaders.authorizationHeader: token},
    );              
    /* print(response.body); */
    /* print(json.decode(json.decode(json.decode(response.body)['body'][0]['data']))['formPrincipal'][0]['list'][6]);     */
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      if (json.decode(response.body)['code'] == 0) {
        var body = json.decode(response.body)['body'];
       
      } else if (json.decode(response.body)['code'] == -1) {
        Fluttertoast.showToast(
          msg: 'Los datos no corresponden a un usuario válido',          
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,          
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      }
      print(response.body);
      return response;
    } else {
      Fluttertoast.showToast(
          msg: 'No se logró enviar el mensaje, intente nuevamente',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,          
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  } 

  Future<http.Response> cambiarEstado(incidenteId, estado, ) async {
    /* print("entered " + token); */
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Response response = await retry(
      () => http.post('http://$urlServicios/api/jsonws/vs-bpm-screen-portlet.incidente/cambiar-estado/',
                      body: {'userId': prefs.getInt('userId').toString(), 'groupId': prefs.getInt('groupId').toString(), 'companyId': prefs.getInt('companyId').toString(), 'incidenteId': incidenteId.toString(), 'estado': estado},
                      headers: {HttpHeaders.authorizationHeader: token},)  
    );              
    /* print(response.body); */
    /* print(json.decode(json.decode(json.decode(response.body)['body'][0]['data']))['formPrincipal'][0]['list'][6]);     */
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      if (json.decode(response.body)['code'] == 0) {
        print(response.body);       
      } else if (json.decode(response.body)['code'] == -1) {
        Fluttertoast.showToast(
          msg: 'Los datos no corresponden a un usuario válido',          
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,          
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      }
      print(response.body);
      return response;
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }    
    
  Future<http.Response> crearIncidente(incidenteId, tipo, data, locationId, userTo, url, gravedad, fechaIncidente, timestamp) async {    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      Response response = await http.post(url,
        body: {'userTo': userTo,'incidenteId': incidenteId, 'tipo': tipo, 'gravedad': gravedad, 'fechaIncidente': fechaIncidente, 'data': data, 'locationId': locationId, 'companyId': prefs.getInt('companyId').toString(), 'userId': prefs.getInt('userId').toString(), 'groupId': prefs.getInt('groupId').toString(), 'idUnique': timestamp.toString()},
        headers: {HttpHeaders.authorizationHeader: token},
      );
      if (response.statusCode == 200) {
        /* print(json.decode(response.body)); */
      // If the call to the server was successful, parse the JSON      
      if(json.decode(response.body)['code'] == 0) {
        /* print(json.decode(response.body)['body']['incidenteId']); */
        await ServiciosConectaPostDio().subirMedios(json.decode(response.body)['body']['incidenteId']);        
        DatosForm().formAvanzdo = null;
        DatosForm().formPrincipal = null;
        DatosForm().formEstado = null;
        DatosForm().formComunicar1 = null;
        DatosForm().formComunicar2 = null;
        return response;        
      } else {       
        print('-1');
        print(json.decode(response.body)['message']); 
        if (json.decode(response.body)['message'] == 'java.lang.Exception: usuario desactivado') {
          prefs.setString('rut', '');
          prefs.setString('fechaNacimiento', '');
          DatosForm().formAvanzdo = null;
          DatosForm().formPrincipal = null;
          DatosForm().formEstado = null;
          DatosForm().formComunicar1 = null;
          DatosForm().formComunicar2 = null;
          Medios().audioFiles = [];
          Medios().videoFiles = [];
          Medios().imageList = [];
          Fluttertoast.showToast(
            msg: 'El usuario no está activo',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,          
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
          );
          return response;                
        } else {
          Fluttertoast.showToast(
            msg: 'No se logro guardar el incidente, intenta nuevamente, code distinto de 0',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,          
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
          );
        }                        
      }
    } else {
      // If that call was not successful, throw an error.
      Fluttertoast.showToast(
              msg: 'No se lograron subir los medios, intenta nuevamente, falla internet',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,          
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0
          );
      throw Exception('No se logró guardar el incidente, intente nuevamente, falla internet');      
    } 
    return response; 
    } catch (error) {
      print(error);
    }                  
  }   

  Future<String> fetchUnreadCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    /* print("entered " + token); */
    Response response = await http.post('http://$urlServicios/api/jsonws/vs-bpm-screen-portlet.incidente/get-messages-unread-count',
              body: {'userId': prefs.getInt('userId').toString()},
              headers: {HttpHeaders.authorizationHeader: token},);                  
    /* print(response.body); */
    /* print(json.decode(json.decode(json.decode(response.body)['body'][0]['data']))['formPrincipal'][0]['list'][6]);     */
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON   
      print('unread');
      print(json.decode(response.body)['body']);
      prefs.setString('unreadMessagesCount', json.decode(response.body)['body'].toString());
      return response.body;
    } else {
      // If that call was not successful, throw an error.
      Fluttertoast.showToast(
            msg: 'No se logró establecer conexión',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            /* timeInSecForIos: 1, */
            backgroundColor: Colors.red,
            textColor: Colors.white);
      throw Exception('Failed to load post');
    }
  }

  Future<String> fetchIncidentesAtrasados() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    /* print("entered " + token); */
    Response response = await http.post('http://$urlServicios/api/jsonws/vs-bpm-screen-portlet.incidente/has-incidentes-atrasados',
              body: {'userId': prefs.getInt('userId').toString()},
              headers: {HttpHeaders.authorizationHeader: token},);                  
    /* print(response.body); */
    /* print(json.decode(json.decode(json.decode(response.body)['body'][0]['data']))['formPrincipal'][0]['list'][6]);     */
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON   
      print('atrasados');
      print(json.decode(response.body)['body']);      
      return response.body;
    } else {
      // If that call was not successful, throw an error.
      Fluttertoast.showToast(
            msg: 'No se logró establecer conexión',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            /* timeInSecForIos: 1, */
            backgroundColor: Colors.red,
            textColor: Colors.white);
      throw Exception('Failed to load post');
    }
  }

  Future<String> setMessageRead(messageId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    /* print("entered " + token); */
    Response response = await http.post('http://$urlServicios/api/jsonws/vs-bpm-screen-portlet.incidente/set-messages-read',
              body: {'userId': prefs.getInt('userId').toString(), 'messageId': messageId.toString()},
              headers: {HttpHeaders.authorizationHeader: token},);                  
    /* print(response.body); */
    /* print(json.decode(json.decode(json.decode(response.body)['body'][0]['data']))['formPrincipal'][0]['list'][6]);     */
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON   
      print('unread');
      print(response.body);      
      return json.decode(response.body)['body'].toString();
    } else {
      // If that call was not successful, throw an error.
      Fluttertoast.showToast(
            msg: 'No se logró establecer conexión',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            /* timeInSecForIos: 1, */
            backgroundColor: Colors.red,
            textColor: Colors.white);
      throw Exception('Failed to load post');
    }
  }
}