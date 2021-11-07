import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nuevo_riesgos/src/resources/datos/medios.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:nuevo_riesgos/src/resources/constantes.dart' as constantes;



class ServiciosConectaPostDio {  
  final token = constantes.token;     
  final urlServicios = constantes.urlBase;

  Future subirMedios(incidenteId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    /* Medios Normales */
    if (Medios().imageList != null) {
      if (Medios().imageList.length > 0) {
        Fluttertoast.showToast(
          msg: 'Subiendo imagenes',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,          
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
        );      
        for (var count = 0; count < Medios().imageList.length; count++) {
          print('path foto');
          print(Medios().imageList[count].path);
          await ServiciosConectaPostDio().subirMediosArchivo(incidenteId, prefs.getInt('companyId').toString(), prefs.getInt('userId').toString(), prefs.getInt('groupId').toString(), 'http://$urlServicios/api/jsonws/vs-bpm-screen-portlet.incidente/add-file-entry', Medios().imageList[count].path);           
        } 
      }                  
    } 
    if (Medios().audioFiles != null) {
      if (Medios().audioFiles.length > 0) {
        Fluttertoast.showToast(
            msg: 'Subiendo audios',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,          
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );      
        for (var count = 0; count < Medios().audioFiles.length; count++) {        
          await ServiciosConectaPostDio().subirMediosArchivo(incidenteId, prefs.getInt('companyId').toString(), prefs.getInt('userId').toString(), prefs.getInt('groupId').toString(), 'http://$urlServicios/api/jsonws/vs-bpm-screen-portlet.incidente/add-file-entry', Medios().audioFiles[count]);           
        } 
      }
    } 
    if (Medios().videoFiles != null) {
      if (Medios().videoFiles.length > 0) {
        Fluttertoast.showToast(
            msg: 'Subiendo videos',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,          
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
        for (var count = 0; count < Medios().videoFiles.length; count++) {
          await ServiciosConectaPostDio().subirMediosArchivo(incidenteId, prefs.getInt('companyId').toString(), prefs.getInt('userId').toString(), prefs.getInt('groupId').toString(), 'http://$urlServicios/api/jsonws/vs-bpm-screen-portlet.incidente/add-file-entry', Medios().videoFiles[count].path);           
        }
      }       
    }  
    Medios().audioFiles = [];
    Medios().videoFiles = [];
    Medios().imageList = [];

    /* Medios resolucion */
    if (Medios().imageListEvidenciaResolutiva != null) {
      if (Medios().imageListEvidenciaResolutiva.length > 0) {
        Fluttertoast.showToast(
          msg: 'Subiendo imagenes',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,          
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
        );      
        for (var count = 0; count < Medios().imageListEvidenciaResolutiva.length; count++) {
          print('path foto');
          print(Medios().imageListEvidenciaResolutiva[count].path);
          await ServiciosConectaPostDio().subirMediosArchivoResolutivo(incidenteId, prefs.getInt('companyId').toString(), prefs.getInt('userId').toString(), prefs.getInt('groupId').toString(), 'http://$urlServicios/api/jsonws/vs-bpm-screen-portlet.incidente/add-file-entry', Medios().imageListEvidenciaResolutiva[count].path);           
        } 
      }                  
    }     
    if (Medios().videoFilesEvidenciaResolutiva != null) {
      if (Medios().videoFilesEvidenciaResolutiva.length > 0) {
        Fluttertoast.showToast(
            msg: 'Subiendo videos',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,          
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
        for (var count = 0; count < Medios().videoFilesEvidenciaResolutiva.length; count++) {
          await ServiciosConectaPostDio().subirMediosArchivoResolutivo(incidenteId, prefs.getInt('companyId').toString(), prefs.getInt('userId').toString(), prefs.getInt('groupId').toString(), 'http://$urlServicios/api/jsonws/vs-bpm-screen-portlet.incidente/add-file-entry', Medios().videoFilesEvidenciaResolutiva[count].path);           
        }
      }       
    }      
    Medios().videoFilesEvidenciaResolutiva = [];
    Medios().imageListEvidenciaResolutiva = [];

    return 'succesfull';
  } 

  Future subirMediosArchivo(incidenteId, companyId, userId, groupId, url, archivo) async {         

    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(archivo, filename: archivo.toString().split('/').last), 
      /* "cmd": {"/vs-bpm-screen-portlet.incidente/add-file-entry":{}}, */
      'incidenteId': incidenteId, 
      'companyId': companyId, 
      'userId': userId, 
      'groupId': groupId,
      'tipo' : 0
    });  

    print('form data');
    print(formData);
    print(archivo.toString().split('/').last);

    Dio dio = new Dio();
    dio.options.headers['authorization'] = token;
    Response response = await dio.post(url, data: formData/* , onSendProgress: (int sent, int total) {
      print("$sent $total");
    }, */
              /* body: {}, */
              /* headers: {HttpHeaders.authorizationHeader: token} */);                  
    /* print(response.body); */
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON     
      print(response.data); 
      if(response.data['code'] == 0) {
        /* print(json.decode(response.body)['body']['incidenteId']); */
        /* Fluttertoast.showToast(
          msg: archivo.toString().split('/').last + ' se subio',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,          
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      ); */        
        print(archivo.toString().split('/').last + ' se subio');
        return response;        
      } else {
        Fluttertoast.showToast(
          msg: 'No se logró guardar el incidente, intente nuevamente',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,          
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
        );
        print('No se logró guardar el incidente, intente nuevamente');
        return 'no se subio';
      }
    } else {
      // If that call was not successful, throw an error.
      Fluttertoast.showToast(
        msg: 'No se logró guardar el incidente, intente nuevamente',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,          
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
      );
      print('No se logró guardar el incidente, intente nuevamente');
      throw Exception('No se logró guardar el incidente, intente nuevamente');      
    }    
  }

  Future subirMediosArchivoResolutivo(incidenteId, companyId, userId, groupId, url, archivo) async {         

    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(archivo, filename: archivo.toString().split('/').last), 
      /* "cmd": {"/vs-bpm-screen-portlet.incidente/add-file-entry":{}}, */
      'incidenteId': incidenteId, 
      'companyId': companyId, 
      'userId': userId, 
      'groupId': groupId,
      'tipo' : 1
    });  

    print('form data');
    print(formData);
    print(archivo.toString().split('/').last);

    Dio dio = new Dio();
    dio.options.headers['authorization'] = token;
    Response response = await dio.post(url, data: formData/* , onSendProgress: (int sent, int total) {
      print("$sent $total");
    }, */
              /* body: {}, */
              /* headers: {HttpHeaders.authorizationHeader: token} */);                  
    /* print(response.body); */
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON     
      print(response.data); 
      if(response.data['code'] == 0) {
        /* print(json.decode(response.body)['body']['incidenteId']); */
        /* Fluttertoast.showToast(
          msg: archivo.toString().split('/').last + ' se subio',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,          
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      ); */        
        print(archivo.toString().split('/').last + ' se subio');
        return response;        
      } else {
        Fluttertoast.showToast(
          msg: 'No se logró guardar el incidente, intente nuevamente',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,          
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
        );
        print('No se logró guardar el incidente, intente nuevamente');
        return 'no se subio';
      }
    } else {
      // If that call was not successful, throw an error.
      Fluttertoast.showToast(
        msg: 'No se logró guardar el incidente, intente nuevamente',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,          
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
      );
      print('No se logró guardar el incidente, intente nuevamente');
      throw Exception('No se logró guardar el incidente, intente nuevamente');      
    }    
  } 
}