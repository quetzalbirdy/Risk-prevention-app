import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nuevo_riesgos/src/blocs/incidentes_bloc.dart';
import 'package:nuevo_riesgos/src/blocs/mensajes_bloc.dart';
import 'package:nuevo_riesgos/src/models/incidentes_model.dart';
import 'package:nuevo_riesgos/src/models/mensajes_model.dart';
import 'package:nuevo_riesgos/src/ui/incidente_historico.dart';
import 'package:nuevo_riesgos/src/ui/mensaje_basico.dart';
import 'package:intl/intl.dart';

class ReportesHistoricos extends StatefulWidget {
  final IncidentesBloc _bloc;    
  ReportesHistoricos(this._bloc);
  
  @override
  _ReportesHistoricosState createState() => _ReportesHistoricosState();
}

class _ReportesHistoricosState extends State<ReportesHistoricos> {
  @override
  void initState() {    
    widget._bloc.init();    
    widget._bloc.fetchIncidentes();         
    super.initState();
  }
  @override
  void dispose() {
    widget._bloc.dispose();
    super.dispose();
  }

  bool mostrarSemanales = false;
  DateTime now = DateTime.now();

  formatDate(fechaMilisegundos) {
    return DateFormat('dd/MM/yyyy – kk:mm').format(DateTime.fromMillisecondsSinceEpoch(fechaMilisegundos));
  }


  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Mis reportes'),
        centerTitle: true,
        leading: new IconButton(
        icon: new Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: StreamBuilder(
          stream: widget._bloc.allIncidentes,
          builder: (context, AsyncSnapshot<IncidentesModel> snapshot) {
            if (snapshot.hasData) {
              return snapshot.data.incidentes.length > 0 ? buildIncidentes(snapshot) : Center(child: Text('No tienes reportes hechos', style: TextStyle(fontSize: 20.0)),);
            } else if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            return Center(child: CircularProgressIndicator(),);
          },
        ),
      )      
    );
  }
  
  Widget buildIncidentes(AsyncSnapshot<IncidentesModel> snapshot) {
    List mensajesOrdenados = snapshot.data.incidentes.reversed.toList();    
    return Stack(
      children: <Widget>[
        ListView.builder(                                  
          itemCount: snapshot.data.incidentes.length,
          itemBuilder: (context, index) {      
            print(mensajesOrdenados[index].responsable); 
            if (mostrarSemanales == true) {
              return 
              now.difference(DateTime.fromMillisecondsSinceEpoch(mensajesOrdenados[index].createDate)).inDays < 7 ?
              Card(
                elevation: 2.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Opacity(
                        opacity: mensajesOrdenados[index].cerrado ? 0.6 : 1.0,
                        child: ListTile(
                          /* Tipo de incidente */
                          /* title: Text(json.decode(incidentes)[index]['data_'][0][0]['list'][valorTipoIncidente-1]['title'].toString()), */
                          title: Text(mensajesOrdenados[index].tituloIncidente),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              /* obra */
                              Text('Estado: ' + mensajesOrdenados[index].estadoIncidente, style: TextStyle(color: Colors.black)),
                              /* Text(mensajesOrdenados[index].body, style: TextStyle(color: Colors.black)), */
                              Text(formatDate(mensajesOrdenados[index].createDate), style: TextStyle(color: Colors.black)),                      
                              /* usuario */
                              /* Text(mensajesOrdenados[index].userSend, style: TextStyle(color: Colors.black)),     */                  
                            ],
                          ),
                          selected: true,
                          // leading: Icon(Icons.priority_high, size: 40.0,),
                          /* trailing: json.decode(incidentes)[index]['estadoIncidente'].toString() == 'pendiente' ? Icon(Icons.input) : (json.decode(incidentes)[index]['estadoIncidente'].toString() == 'resuelto' ? Icon(Icons.assignment_turned_in) : Icon(Icons.loop)), */
                          trailing: mensajesOrdenados[index].estadoIncidente == 'Resuelto' ? Icon(Icons.assignment_turned_in, size: 40.0, color: Colors.green[800],) : mensajesOrdenados[index].estadoIncidente == 'Pendiente' ? Icon(Icons.assignment_late, size: 40.0, color: Colors.yellow[900],) : Icon(Icons.assignment, size: 40.0, color: Colors.yellow[700],),
                          onTap: () {
                            Navigator.push(context, 
                            MaterialPageRoute(builder: (context) => IncidenteHistorico(cerrado: mensajesOrdenados[index].cerrado, incidente: mensajesOrdenados[index].incidente, incidentId: mensajesOrdenados[index].incidenteId, responsable: mensajesOrdenados[index].responsable, tituloIncidente: mensajesOrdenados[index].tituloIncidente )));                             
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ) : Container();
            } else {
              return Card(
                elevation: 2.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child:  Opacity(
                        opacity: mensajesOrdenados[index].cerrado ? 0.6 : 1.0,
                        child: ListTile(
                          /* Tipo de incidente */
                          /* title: Text(json.decode(incidentes)[index]['data_'][0][0]['list'][valorTipoIncidente-1]['title'].toString()), */
                          title: Text(mensajesOrdenados[index].tituloIncidente),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              /* obra */
                              Text('Estado: ' + mensajesOrdenados[index].estadoIncidente, style: TextStyle(color: Colors.black)),
                              /* Text(mensajesOrdenados[index].body, style: TextStyle(color: Colors.black)), */
                              Text(formatDate(mensajesOrdenados[index].createDate), style: TextStyle(color: Colors.black)),                      
                              /* usuario */
                              /* Text(mensajesOrdenados[index].userSend, style: TextStyle(color: Colors.black)),     */                  
                            ],
                          ),
                          selected: true,
                          // leading: Icon(Icons.priority_high, size: 40.0,),
                          /* trailing: json.decode(incidentes)[index]['estadoIncidente'].toString() == 'pendiente' ? Icon(Icons.input) : (json.decode(incidentes)[index]['estadoIncidente'].toString() == 'resuelto' ? Icon(Icons.assignment_turned_in) : Icon(Icons.loop)), */
                          trailing: mensajesOrdenados[index].estadoIncidente == 'Resuelto' ? Icon(Icons.assignment_turned_in, size: 40.0, color: Colors.green[800],) : mensajesOrdenados[index].estadoIncidente == 'Pendiente' ? Icon(Icons.assignment_late, size: 40.0, color: Colors.yellow[900],) : Icon(Icons.assignment, size: 40.0, color: Colors.yellow[700],),
                          onTap: () {
                            Navigator.push(context, 
                            MaterialPageRoute(builder: (context) => IncidenteHistorico(cerrado: mensajesOrdenados[index].cerrado, incidente: mensajesOrdenados[index].incidente, incidentId: mensajesOrdenados[index].incidenteId, responsable: mensajesOrdenados[index].responsable, tituloIncidente: mensajesOrdenados[index].tituloIncidente )));                             
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }                            
          },
        ),
        Positioned(
          bottom: 30.0,
          left: (MediaQuery.of(context).size.width / 2) - 135,
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
            width: 250.0,                                
            height: 45.0,
            child: Row(                                  
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        mostrarSemanales = true;
                      });
                      print(now.difference(DateTime.fromMillisecondsSinceEpoch(mensajesOrdenados[1].createDate)).inDays);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.tune, color: Colors.white),
                        Text('Ult. 7 dias', style: TextStyle(color: Colors.white))
                      ],
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
                        mostrarSemanales = false;
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