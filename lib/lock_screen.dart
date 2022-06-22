import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_course/main.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lottie/lottie.dart';

class LockScreen extends StatefulWidget {

  @override
  _LockScreenState createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen>{

  bool isDarkMode;

  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {

    var brightness = SchedulerBinding.instance.window.platformBrightness;
    isDarkMode = brightness == Brightness.dark;

    //Auth();

    super.initState();
  }

  Future Auth() async {

        bool didAuthenticate = await auth.authenticate(
          localizedReason:
              'Scan your fingerprint (or face or whatever) to authenticate',
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true);

    if(didAuthenticate == true){

      setState(() {
    //  AuthenticationWrapper().isLocked = false;
      });
    }
    else{
      setState(() {
     //   AuthenticationWrapper().isLocked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

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
                Text("LOCKED", style: TextStyle(color: Theme.of(context).iconTheme.color, fontSize: 20,),),
                Container(
                  margin: const EdgeInsets.fromLTRB(50, 20, 50, 0),
                  child: Text("Prove your identity.",
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Theme.of(context).iconTheme.color, fontSize: 15,),),
                ),
                TextButton(   
                  onPressed: () async { 

                     await Auth();
                  },
                  child: Text('TextButton'),
                )
          ],),
        ),
      );
    }
  }