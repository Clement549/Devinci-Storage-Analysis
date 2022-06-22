import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class ErrorScreen extends StatefulWidget {

  String lottie;

  ErrorScreen({
    this.lottie,
  });

  @override
  _ErrorScreenState createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen>{

  bool isDarkMode;

  @override
  void initState() {

    var brightness = SchedulerBinding.instance.window.platformBrightness;
    isDarkMode = brightness == Brightness.dark;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    if(widget.lottie == "shield"){

      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 0,
          backgroundColor: Theme.of(context).backgroundColor,
          foregroundColor: Theme.of(context).iconTheme.color,
          systemOverlayStyle: isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        ),
        body: 
        Container(
          width: double.infinity,
          color: Theme.of(context).backgroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset(
                "assets/shield.json",
                animate: true,
                height: 110,
              ), 
                Text("ACCESS DENIED", style: TextStyle(color: Theme.of(context).iconTheme.color, fontSize: 20,),),
                Container(
                  margin: const EdgeInsets.fromLTRB(50, 20, 50, 0),
                  child: Text("Our system detected you are either:" + "\n" +
                  "- Using a rooted device" + "\n" +
                  "- Using an emulator" + "\n" +
                  "- Using mock locations" + "\n" +
                  "- Running the app on the external storage" + "\n\n" +
                  "For safety reasons, we can't let you login until you fix these."
                  ,
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Theme.of(context).iconTheme.color, fontSize: 15,),),
                ),
          ],),
        ),
      );
    }
    else{

      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 0,
          backgroundColor: Theme.of(context).backgroundColor,
          foregroundColor: Theme.of(context).iconTheme.color,
          systemOverlayStyle: isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        ),
        body: 
        Container(
          width: double.infinity,
          color: Theme.of(context).backgroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset(
                "assets/maintenance.json",
                animate: true,
                height: 120,
              ), 
                Container(height: 20,),
                Text("SERVER MAINTENANCE", style: TextStyle(color: Theme.of(context).iconTheme.color, fontSize: 20,),),
                Container(
                  margin: const EdgeInsets.fromLTRB(50,20, 50, 0),
                  child: Text("Our team is working on the server. Please, come back later."
                  ,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).iconTheme.color, fontSize: 15,),),
                ),
          ],),
        ),
      );
    }
  }
}