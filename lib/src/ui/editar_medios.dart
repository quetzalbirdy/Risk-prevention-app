import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nuevo_riesgos/src/resources/datos/medios.dart';
import 'package:nuevo_riesgos/src/resources/grabar_reproducir/reproductor_audio.dart';
import 'package:nuevo_riesgos/src/resources/grabar_reproducir/reproductor_video.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class EditarMedios extends StatefulWidget {
  final onDelete;
  EditarMedios({Key key, this.onDelete}) : super(key: key);

  @override
  _EditarMediosState createState() => _EditarMediosState();
}

class _EditarMediosState extends State<EditarMedios> {
  final videoHero = "videoTag";
  final audioHero = "audioTag";
  final listaPrueba = ['uno', 'dos', 'tres', 'cuatro'];     

  @override 
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(      
          backgroundColor: Colors.black,   
          centerTitle: true,
          elevation: 0,
          title: Padding(
            padding: EdgeInsets.only(left: 0.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Editando Medios en:', style: TextStyle(fontSize: 15.0),),
                Text('4TA AVENIDA CONQUISTA', style: TextStyle(fontSize: 15.0),)
              ],
            ),
          ),
          bottom: TabBar(
            labelColor: Colors.redAccent,
            unselectedLabelColor: Colors.white,
            indicatorSize: TabBarIndicatorSize.label,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5)
              ),
              color: Colors.white
            ),
            tabs: [
              Tab(
                child: Container(  
                  padding: EdgeInsets.only(top: 5.0),
                  width: 90.0,                           
                  child: Column(
                      children: <Widget>[
                        Icon(Icons.insert_photo),
                        Text('Fotos')
                      ],
                    )
                ),
              ),
              Tab(
                child: Container(    
                  padding: EdgeInsets.only(top: 5.0),
                  width: 90.0,              
                  child: Column(
                      children: <Widget>[
                        Icon(Icons.movie),
                        Text('Video')
                      ],
                    )
                ),
              ),
              Tab(
                child: Container(  
                  padding: EdgeInsets.only(top: 5.0),
                  width: 90.0,                
                  child: Column(
                      children: <Widget>[
                        Icon(Icons.mic),
                        Text('Audio')
                      ],
                    )
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [            
            Container(
              /* padding: EdgeInsets.only(top: 10.0, bottom: 10.0), */
              child: Medios().imageList != null ? StaggeredGridView.countBuilder(
                /* scrollDirection: Axis.vertical, */
                padding: EdgeInsets.all(10.0),
                crossAxisCount: 4,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                staggeredTileBuilder: (int index) => 
                  new StaggeredTile.fit(2),
                itemCount: Medios().imageList.length,                                  
                itemBuilder: (context, index) {
                  return new Stack(
                    alignment: Alignment.center,
                    children: <Widget>[                     
                      InkWell(
                      onTap: () {
                        return null;
                      },
                      child: Card(
                        color: Theme.of(context).accentColor,
                        child: Column(
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Image.file(File(Medios().imageList[index].path),),
                                /* Padding(
                                  padding: EdgeInsets.only(top: 0.0),
                                  child: TextField(                                        
                                    style: TextStyle(
                                      color: Colors.white
                                    ),
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 1,
                                    decoration: InputDecoration(
                                      hintText: "Comentario",
                                      hintStyle: TextStyle(color: Colors.red[100]),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Theme.of(context).primaryColor)
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Theme.of(context).primaryColor)
                                      ), 
                                    )
                                  ), 
                                )   */                                 
                              ],
                            )
                          ],
                        )
                      )),
                      FlatButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return SimpleDialog(
                                  backgroundColor: Colors.white,
                                  contentPadding: EdgeInsets.all(0),
                                  children: <Widget>[
                                    Image.file(Medios().imageList[index],),
                                    Center(
                                      child: IconButton(                                        
                                        icon: const Icon(Icons.close, color: Colors.black,),
                                        tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                                        onPressed: () {
                                          Navigator.maybePop(context);
                                        },
                                      ),
                                    )
                                  ],
                                );
                              }
                            );
                        },                        
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 0.0),
                          child: Opacity(                          
                            child: Icon(Icons.zoom_in, size: 100.0, color: Theme.of(context).primaryColor,),
                            opacity: 0.6,
                          )
                        ),
                        ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: SizedBox(
                          width: 25.0,
                          height: 25.0,
                          child: FloatingActionButton(
                            heroTag: index,
                            backgroundColor: Colors.black,
                            child: Icon(Icons.close, size: 15.0, color: Colors.white,),                          
                            onPressed: () {
                              setState(() {
                                Medios().imageList.removeAt(index);
                              });
                              widget.onDelete();
                            }
                          ),
                        )
                      )
                    ],
                  );
                }) : Text(''),
            ),  
            Container(              
              /* padding: EdgeInsets.only(top: 10.0, bottom: 10.0), */
              child: Medios().videoFiles.length > 0 ? StaggeredGridView.countBuilder(                
                /* scrollDirection: Axis.vertical, */
                padding: EdgeInsets.all(10.0),
                crossAxisCount: 4,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                staggeredTileBuilder: (int index) => 
                  new StaggeredTile.fit(2),
                itemCount: Medios().videoFiles.length,                                  
                itemBuilder: (context, index) {
                  return ReproductorVideo(
                    key: new ObjectKey(Medios().videoFiles[index]),
                    videoFile: Medios().videoFiles[index], 
                    index: index,
                    onRemove: () {
                      setState(() {
                        Medios().videoFiles.removeAt(index);  
                      });
                      widget.onDelete();
                    }
                  );
                }) : Text(''),
            ),                                    
            Container(              
              /* padding: EdgeInsets.only(top: 10.0, bottom: 10.0), */
              child: Medios().audioFiles.length > 0 ? ListView.builder(                
                /* scrollDirection: Axis.vertical, */
                padding: EdgeInsets.all(10.0),
                itemCount: Medios().audioFiles.length,                  
                /* gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, mainAxisSpacing: 5.0, crossAxisSpacing: 5.0), */
                itemBuilder: (context, index) {
                  return Stack(     
                    key: UniqueKey(),               
                    alignment: Alignment.center,
                    children: <Widget>[                     
                      Column(                                                
                        children: <Widget>[
                          Container(                                                  
                            child: SizedBox(
                              height: Medios().audioFiles.length < 1 ? 0.0 : 110.0,
                              child: ReproductorAudio(
                                audioFile: Medios().audioFiles[index], 
                                index: index,
                                onRemove: () {
                                  setState(() {
                                    Medios().audioFiles.removeAt(index);  
                                  });
                                  widget.onDelete();
                                }
                              ),                                
                            ),
                          ), 
                        ],
                      ),                
                                           
                    ],
                  );
                }) : Text(''),
            ),    
          ]
        ),
      ),
    );
  }
}

