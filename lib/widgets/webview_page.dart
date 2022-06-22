import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:webview_flutter/webview_flutter.dart'; // flutter run -d chrome --web-renderer html  // flutter build web --web-renderer html --release


class WebViewPage extends StatefulWidget {
  
  final String url;

  WebViewPage({this.url});


  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
 
  bool isDarkMode;

   @override
   void initState() {

      var brightness = SchedulerBinding.instance.window.platformBrightness;
      isDarkMode = brightness == Brightness.dark;
      
      super.initState();
   }

  @override
  void dispose() {
    super.dispose();
  }

  bool isLoading = true;

  @override
  Widget build(BuildContext context) {

    if(!kIsWeb){
      return Material(
        color: Colors.white,
        type: MaterialType.transparency,
        child: Scaffold(
          appBar: AppBar(
          systemOverlayStyle: isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
          foregroundColor: Theme.of(context).iconTheme.color,
          backgroundColor: Colors.transparent,
          toolbarHeight: 40,
          elevation: 0,
          flexibleSpace: Container(
                  decoration: BoxDecoration(
                    //borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                    color: Theme.of(context).backgroundColor.withOpacity(1),
                  ),
              ),
          centerTitle: true,
          title: Text('DSA', style: TextStyle(color: Theme.of(context).iconTheme.color,)),
          ),
          body: WebView(initialUrl: widget.url, backgroundColor: Theme.of(context).backgroundColor,),
        ),
      );
    }
    /*else{

      return Scaffold(
              appBar: AppBar(
                toolbarHeight: 50,
                flexibleSpace: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromRGBO(100, 198, 214, 1),
                              Color.fromRGBO(0,152, 242, 1),
                            ],
                          ),
                          boxShadow: [
                            //background color of box
                            BoxShadow(
                              color: Color.fromRGBO(0, 50, 70, 1),
                              blurRadius: 5.0, // soften the shadow
                              spreadRadius: 1.0, //extend the shadow
                              offset: Offset(
                                0, // Move to right 10  horizontally
                                0, // Move to bottom 10 Vertically
                              ),
                            )
                          ],
                        ),
                    ),
                centerTitle: false,
                title: const Text('Aide'),
              ),
              body: Stack(
                children: <Widget>[
                  WebViewX(
                    initialContent: widget.url,
                    javascriptMode: JavascriptMode.unrestricted,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 1.05,
                    onPageFinished: (finish) {
                      setState(() {
                        isLoading = false;
                      });
                    },
                  ),
                  isLoading ? Center( child: CircularProgressIndicator(),)
                            : Stack(),
                ],
              ),
      );
    }*/
  }

  Future rateApp() async {

        final InAppReview inAppReview = InAppReview.instance;

        if (await inAppReview.isAvailable()) {
            inAppReview.requestReview();
            //inAppReview.openStoreListing(appStoreId: "375380948");
        }
  }
}