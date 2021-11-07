library json_to_form;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:nuevo_riesgos/src/resources/datos/datos_usuario.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CoreForm extends StatefulWidget {
  const CoreForm({
    @required this.form,
    @required this.onChanged,
    this.padding,
    this.form_map,
  });

  final String form;
  final dynamic form_map;
  final double padding;
  final ValueChanged<dynamic> onChanged;

  @override
  _CoreFormState createState() =>
      new _CoreFormState(form_map ?? json.decode(form));
}

class _CoreFormState extends State<CoreForm> {
  final dynamic form_items;

  int radioValue;
  String dropValue;
  String _dropValue;
  String dropValue3;
  final format = DateFormat("dd-MM-yyyy - HH:mm");

  final double kMinInteractiveDimension = 50.0;

  var estiloTitle = TextStyle(fontSize: 13.0, color: Colors.black, /* fontWeight: FontWeight.w700 */);
  var estiloDato = TextStyle(fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.w600);

  void _mostrarDialogValidacion(texto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(          
          content: Text(texto),
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

  List<Widget> JsonToForm() {
    List<Widget> list_widget = new List<Widget>();

    for (var count = 0; count < form_items.length; count++) {
      Map item = form_items[count];      

      if (item['type'] == "Input" ||
          item['type'] == "Password" ||
          item['type'] == "Email") {
            print(item['alturalinea']);
      print(item[count]);
        list_widget.add(Padding(
          padding: EdgeInsets.symmetric(vertical: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(bottom: 5.0, left: 2.0),
                  child: Text(
                    item['placeholder'] == "" ? item['title'] : "",
                    style: estiloTitle,
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 0,
                          blurRadius: 4,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                ),
                child: TextFormField(
                  style: estiloDato,                  
                  controller: null,
                  initialValue: item['response'] != null ? item['response'] : null,                    
                  decoration: new InputDecoration(            
                    /* labelText: 'Rellena el campo', */                  
                    hintText: 'Rellenar el campo',
                    hintStyle: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w400),
                    labelStyle: estiloTitle,
                    fillColor: Colors.white, 
                    filled: true,               
                    border: InputBorder.none,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent, width: 0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.transparent, width: 0),
                    ), 
                  ),
                  maxLines: item['alturalinea'] == 3 ? 3 : 1,
                  onChanged: (String value) {
                    item['response'] = value;
                    print('response');
                    print(item['response']);
                    _handleChanged();
                  },
                  obscureText: item['type'] == "Password" ? true : false,
                ),
              ),
            ],
          ),
        ));
      }

      if (item['type'] == "FechaHora") {
        form_items[count]['response'] = form_items[count]['response'] == null ? DateFormat("dd-MM-yyyy - HH:mm").format(DateTime.now()) : DatosUsuario().fechaIncidente;
        DatosUsuario().fechaIncidente = (DatosUsuario().fechaIncidente == null) ? form_items[count]['response'] : form_items[count]['response'];
        list_widget.add(Padding(          
          padding: EdgeInsets.symmetric(vertical: 5.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0, left: 2.0),
                child: Text(
                  'Fecha y Hora',
                  style: estiloTitle,
                ),
              ),
            Padding(
              padding: EdgeInsets.only(top: 0.0, bottom: 0.0),
              child: Stack(
                children: <Widget>[                 
                  Container(
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
                    borderRadius: BorderRadius.circular(10)),
                    child: DateTimeField(                         
                      style: estiloDato,
                      decoration: InputDecoration(
                        suffixIcon: Icon(FontAwesomeIcons.calendarAlt, color: Colors.black),
                        /* prefixIcon: Icon(FontAwesomeIcons.calendarAlt, color: Colors.black), */
                        hintText: DatosUsuario().fechaIncidente,
                        //DateTime.now().day.toString() + "-" + DateTime.now().month.toString() + "-" + DateTime.now().year.toString() + " - " + DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString(),
                        hintStyle: TextStyle(color: Colors.black, height: 1.5),
                        // labelStyle: TextStyle(color: Colors.black),
                        enabledBorder: UnderlineInputBorder(                          
                                    borderSide: BorderSide(color: Colors.transparent, width: 1.5)
                                  ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 0)
                        ),),
                      format: format,                                                            
                      onShowPicker: (context, currentValue) async {
                        var date = await showDatePicker(
                            context: context,
                            firstDate: DateTime(1900),
                            initialDate: currentValue ?? DateTime.now(),
                            lastDate: DateTime(2100));                        
                        if (date != null) {
                          var time = await showTimePicker(
                            context: context,
                            initialTime:
                                TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                          );
                          form_items[count]['response'] = DateFormat("dd-MM-yyyy - HH:mm").format(DateTimeField.combine(date, time));                          
                          return DateTimeField.combine(date, time);
                        } else {
                          return currentValue;
                        }
                      },
                      onChanged: (dynamic value) {                                                              
                        if (DateTime.now().difference(value).isNegative) {
                          _mostrarDialogValidacion('Asegúrate que la fecha y hora sean anterior o igual al momento actual');
                        }                                                 
                        form_items[count]['response'] = DateFormat("dd-MM-yyyy - HH:mm").format(value);
                        DatosUsuario().fechaIncidente = form_items[count]['response'];
                        _handleChanged();                      
                      },
                    ),
                  ),
                ],
              )
            )
          ]),
        ));
      }

      if (item['type'] == "TextArea") {
        list_widget.add(Padding(          
          padding: EdgeInsets.symmetric(vertical: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0, left: 2.0),
                child: Text(
                  item['placeholder'],
                  style: estiloTitle,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 0,
                          blurRadius: 4,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                  ],
                ),
                child: new TextFormField(
                  style: estiloDato,                                                  
                  decoration: new InputDecoration(  
                    fillColor: Colors.white,              
                    border: InputBorder.none,
                    filled: true,        
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent, width: 0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.transparent, width: 0),
                    ), 
                    hintText: item['placeholder'],
                    hintStyle: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w400)
                  ),
                  initialValue: form_items[count]['response'] != null ? form_items[count]['response'] : null,
                  maxLines: 3,          
                  onChanged: (String value) {
                    form_items[count]['response'] = value;
                    _handleChanged();
                  },
                ),
              ),
            ],
          ),
        ));
      }

      if (item['type'] == "RadioButton") {
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
      }

      if (item['type'] == "Switch") {
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
      }

      if (item['type'] == "Checkbox") {
        list_widget.add(new Container(
            margin: new EdgeInsets.only(top: 5.0, bottom: 5.0),
            child: new Text(item['title'],
                style: TextStyle(color: Colors.black, fontSize: 20.0))));
        for (var i = 0; i < item['list'].length; i++) {
          list_widget.add(new Row(children: <Widget>[
            new Expanded(
                child: new Text(form_items[count]['list'][i]['title'], style: TextStyle(color: Colors.black))),
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
      }

      if (item['type'] == "Dropdown") {  
        _dropValue = (item['value'] != '')? item['value'] : null;
        list_widget.add(Padding(
          padding: EdgeInsets.symmetric(vertical: 5.0),
          child: new Stack(
            children: <Widget>[
              /* new Positioned(
                top: -2.0,
                child: new Text(
                  item['title'],
                  style: estiloTitle,
                ),
              ), */
              Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: Colors.white
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5.0, left: 2.0),
                      child: Text(
                        item['title'],
                        style: estiloTitle,
                      ),
                    ),
                    Container(
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
                        /* isDense: true, */
                        /* itemHeight: 48, */                      
                        icon: Icon(Icons.keyboard_arrow_down),                        
                        isExpanded: true,                
                        hint: FittedBox(child: Text('Selecciona una opción', style: TextStyle(fontSize: 15.0),), fit: BoxFit.contain,),                    
                        /* decoration: InputDecoration(
                          /* contentPadding: EdgeInsets.all(0.0), */
                          enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black))),   */                
                        /* underline: Container(
                          height: 0.5,
                          color: Colors.black,
                        ), */
                        underline: Container(height: 0.0),
                        
                        value: _dropValue,                    
                        /* hint: Text('', style: TextStyle(color: Colors.grey[800]),), */
                        onChanged: (String valorNuevo) async {
                          this.setState(() {                                          
                            form_items[count]['value'] = valorNuevo;   
                            if (form_items[count]['title'] == 'Gravedad') {
                              DatosUsuario().gravedad = 2 - (int.parse(valorNuevo)-1);
                              print(DatosUsuario().gravedad);  
                            }
                            if (form_items[count]['title'] == 'Tipo de incidente') {
                              DatosUsuario().tipoIncidente = (int.parse(valorNuevo));
                              print(DatosUsuario().tipoIncidente);  
                            }
                          });
                          _handleChanged();
                        },
                        
                        items: [
                          for (var i = 0; i<item['list'].length; i++) 
                            DropdownMenuItem<String>(                                                    
                              value: form_items[count]['list'][i]['value'].toString(),
                              child: Text(form_items[count]['list'][i]['title'].toString(), style: estiloDato,),
                            ),
                        ],              
                      ),
                    ),
                  ],
                )
              ),
              /* item['value'] == '11' ? Container(
                padding: EdgeInsets.only(top: 33.0, bottom: 10.0),             
                child: TextField(
                  style: TextStyle(
                    color: Colors.black
                  ),
                  controller: null,
                  decoration: new InputDecoration(
                    labelText: 'Descripción del tipo de incidente',
                    labelStyle: TextStyle(color: Colors.grey[800]),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)
                    ), 
                  ),
                  maxLines: item['alturalinea'] == 3 ? 3 : 1,
                  onChanged: (String value) {
                    form_items[count]['list'][10]['title'] = value;
                    print(form_items[count]['list'][10]['title']);
                    _handleChanged();
                  },
                  obscureText: item['type'] == "Password" ? true : false,
                ),
              ):SizedBox(height: 0.0,) */
            ]
          )
        ));
      }

      if (item['type'] == "DropdownComunicar") {  
        _dropValue = (item['value'] != '')? item['value'] : null;
        list_widget.add(Padding(
          padding: EdgeInsets.only(top: 25.0),
          child: new Stack(
            children: <Widget>[
              new Positioned(
                top: -2.0,
                child: new Text(
                  item['title'],
                  style: estiloTitle,
                ),
              ),
              Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: Colors.grey[200]
                ),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: DropdownButton<String>(
                    value: _dropValue,
                    /* hint: Text('', style: TextStyle(color: Colors.grey[800]),), */
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
                          child: Text(form_items[count]['list'][i]['title'].toString(), style: TextStyle(color: Colors.black),),
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
                    color: Colors.black
                  ),
                  controller: null,
                  initialValue: form_items[count]['response'] != null ? form_items[count]['response'] : null,
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Comentario",
                    hintStyle: TextStyle(color: Colors.grey[800]),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)
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
      }

    }
    return list_widget;
  }

  _CoreFormState(this.form_items);

  void _handleChanged() {
    widget.onChanged(form_items);
  }

  @override
  Widget build(BuildContext context) {    
    return new Container(
      /* padding: new EdgeInsets.all(widget.padding ?? 8.0), */
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: JsonToForm(),
      ),
    );
  }
}
