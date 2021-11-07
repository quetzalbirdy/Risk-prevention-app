import 'package:flutter/material.dart';
import 'package:animator/animator.dart';

class Cargando extends StatefulWidget {
  Cargando({
    Key key,
  }) : super(key: key);
  @override
  _CargandoState createState() => _CargandoState();
}

class _CargandoState extends State<Cargando> {
  @override 
  Widget build(BuildContext context) {
    return Animator<double>(
      resetAnimationOnRebuild: true,
      tween: Tween<double>(begin: 30, end: 70),
      duration: Duration(milliseconds: 500),
      curve: Curves.easeIn,
      cycles: 0,       
      triggerOnInit: true,
      builder: (context, anim, child) => Center(
        child: Icon(Icons.location_on, size: anim.value, color: Theme.of(context).accentColor,),
      ),
    );
  }
}