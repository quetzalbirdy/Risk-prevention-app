import 'package:flutter/material.dart';
import 'package:flutter_youtube/flutter_youtube.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:nuevo_riesgos/src/resources/constantes.dart' as constantes;

class InformacionPrevencionTest extends StatefulWidget {
  @override
  _InformacionPrevencionTestState createState() => _InformacionPrevencionTestState();
}

class _InformacionPrevencionTestState extends State<InformacionPrevencionTest> { 

  bool cargandoPagina;
  WebViewController _webController;    
  final urlServicios = constantes.urlBase;

  @override
  void initState() {
    super.initState();
    cargandoPagina = true;    
  }

  Future<bool> _exitApp(BuildContext context) async {
  if (await _webController.canGoBack()) {
    print("onwill goback");
    _webController.goBack();
  } else {
    Scaffold.of(context).showSnackBar(
      const SnackBar(content: Text("No back history item")),
    );
    return Future.value(false);
  }
}

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text('Documentos preventivos', style: TextStyle(
            fontSize: 17.0
          ),),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
             /*  if (await _webController.currentUrl() != 'http://$urlServicios/web/ebco-app-test/home') {
                _webController.loadUrl('http://$urlServicios/web/ebco-app-test/home');          
              } else {
                Navigator.pop(context);
              } */
              if (await _webController.canGoBack()) {                
                _webController.goBack();
              } else {
                Navigator.pop(context);
              }
            },
          ),
          /* actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              color: Colors.white, 
              onPressed: () {},
            )
          ], */
        ),
        body: Stack(
          children: <Widget>[
            WebView(
              initialUrl: 'http://$urlServicios/web/ebco-app-test/home',
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _webController = webViewController;              
              },
              onPageFinished: (finish) {
                setState(() {
                  cargandoPagina = false;                
                });
              },
            ),
            cargandoPagina == true ? Container(
              alignment: FractionalOffset.center,
              child: CircularProgressIndicator(),
            ) :
            Container(
              height: 0.0,
            ),
          ],
        ) ,      
        /* floatingActionButton: FloatingActionButton(
          onPressed: () {
            _webController.loadUrl('http://$urlServicios/web/ebco-app-test/home');              
          },
          child: Icon(Icons.arrow_back),
        ),  */   
      );
  }
}