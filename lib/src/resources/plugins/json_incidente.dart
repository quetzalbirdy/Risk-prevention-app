import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:intl/intl.dart';

class JsonIncidente extends StatefulWidget {
  const JsonIncidente({
    @required this.form,
    this.onChanged,
    this.padding,
    this.form_map,
  });

  final List<dynamic> form;
  final dynamic form_map;
  final double padding;
  final ValueChanged<dynamic> onChanged;

  @override
  _JsonIncidenteState createState() =>
      new _JsonIncidenteState(form_map ?? form);
}

class _JsonIncidenteState extends State<JsonIncidente> {
  final dynamic form_items;

  int radioValue;
  String dropValue;  
  String dropValue3;
  final format = DateFormat("dd-MM-yyyy - HH:mm");

  var estiloTitle = TextStyle(fontSize: 13.0, color: Colors.black, /* fontWeight: FontWeight.w700 */);
  var estiloDato = TextStyle(fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.w600);

  List<Widget> JsonToForm() {
    List<Widget> list_widget = new List<Widget>();
    /* final dynamic form_items = form_items; */

    for (var counter = 0; counter < form_items.length; counter++) {
      var form_item;
      if (form_items[counter] == null) {continue;}
      if (form_items[counter]['formPrincipal'] != null) {
        form_item = form_items[counter]['formPrincipal'];
      } else if (form_items[counter]['formAgregarInfo'] != null) {
        form_item = form_items[counter]['formAgregarInfo'];
      } else if (form_items[counter]['formComunicar'] != null) {
        form_item = form_items[counter]['formComunicar'];        
      } else if (form_items[counter]['formEstadoSolucion'] != null) {
        form_item = form_items[counter]['formEstadoSolucion'];
      } else if (form_items[counter]['formComplementar'] != null) {
        form_item = form_items[counter]['formComplementar'];
      }

      for (var count = 0; count < form_item.length; count++) {
        var item = form_item[count];        
        if (item['type'] == "Input") {
          list_widget.add(
            new Container(
              padding: EdgeInsets.only(top: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item['title'],
                    style: estiloTitle,
                  ),
                  Text(
                    item['response'],
                    style: estiloDato,
                  ),
                ],
              ),
            ),
          );
        }

        if (item['type'] == "FechaHora") {
          list_widget.add(Container(
            padding: EdgeInsets.only(top: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Fecha y Hora',
                  style: estiloTitle,
                ),
                Text(
                  item['response'],
                  style: estiloDato,
                ),
              ],
            ),
          ));
        }

        if (item['type'] == "Dropdown") {
          int value = int.parse(item['value']);
          list_widget.add(Container(
            padding: EdgeInsets.only(top: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item['title'],
                  style: estiloTitle,
                ),
                Text(
                  item['list'][value - 1]['title'],
                  style: estiloDato,
                ),
              ],
            ),
          ));
        }

        if (item['type'] == "DropdownComunicar") {
          int value = int.parse(item['value']);
          list_widget.add(Container(
            padding: EdgeInsets.only(top: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item['title'],
                  style: TextStyle(fontSize: 12.0, color: Colors.grey[700]),
                ),
                Text(
                  item['list'][value - 1]['title'],
                  style: estiloDato,
                ),
                Text(
                  'Mensaje',
                  style: TextStyle(fontSize: 12.0, color: Colors.grey[700]),
                ),
                Text(
                  item['response'],
                  style: estiloDato,
                ),
              ],
            ),
          ));
        }

        if (item['type'] == "TextArea") {
          list_widget.add(new Container(
            padding: EdgeInsets.only(top: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item['placeholder'],
                  style: estiloTitle,
                ),
                Text(
                  item['response'],
                  style: estiloDato,
                ),
              ],
            ),
          ));
        }

        /*  

        /* if (item['type'] == "RadioButton") {
          list_widget.add(new Container(
              margin: new EdgeInsets.only(top: 5.0, bottom: 5.0),
              child: new Text(item['title'],
                  style: new TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16.0))));
          radioValue = item['value'];
          for (var i = 0; i < item['list'].length; i++) {
            list_widget.add(new Row(children: <Widget>[
              new Expanded(
                  child: new Text(form_items[count]['list'][i]['title'])),
              new Radio<int>(
                  value: form_items[count]['list'][i]['value'],
                  groupValue: radioValue,
                  onChanged: (int value) {
                    this.setState(() {
                      radioValue = value;
                      form_items[count]['value'] = value;
                      _handleChanged();
                    });
                  })
            ]));
          }
        } */

        /* if (item['type'] == "Switch") {
          list_widget.add(
            new Row(children: <Widget>[
              new Expanded(child: new Text(item['title'])),
              new Switch(
                  value: item['switchValue'],
                  onChanged: (bool value) {
                    this.setState(() {
                      form_items[count]['switchValue'] = value;
                      _handleChanged();
                    });
                  })
            ]),
          );
        } */

        /* if (item['type'] == "Checkbox") {
          list_widget.add(new Container(
              margin: new EdgeInsets.only(top: 5.0, bottom: 5.0),
              child: new Text(item['title'],
                  style: TextStyle(color: Colors.white, fontSize: 20.0))));
          for (var i = 0; i < item['list'].length; i++) {
            list_widget.add(new Row(children: <Widget>[
              new Expanded(
                  child: new Text(form_items[count]['list'][i]['title'], style: TextStyle(color: Colors.white))),
              new Checkbox(
                  value: form_items[count]['list'][i]['value'],
                  onChanged: (bool value) {
                    this.setState(() {
                      form_items[count]['list'][i]['value'] = value;
                      _handleChanged();
                    });
                  })
            ]));
          }
        } */      

        if (item['type'] == "DropdownComunicar") {  
          _dropValue = (item['value'] != '')? item['value'] : null;
          list_widget.add(Padding(
            padding: EdgeInsets.only(top: 25.0),
            child: new Stack(
              children: <Widget>[
                new Positioned(
                  top: -3.0,
                  child: new Text(
                    item['title'],
                    style: new TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: Colors.red[800]
                  ),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: DropdownButton<String>(
                      value: _dropValue,
                      /* hint: Text('', style: TextStyle(color: Colors.grey[700]),), */
                      onChanged: (String valorNuevo) {
                        this.setState(() {                  
                          /* _dropValue = valorNuevo; */
                          form_items[count]['value'] = valorNuevo;
                          _handleChanged();
                        });
                      },
                      items: [
                        for (var i = 0; i<item['list'].length; i++) 
                          DropdownMenuItem<String>(
                            value: form_items[count]['list'][i]['value'].toString(),
                            child: Text(form_items[count]['list'][i]['title'].toString(), style: TextStyle(color: Colors.white),),
                          ),
                      ],              
                    ),
                  )
                ),
                item['value'] != "" ? 
                Container(
                  padding: EdgeInsets.only(top: 53.0, bottom: 10.0),             
                  child: TextFormField(
                    style: TextStyle(
                      color: Colors.white
                    ),
                    controller: null,
                    initialValue: form_items[count]['response'] != null ? form_items[count]['response'] : null,
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Comentario",
                      hintStyle: TextStyle(color: Colors.grey[700]),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).accentColor)
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).accentColor)
                      ), 
                    ),                  
                    onChanged: (String value) {
                      form_items[count]['response'] = value;
                      _handleChanged();
                    },                  
                  ),
                )
                :SizedBox(height: 0.0,)
              ]
            )
          ));
        } */

      }

      /* counter + 1 != form_items.length
          ? list_widget.add(Center(
              child: Divider(
                color: Colors.grey[800],
              ),
            ))
          : null; */
    }
    return list_widget;
  }

  _JsonIncidenteState(this.form_items);

  void _handleChanged() {
    widget.onChanged(form_items);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Container(
      /* padding: new EdgeInsets.all(widget.padding ?? 8.0), */
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: JsonToForm(),
      ),
    );
  }
}
