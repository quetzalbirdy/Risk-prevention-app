import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

class BasicDateTimeField extends StatelessWidget {
  final format = DateFormat("dd-MM-yyyy - HH:mm");
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
      Stack(
        children: <Widget>[
          Positioned(
            top: -2.0,
            child: Text('Selecciona una Fecha y Hora', style: TextStyle(color: Colors.red[100]), textAlign: TextAlign.left,),
          ),
          DateTimeField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: Icon(FontAwesomeIcons.calendarAlt, color: Colors.white),
              hintText: DateTime.now().day.toString() + "/" + DateTime.now().month.toString() + "/" + DateTime.now().year.toString() + " - " + DateTime.now().hour.toString() + ":" + DateTime.now().minute.toString(),
              hintStyle: TextStyle(color: Colors.white, height: 1.5),
              // labelStyle: TextStyle(color: Colors.white),
              enabledBorder: UnderlineInputBorder(                          
                          borderSide: BorderSide(color: Theme.of(context).accentColor)
                        ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).accentColor)
              ),),
            format: format,
            onShowPicker: (context, currentValue) async {
              final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime(1900),
                  initialDate: currentValue ?? DateTime.now(),
                  lastDate: DateTime(2100));
              if (date != null) {
                final time = await showTimePicker(
                  context: context,
                  initialTime:
                      TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                );
                return DateTimeField.combine(date, time);
              } else {
                return currentValue;
              }
            },
          ),
        ],
      )
    ]);
  }
}