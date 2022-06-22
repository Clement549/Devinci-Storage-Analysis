//flutter build appbundle --release --target-platform=android-arm64   // android
//flutter build ipa   // ios

//firebase use <project_name>

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:fancy_on_boarding/fancy_on_boarding.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_course/main.dart';
import 'package:flutter_course/map_page_picker.dart';
import 'package:flutter_course/widgets/loading_screen.dart';
import 'package:flutter_course/widgets/map_menu.dart';
import 'package:flutter_course/widgets/rounded_button_widget.dart';
import 'package:flutter_recaptcha_v2/flutter_recaptcha_v2.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:googleapis/admob/v1.dart';
import 'package:googleapis/cloudresourcemanager/v1.dart';
import 'package:lottie/lottie.dart';
import 'package:ndialog/ndialog.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:particles_flutter/particles_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// WINDOWS ///
/*const firebaseOptions = FirebaseOptions(
    appId: String.fromEnvironment('FIREBASE_APP_ID'),
    apiKey: String.fromEnvironment('FIREBASE_API_KEY'),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
    messagingSenderId: String.fromEnvironment('FIREBASE_SENDER_ID'),
    authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
);*/
///////////////

class ConnexionPage extends StatefulWidget {

  bool hasInternet;
  ConnexionPage({this.hasInternet,});

  @override
  _ConnexionPageState createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> with WidgetsBindingObserver {

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  final storage = const FlutterSecureStorage();
  final storage_options = const IOSOptions(accessibility: IOSAccessibility.first_unlock);

  String popupTitle = "";
  String popupBody = "";
  String popupBtn = "";
  String popupLottie = "";
  double popupHeight = 70;

  final formKey = GlobalKey<FormState>();

  String selectedCommune = "";

  TextEditingController _emailController = TextEditingController();
  //TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  TextEditingController _emailControllerREGISTER = TextEditingController();
  TextEditingController _usernameControllerREGISTER = TextEditingController();
  TextEditingController _passwordControllerREGISTER = TextEditingController();

  bool signup = false;

  Future<bool> _loadCommunes;

  bool isLoading = false;

  StreamSubscription subscription; // check internet
  //bool maintenance = false;
  bool ingoreFirstConnection = false;

  @override
  void initState() {

    WidgetsBinding.instance.addObserver(this); // detect app go background / close
    super.initState();

    _loadCommunes = loadCommunes();

    subscription = Connectivity().onConnectivityChanged.listen(showConnectivityBar);

    if(!kIsWeb) recaptchaV2Controller.show();

    /*_videoController = VideoPlayerController.asset(
        'assets/menu.mp4')
        ..initialize().then((_) {
          _videoController.setLooping(true);
          _videoController.setVolume(0.0);
          Timer(const Duration(milliseconds: 100), () {
            setState(() {
              _videoController.play();
        });
      });
    });*/

    //player.setFilePath("assets/two_feet.mp3");
    //player.play();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state){ // check app go background / resume
    super.didChangeAppLifecycleState(state);

    if(state == AppLifecycleState.inactive || state == AppLifecycleState.detached) return;

    final isBackground = state == AppLifecycleState.paused;

    if(isBackground){
      log("app in background");
    }
    else{
      log("app in foreground");
    }
  }
  @override
  void dispose() {
    //recaptchaV2Controller.dispose();
    super.dispose();
  }

List<String> communes = [];
List<String> passwords = [];

Future<bool> loadCommunes() async {

  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult != ConnectivityResult.none) {

    communes = [];

   if (this.mounted){

        await FirebaseFirestore.instance.collection("communes").orderBy('nom', descending: false).get().then((querySnapshot) {
                    querySnapshot.docs.forEach((result) {
                          if(!communes.contains(result.data()["nom"])){

                            if (this.mounted){
                              setState((){
                                communes.add(result.data()["nom"]);
                                passwords.add(result.data()["mdp"]);
                              });
                            }
                          }
                    });
        });      

      /*await FirebaseFirestore.instance.collection("server").get().then((querySnapshot) {
                    querySnapshot.docs.forEach((result) {
                        maintenance = result.data()["maintenance"];
                    });
      });*/
   }

    if(communes != null && communes.length > 0)
    selectedCommune = communes[0];

    return Future<bool>.value(false);
  }
  else{

    if(communes.length < 1){

        communes.add("Erreur de Connexion");
    }

    return Future<bool>.value(true);
  }
}

void showConnectivityBar(ConnectivityResult result) async {

    if(!kIsWeb){

          if(Platform.isWindows){

            //await Firebase.initializeApp(options: firebaseOptions);
          }
          else{

            await Firebase.initializeApp();

            FirebaseMessaging messaging = FirebaseMessaging.instance;
            NotificationSettings settings = await messaging.requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
            );
          }

          userCredential = await FirebaseAuth.instance.signInAnonymously();

          loadCommunes();
    }
  }

