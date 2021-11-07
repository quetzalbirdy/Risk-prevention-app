import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:nuevo_riesgos/src/resources/constantes.dart' as constantes;

class ServiciosConecta2 {
  final urlServicios = constantes.urlBase;
  dynamic obtenerJson(keywords, active, companyId, groupId, userId, token) async {     
    var client = http.Client();
    var url = 'http://$urlServicios/api/jsonws/vs-bpm-screen-portlet.customize/get-list-obras';        
    var uriResponse;
    try {
      uriResponse = await client.post(url,
          body: {'keywords': keywords == null ? '' : keywords, 'active': active == null ? '' : active, 'companyId': companyId == null ? '' : companyId, 'groupId': groupId == null ? '' : groupId, 'userId': userId == null ? '' : userId,},
          headers: {HttpHeaders.authorizationHeader: token},);          
    } finally {
      client.close();
    }   
    if (json.decode(uriResponse.body)['code'] != 0) {
      return 'intente mas tarde';
    } else {
      return json.decode(uriResponse.body);
    }    
  }  
}