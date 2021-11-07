import 'package:flutter/material.dart';
import 'package:nuevo_riesgos/src/blocs/mensajes_bloc.dart';
import 'package:nuevo_riesgos/src/models/mensajes_model.dart';
import 'package:nuevo_riesgos/src/ui/mensaje_basico.dart';
import 'package:intl/intl.dart';

class MensajesBasico extends StatefulWidget {
  final MensajesBloc _bloc;    
  MensajesBasico(this._bloc);
  
  @override
  _MensajesBasicoState createState() => _MensajesBasicoState();
}

class _MensajesBasicoState extends State<MensajesBasico> with WidgetsBindingObserver {
  @override
  void initState() {  
    super.initState();  
    widget._bloc.init();    
    widget._bloc.fetchListaMensajes();         
    WidgetsBinding.instance.addObserver(this);       
  }
  @override
  void dispose() {
    widget._bloc.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('resumend');
      widget._bloc.fetchListaMensajes(); 
    }    
  }

  formatDate(fechaMilisegundos) {
    return DateFormat('dd/MM/yyyy – kk:mm').format(DateTime.fromMillisecondsSinceEpoch(fechaMilisegundos));
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Avisos'),
        centerTitle: true,
        leading: new IconButton(
        icon: new Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pushNamed(
            context,
            'inicio',
          );
        },
      ),
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: StreamBuilder(
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
      ) 
      // body: Center(
      //   // child: Container(
      //   //   width: 200.0,
      //   //   child: Text('Hemos resuelto el riesgo informado por ti \n\nGracias por tu aporte', style: TextStyle(fontSize: 20.0),),
      //   // ),
      // )
    );
  }
  
  Widget buildIncidentes(AsyncSnapshot<MensajesModel> snapshot) {
    List mensajesOrdenados = snapshot.data.mensajes.reversed.toList();
    return ListView.builder(                                  
      itemCount: snapshot.data.mensajes.length,
      itemBuilder: (context, index) {                                      
        return Card(
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
                child: Opacity(
                  opacity: mensajesOrdenados[index].cerrado ? 0.6 : 1.0,
                  child: ListTile(
                    /* Tipo de incidente */
                    /* title: Text(json.decode(incidentes)[index]['data_'][0][0]['list'][valorTipoIncidente-1]['title'].toString()), */
                    title: Text(mensajesOrdenados[index].tituloIncidente, style: TextStyle(color: !mensajesOrdenados[index].cerrado ? Theme.of(context).accentColor : Colors.black, fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        /* obra */
                        Text('Estado: ' + mensajesOrdenados[index].estadoIncidente, style: TextStyle(color: Colors.black)),
                        Text(mensajesOrdenados[index].body, style: TextStyle(color: Colors.black)),
                        Text(formatDate(mensajesOrdenados[index].createDate), style: TextStyle(color: Colors.black)),                      
                        /* usuario */
                        Text(mensajesOrdenados[index].userSend, style: TextStyle(color: Colors.black)),                      
                      ],
                    ),
                    selected: true,
                    // leading: Icon(Icons.priority_high, size: 40.0,),
                    /* trailing: json.decode(incidentes)[index]['estadoIncidente'].toString() == 'pendiente' ? Icon(Icons.input) : (json.decode(incidentes)[index]['estadoIncidente'].toString() == 'resuelto' ? Icon(Icons.assignment_turned_in) : Icon(Icons.loop)), */
                    trailing: mensajesOrdenados[index].estadoIncidente == 'Resuelto' ? Icon(Icons.assignment_turned_in, size: 40.0, color: Colors.grey,) : (mensajesOrdenados[index].body == 'Se ha generado un nuevo Incidente' ? Icon(Icons.assignment_late, size: 40.0, color: Theme.of(context).accentColor,) : Icon(Icons.question_answer, size: 40.0, color: Colors.yellow[900])),
                    onTap: () {
                      Navigator.push(context, 
                      MaterialPageRoute(builder: (context) => AgregarElementosBasico(cerrado :mensajesOrdenados[index].cerrado , mensaje: mensajesOrdenados[index].body,incidente: mensajesOrdenados[index].incidente, responsable: mensajesOrdenados[index].responsable, usuarioIncidente: mensajesOrdenados[index].userSend, incidentId: mensajesOrdenados[index].incidentId, nombreObra: mensajesOrdenados[index].nombreObra, threadId: mensajesOrdenados[index].threadId, parentMessageId:  mensajesOrdenados[index].parentMessageId, obraId: mensajesOrdenados[index].locationId, userIncidenteId: mensajesOrdenados[index].userId, userReportadoPor: mensajesOrdenados[index].userReportadoPor, messageId: mensajesOrdenados[index].messageId, userIdSend: mensajesOrdenados[index].userIdSend, tituloIncidente: mensajesOrdenados[index].tituloIncidente )));                             
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}