RecaptchaV2Controller recaptchaV2Controller = RecaptchaV2Controller();

@override
  Widget build(BuildContext context) =>
    isLoading ? LoadingScreen()
    : Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: DoubleBackToCloseApp(
        child:   Container(
        color: Colors.black,
        child:Center(
          child: Stack(
            children: [

              Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                  fit: BoxFit.cover,
                              colorFilter: 
                  ColorFilter.mode(Colors.black.withOpacity(0.5), 
                  BlendMode.dstATop),
                  image: const AssetImage(
                    'assets/bck1.jpg',
                    
                  ),
               ))), 

               CircularParticle(
                      // key: UniqueKey(),
                      awayRadius: 150,
                      numberOfParticles: 50,
                      speedOfParticles: 1,
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      onTapAnimation: true,
                      particleColor: Colors.white.withAlpha(120),
                      awayAnimationDuration: const Duration(milliseconds: 600),
                      maxParticleSize: 3,
                      isRandSize: true,
                      isRandomColor: true,
                      randColorList: [
                        Colors.red.withAlpha(150),
                        Colors.white.withAlpha(150),
                        Colors.yellow.withAlpha(150),
                        Colors.green.withAlpha(150)
                      ],
                      awayAnimationCurve: Curves.easeInOutBack,
                      enableHover: true,
                      hoverColor: Colors.white,
                      hoverRadius: 120,
                      connectDots: true, //not recommended
                    ),


              if(signup == false)
              Column(

                children: [

                  Container(height: MediaQuery.of(context).size.height / 5 ),
                 
                  Container(
                          height: 120,
                          margin: const EdgeInsets.fromLTRB(30, 40, 30, 20),
                          child: Opacity( 
                            opacity: 0.9,
                              child:Image.asset(
                                "assets/dsa_logo.png",
                              ),
                          ),
                        ),
                Form(
                    key: formKey,
                    child: Column(
                      children:[

                      GlassContainer(
                        height: 50,
                        blur: 3,
                        shadowStrength: 10,
                        opacity: 0.2,
                        width: 230,
                        //--code to remove border
                        border: const Border.fromBorderSide(BorderSide.none),
                        child: Theme(
                          data: ThemeData(
                            textTheme: const TextTheme(subtitle1: TextStyle(color: Colors.white)),
                          ),
                        child: FutureBuilder<bool>(
                        future: _loadCommunes,
                        builder: (context, snapshot) {
                          if(snapshot.hasData){
                            return DropdownSearch<String>(
                              mode: Mode.MENU,
                              showSelectedItems: true,
                              //showClearButton: true,
                              //showSearchBox: true,
                              items: communes,
                              //popupItemDisabled: (String s) => s.startsWith('I'),
                              onChanged: (item) => selectedCommune = item,
                              selectedItem: communes[0],
                              popupBackgroundColor: Colors.transparent.withOpacity(0.3),
                              popupBarrierColor: Colors.black26,
                            );
                          }
                          else if(snapshot.hasError){
                            return Icon(Icons.wifi_off, color: Colors.white);
                          }
                          else{
                              return Center(child:  SizedBox(
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2,),
                                  height: 35.0,
                                  width: 35.0,
                                ));
                          }
                          }),
                      )),
   
                       Container(height: 20,),

                       MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child:GestureDetector(
                         onTap: () async {  

                           if(!kIsWeb)recaptchaV2Controller.show();

                            var connectivityResult = await (Connectivity().checkConnectivity());
                            if (connectivityResult != ConnectivityResult.none) {

                              //if(maintenance == false){
                              
                                final isValid = formKey.currentState.validate();
                                FocusScope.of(context).unfocus();
                                if(isValid){

                                  if(selectedCommune != ""){

                                      //final SharedPreferences prefs = await _prefs;
                                      //await prefs.clear();
                                      await storage.deleteAll();

                                      String _captcha = await storage.read(key: "captcha");

                                          if(_captcha != "true" && !kIsWeb){
                                      
                                          await NDialog(
                                              dialogStyle: DialogStyle(titleDivider: true, contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0), backgroundColor: Colors.white),
                                              title: const Text("Vérification.", style: TextStyle(color: Color.fromRGBO(10,10,10,1))),
                                              content: 
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(5.0),
                                                  child: Container(
                                                  color: Colors.transparent,
                                                  height: 500,
                                                  width: 330,
                                                  child: RecaptchaV2(
                                                  apiKey: "6LdUhIseAAAAAMNsdChUd8tv5g2LOJscfuUvzeMm", // for enabling the reCaptcha
                                                  apiSecret: "6LdUhIseAAAAACtWtEdXqYrhGGxv2T0CQLtlzhew", // for verifying the responded token
                                                  controller: recaptchaV2Controller,
                                                  onVerifiedError: (err){
                                                    log(err);
                                                  },
                                                  onVerifiedSuccessfully: (success) async {

                                                      if(success){

                                                          await storage.write(key: "topic", value: selectedCommune);
                                                          await storage.write(key: "captcha", value: "true");
 
                                                          await Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) =>  MenuPage(commune: selectedCommune)));
                                                      }
                                                      else{

                                                        log("Failed");
                                                      }
                                                  },
                                                ))),
                                              actions: <Widget>[
                                                FlatButton(child: Text("Retour"),onPressed: () {Navigator.pop(context);}),
                                              ],
                                            ).show(context);

                                          }
                                          else{

                                            await storage.write(key: "topic", value: selectedCommune);

                                            await Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) =>  MenuPage(commune: selectedCommune)));
                                          }
                                  }
                                }
                              //}
                            }
                            else{


                            }
                        },
                        child: GlassContainer(
                                    height: 50,
                                    blur: 3,
                                    shadowStrength: 10,
                                    opacity: 0.2,
                                    width: 150,
                                    //--code to remove border
                                    border: const Border.fromBorderSide(BorderSide.none),
                                    borderRadius: BorderRadius.circular(20),
                                    child:const  Center(
                                      child: Text(
                                        "Se Connecter",
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                    ),
                                  ),
                        )),
                      ],
                    ),
                  ),
                  /*Container(height: 10,),
                  Row( 
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children:[
                          Container( // Draw Line
                            width: 80,
                            height: 1,
                            color: Colors.white,
                          ),
                          Container(
                          margin: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                          child: const Text(
                            "Admin",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          Container( // Draw Line
                            width: 80,
                            height: 1,
                            color: Colors.white,
                          ),
                  ]),

              

              Container(
                margin: const EdgeInsets.fromLTRB(50, 0, 50, 10),
                child: TextButton(
                  style: TextButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, fontStyle: FontStyle.italic),
                      primary: Colors.white,
                  ),
                  child: const Text("Connexion administrateur"),
                  onPressed: () async {

                    setState(() {
                       signup = true;
                    });
                  },
                ),
              ), */
              
            ],
          ),
          if(signup == true)
          ListView(
                //mainAxisAlignment: MainAxisAlignment.center,
                //crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  Container(height: MediaQuery.of(context).size.height / 1 ),
                 
                  Container(
                          height: 60,
                          margin: const EdgeInsets.fromLTRB(30, 50, 30, 30),
                          child: Image.asset(
                              "assets/splash.png",
                          ),
                        ),
                Form(
                    key: formKey,
                    child: Column(
                      children:[
                        
                        
                        GlassContainer(
                        //margin: const EdgeInsets.fromLTRB(50, 5, 50, 5),
                        height: 50,
                        //alignment: Alignment.center,
                        
                        /*decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.99),
                          borderRadius: const BorderRadius.all(Radius.circular(5)),
                        ),*/
                        blur: 3,
                        shadowStrength: 10,
                        opacity: 0.2,
                        border: Border.fromBorderSide(BorderSide.none),
                        borderRadius: BorderRadius.circular(10),

                        child: DropdownSearch<String>(
                          mode: Mode.MENU,
                          showSelectedItems: true,
                          items: communes,
                          //popupItemDisabled: (String s) => s.startsWith('I'),
                          onChanged: (item) => selectedCommune = item,
                          //selectedItem: communes[0],
                          popupBackgroundColor: Colors.white.withOpacity(0.9),
                          popupBarrierColor: Colors.black12,
                          
                        ),
                      ),

                          Container(
                            height: 68,
                            margin: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                            child: TextFormField(
                              obscureText: true,
                              controller: _passwordControllerREGISTER,
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                labelText: "Mot de passe",
                                labelStyle: const TextStyle(color: Colors.black87),
                                fillColor: Colors.white.withOpacity(0.99), filled: true,

                                focusedBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                  borderSide: BorderSide(width: 1,color: Colors.blueAccent),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                  borderSide: BorderSide(width: 1,color: Colors.black),
                                ),
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                  borderSide: BorderSide(width: 1,)
                                ),
                                errorBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                  borderSide: BorderSide(width: 1,color: Colors.redAccent)
                                ),
                                focusedErrorBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(4)),
                                  borderSide: BorderSide(width: 1.5,color: Colors.redAccent)
                                ),
                                /*
                                hintStyle: TextStyle(
                                  color: Colors.blueAccent,
                                ),*/
                              ),
                              maxLength: 20,
                              keyboardType: TextInputType.visiblePassword,
                              autofillHints: [AutofillHints.password],
                              validator: (value){

                              final pattern = r'^[a-zA-Z0-9&$#!=_\-\?]+$';
                              final regExp = RegExp(pattern);

                              if(value.length < 6){
                                return 'Entrez au moins 6 caractères.';
                              }
                              else if(!regExp.hasMatch(value)){

                                 return "Caractères non autorisés.";
                              }
                              else{
                                return null;
                              }
                            },
                            ),
                        ),

                        Container(
                          margin: const EdgeInsets.fromLTRB(30, 10, 30, 0),
                          alignment: Alignment.center,
                          child: RoundedButtonWidget(buttonText: " Se connecter ", width: 60, 
                            onpressed: () async {  
                              // ADMIN
                              final isValid = formKey.currentState.validate();
                              FocusScope.of(context).unfocus();
                              if(isValid){
                                if(selectedCommune != ""){

                                  int i = communes.indexOf(selectedCommune);

                                  if(passwords[i] == _passwordControllerREGISTER.text){
                                
                                    final SharedPreferences prefs = await _prefs;
                                    setState(() {
                                      prefs.setString("topic", selectedCommune);
                                      prefs.setString("captcha", "true");
                                    });

                                     await Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) =>  MenuPage(commune: selectedCommune)));
                                  }
                                  else{

                                    popupTitle = "Erreur";
                                    popupBody = "Mot de passe Incorrect.";
                                    popupBtn = "OK";
                                    popupLottie="assets/error.json";
                                    popupHeight = 70;

                                    await showCupertinoDialog(
                                      context: context, 
                                      builder: createMessage
                                    ); 
                                  }
                                }
                              }
                            },
                          ),
                        ),

                     /*    Container(
                          margin: const EdgeInsets.fromLTRB(50, 0, 50, 10),
                          child: TextButton(
                            style: TextButton.styleFrom(
                                 textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, fontStyle: FontStyle.italic),
                                 primary: Colors.white,
                            ),
                            child: const Text("Mot de passe oublié ?"),
                            onPressed: () async {

                              final isYes = await showCupertinoDialog(
                                  context: context, 
                                  builder: createDialog
                              ); 

                              if(isYes){

                                popupTitle = "Email envoyé !";
                                popupBody = "You can check your emails.";
                                popupBtn = "Open emails";
                                popupLottie="assets/success.json";
                                popupHeight = 70;

                                final isYes2 = await showCupertinoDialog(
                                  context: context, 
                                  builder: createMessage
                               ); 

                                if(isYes2){

                                }
                              }

                            },
                          ),
                        ),    */

                        Container(
                          margin: const EdgeInsets.fromLTRB(50, 0, 50, 10),
                          child: TextButton(
                            style: TextButton.styleFrom(
                                 textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, fontStyle: FontStyle.italic),
                                 primary: Colors.white,
                            ),
                            child: const Text("Retour"),
                            onPressed: () async {

                              setState(() {
                                 signup = false;
                              });
                            },
                          ),
                        )
                      ],
                    ),
                  ),           
            ],
          ),

        ]),
        ),
      ),
        snackBar: SnackBar(
        backgroundColor: Theme.of(context).backgroundColor,
        content: Text('Appuyez encore pour quitter.', style: TextStyle(color: Theme.of(context).iconTheme.color)),
      ),
    ));


 Widget createDialog(BuildContext context) => CupertinoAlertDialog(
         title: const Text("Forgot Password", style: TextStyle(fontSize:18)),
         content: Column(
           children: [
             Lottie.asset(
              "assets/plane.json",
              animate: true,
              height: 80,
             ), 
             const Text("Do you want to receive an email to change your password ?", style: TextStyle(fontSize:16)),
           ],
         ),
         actions: [
           CupertinoDialogAction(
             child: const Text("No"),
             onPressed: () => Navigator.pop(context,false),
           ),
           CupertinoDialogAction(
             child: const Text("Yes"),
             onPressed: () => Navigator.pop(context,true),
           ),
         ],
  );

   Widget createMessage(BuildContext context) => CupertinoAlertDialog(
         title: Text(popupTitle, style: TextStyle(fontSize:18)),
         content: Column(
           children: [
             Lottie.asset(
              popupLottie,
              animate: true,
              height: popupHeight,
             ), 
             Text(popupBody, style: TextStyle(fontSize:16)),
           ],
         ),
         actions: [
           CupertinoDialogAction(
             child: Text(popupBtn),
             onPressed: () => Navigator.pop(context,true),
           ),
         ],
  );
}