/* class EditarMedios extends StatelessWidget {
  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Padding(
          padding: EdgeInsets.only(left: 0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Editando Medios en:', style: TextStyle(fontSize: 15.0),),
              Text('4TA AVENIDA CONQUISTA', style: TextStyle(fontSize: 15.0),)
            ],
          ),
        )
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 2.0, left: 0.0, right: 0.0),
        child: ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      InkWell(
                      onTap: () {
                        return null;
                      },
                      child: Card(
                        color: Theme.of(context).accentColor,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              height: 103.0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset('imagenes/imagen1.jpg'),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(5.0),
                              width: 165.0,
                              child: TextField(
                                style: TextStyle(
                                  color: Colors.white
                                ),
                                keyboardType: TextInputType.multiline,
                                maxLines: 2,
                                decoration: InputDecoration(
                                  hintText: "Comentario",
                                  hintStyle: TextStyle(color: Colors.red[200]),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Theme.of(context).primaryColor)
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Theme.of(context).primaryColor)
                                  ), 
                                )
                              ),
                            )
                          ],
                        )
                      )),
                      Positioned(
                        top: 0.0,
                        right: 0.0,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle
                          ),
                          height: 20.0,
                          width: 20.0,
                          child: IconButton(
                            padding: EdgeInsets.all(0.0),
                            iconSize: 15.0,
                            color: Colors.black,
                            onPressed: () {
                              
                            },
                            icon: Icon(Icons.close),
                          ),
                        )),
                    ],
                  ),
                  Stack(
                    children: <Widget>[
                      InkWell(
                      onTap: () {
                        return null;
                      },
                      child: Card(
                        color: Theme.of(context).accentColor,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              height: 103.0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset('imagenes/imagen2.jpg'),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(5.0),
                              width: 165.0,
                              child: TextField(
                                style: TextStyle(
                                  color: Colors.white
                                ),
                                keyboardType: TextInputType.multiline,
                                maxLines: 2,
                                decoration: InputDecoration(
                                  hintText: "Comentario",
                                  hintStyle: TextStyle(color: Colors.red[200]),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Theme.of(context).primaryColor)
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Theme.of(context).primaryColor)
                                  ), 
                                )
                              ),
                            )
                          ],
                        )
                      )),
                      Positioned(
                        top: 0.0,
                        right: 0.0,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle
                          ),
                          height: 20.0,
                          width: 20.0,
                          child: IconButton(
                            padding: EdgeInsets.all(0.0),
                            iconSize: 15.0,
                            color: Colors.black,
                            onPressed: () {
                              
                            },
                            icon: Icon(Icons.close),
                          ),
                        )),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      InkWell(
                      onTap: () {
                        return null;
                      },
                      child: Card(
                        color: Theme.of(context).accentColor,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              height: 103.0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset('imagenes/imagen3.jpg'),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(5.0),
                              width: 165.0,
                              child: TextField(
                                style: TextStyle(
                                  color: Colors.white
                                ),
                                keyboardType: TextInputType.multiline,
                                maxLines: 2,
                                decoration: InputDecoration(
                                  hintText: "Comentario",
                                  hintStyle: TextStyle(color: Colors.red[200]),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Theme.of(context).primaryColor)
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Theme.of(context).primaryColor)
                                  ), 
                                )
                              ),
                            )
                          ],
                        )
                      )),
                      Positioned(
                        top: 0.0,
                        right: 0.0,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle
                          ),
                          height: 20.0,
                          width: 20.0,
                          child: IconButton(
                            padding: EdgeInsets.all(0.0),
                            iconSize: 15.0,
                            color: Colors.black,
                            onPressed: () {
                              
                            },
                            icon: Icon(Icons.close),
                          ),
                        )),
                    ],
                  ),
                ],
              )
            ],
          ),
        ],
        ),
      )
    );
  }
} */