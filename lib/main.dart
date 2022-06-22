//flutter build appbundle --release --target-platform=android-arm64
//flutter build appbundle --target-platform android-arm64 --obfuscate --split-debug-info=/<directory>

//  cd android   ./gradlew signingReport     // debugUnitTest
//SHA1: 15:98:B6:4B:AC:AE:E5:FC:34:4A:C5:65:93:7C:0B:65:AD:B3:0C:61
//SHA-256: CF:29:FF:9B:5F:8E:3D:43:98:B2:BD:2E:55:50:AD:8E:B8:9B:41:AC:EB:7B:03:21:DE:85:7C:E0:8D:6C:3D:B2

//dart pub outdated

//flutter pub cache repair
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_course/connexion_page.dart';
import 'package:flutter_course/const/manager.dart';
import 'package:flutter_course/error_screen.dart';
import 'package:flutter_course/lock_screen.dart';
import 'package:flutter_course/map_page_picker.dart';
import 'package:flutter_course/map_page_picker_web.dart';
import 'package:flutter_course/onboarding_screen.dart';
import 'package:flutter_course/providers/theme_provider.dart';
import 'package:flutter_course/widgets/loading_screen.dart';
import 'package:flutter_course/widgets/map_menu.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_course/local_notification_service.dart';
import 'package:flutter_course/messaging.dart';
import 'package:flutter_course/models/config.dart';
import 'package:flutter_course/models/capteur.dart';
import 'package:flutter_course/models/utils.dart';
import 'package:flutter_course/widgets/shimmer_widget.dart';
import 'package:flutter_course/widgets/webview_page.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:safe_device/safe_device.dart';
import 'package:secure_application/secure_application.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb; // flutter run -d chrome --web-renderer html  // flutter build web --web-renderer html --release
import 'package:flutter_native_splash/flutter_native_splash.dart';


String commune = "none";  //saved in prefs
Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

const storage = FlutterSecureStorage();
const storage_options = IOSOptions(accessibility: IOSAccessibility.first_unlock);

String error_reason = "shield";

UserCredential userCredential = null;

/// WINDOWS ///
const firebaseOptions = FirebaseOptions(
    appId: String.fromEnvironment('FIREBASE_APP_ID'),
    apiKey: String.fromEnvironment('FIREBASE_API_KEY'),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
    messagingSenderId: String.fromEnvironment('FIREBASE_SENDER_ID'),
    authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
);
///////////////

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.removeAfter(initialization);

  SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
  ]);

  if(!kIsWeb){

    var brightness = SchedulerBinding.instance.window.platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    if (Platform.isAndroid) {

       AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );

      if(isDarkMode){
      
          SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle (
            systemNavigationBarColor: Color.fromRGBO(10, 10, 10, 1), // navigation bar color // 0xff + 6 digits hex
            systemNavigationBarIconBrightness: Brightness.light,
            statusBarColor: Colors.transparent, // status bar color
            systemNavigationBarDividerColor: Colors.transparent,//Navigation bar divider color
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.light,
          ));
      }
      else{

        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle (
            systemNavigationBarColor: Color.fromRGBO(245, 245, 245, 1), // navigation bar color // 0xff + 6 digits hex
            systemNavigationBarIconBrightness: Brightness.dark,
            statusBarColor: Colors.transparent, // status bar color
            systemNavigationBarDividerColor: Colors.transparent,//Navigation bar divider color
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.dark,
          ));
      }

      //SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge); // hide nav/top bars  
    }
  }
  
  configLoading(); // loading indicator init

  bool hasInternet = false;
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult != ConnectivityResult.none) {

      hasInternet = true;

      //if(!Platform.isWindows){

        await Firebase.initializeApp();
        //FirebaseCrashlytics.instance.crash();

        if(!kIsWeb){

          await FirebaseAppCheck.instance.activate(
            webRecaptchaSiteKey: '6LcCwo4eAAAAAKj6rbHkJE7KVA1r2V0J94dPYdAC',
          );

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
          //await FirebaseMessaging.instance.subscribeToTopic(commune);
        }

        userCredential = await FirebaseAuth.instance.signInAnonymously();
      }
     // else{

        //await Firebase.initializeApp(options: firebaseOptions);
     // }
 // }

  final SharedPreferences prefs = await _prefs;
  //await prefs.clear(); // reset
  //await storage.deleteAll();
  //commune = prefs.getString("topic") ?? "none";
  commune = await storage.read(key: "topic");
  if(commune == "" || commune == null){
    commune = "none";
  }
  log("COMMUNE : " + commune);

  runApp(MyApp(hasInternet: hasInternet, topic: commune,));
}

void initialization(BuildContext context) async {
  
  await Future.delayed(const Duration(seconds: 1));
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false;
}

class MyApp extends StatelessWidget{

    bool hasInternet;
    String topic = "none";
    MyApp({this.hasInternet, this.topic,});

    @override
    Widget build(BuildContext context) => ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      builder: (context, _) {

        //LocalNotificationService.initialize(context);
        
        final themeProvider = Provider.of<ThemeProvider>(context);

        return OverlaySupport(
            child: MaterialApp(
              title:'DSA',
              themeMode: themeProvider.themeMode,
              theme: MyThemes.lightTheme,
              darkTheme: MyThemes.darkTheme,
              debugShowCheckedModeBanner: false,
              home: AuthenticationWrapper(hasInternet: true,),
              builder: EasyLoading.init(),
            ),
        );
      }
    );
}

class AuthenticationWrapper extends StatefulWidget {

  bool hasInternet;
  AuthenticationWrapper({this.hasInternet});

  @override
  _AuthenticationWrapperState createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> with WidgetsBindingObserver {

  StreamSubscription subscription; // check internet
  bool ignoreFirstConnexion = true; //

  bool isInMaintenance = false;
  bool isSafeDevice = true;
  bool error = false;

  bool isLocked = false;

  @override
  void initState() {

    if(widget.hasInternet){

      if(!kIsWeb){
         checkVersion();
      }
    }
    
    subscription = Connectivity().onConnectivityChanged.listen(showConnectivityBar);
    WidgetsBinding.instance.addObserver(this);

    EasyLoading.addStatusCallback((status) {
      print('EasyLoading Status $status');
      if (status == EasyLoadingStatus.dismiss) {
        //_timer?.cancel();
      }
    });

    Auth();

    super.initState();
  }

  @override
  void dispose(){
    subscription.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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

      //MapScreenPicker.timer.cancel();

      Future.delayed(
         const Duration(minutes: 15),
         Manager.customCacheManager.emptyCache,
      );

      log("app in background");

    }
    else{
      log("app in foreground");
    }
  }

  @override
  Widget build(BuildContext context) {

        if (commune == "none") {

                return Container(
                  color: Theme.of(context).backgroundColor,
                  child:Visibility(
                    visible: isLocked? false : true,
                    child: !error ? ConnexionPage(hasInternet: widget.hasInternet) : ErrorScreen(lottie: error_reason,)
                  ),
                );
        }
        else{

                return Container(
                  color: Theme.of(context).backgroundColor,
                  child:Visibility(
                    visible: isLocked? false : true,
                    child: !error ? MenuPage(commune: commune) : ErrorScreen(lottie: error_reason,)
                  ),
                );
        }
  }

  final LocalAuthentication auth = LocalAuthentication();

  Future Auth() async {

    if(isLocked){

      bool didAuthenticate = await auth.authenticate(
            localizedReason:
                'Veuillez vous authentifier pour accéder à votre espace personnel.',
            useErrorDialogs: true,
            stickyAuth: true,
            biometricOnly: true,
      );

      if(didAuthenticate == true){

        setState(() {
          isLocked = false;
        });
      }
      else{
        setState(() {
          Auth();
        });
      }
    }
  }

  void showConnectivityBar(ConnectivityResult result) async {

    if(!kIsWeb){

      if(widget.hasInternet == false){
        ignoreFirstConnexion = false;
      }

      if(ignoreFirstConnexion == false){
      
      final _hasInternet = result != ConnectivityResult.none;
      final message = _hasInternet
        ? "Reconnecté à Internet"
        : "Connexion Perdue";
      final color = _hasInternet ? Colors.green : Colors.red;

      // show a notification at top of screen.
      Utils.showTopSnackBar(context, message, message, color);

      if(widget.hasInternet == false){

         // if(!Platform.isWindows){

            log("Loading App now with have Internet !");
        
            await Firebase.initializeApp();
            await FirebaseAppCheck.instance.activate(
              webRecaptchaSiteKey: '6LcCwo4eAAAAAJUYX1BIadc0RI3kHewxLZ-yIxtn',
            );

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

            checkVersion();
        //}
       // else{
      
       //    await Firebase.initializeApp(options: firebaseOptions);
       // }

        if(userCredential == null){
          
          userCredential = await FirebaseAuth.instance.signInAnonymously();
        }
      }

      setState(() {
        if(widget.hasInternet == false){
          widget.hasInternet = _hasInternet;
        }
      });

      }
      else{
        ignoreFirstConnexion = false;
      }
    }
  }

  Future<String> checkCountry() async {

    Response data = await http.get(Uri.parse("http://ip-api.com/json"));

    Map dataMap = jsonDecode(data.body);
    String country = dataMap['country'];

    String language = await Devicelocale.currentLocale;
    log("country: " + country + "  language: " + language);
    return country;
  }

  Future checkVersion() async {

    try{

      bool isSafeDevice = false;//await SafeDevice.isSafeDevice;
      setState(() {
        error = isSafeDevice; // !
        error_reason = "shield";
      });

      String version = "";

      PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
        String appName = packageInfo.appName;
        String packageName = packageInfo.packageName;
        version = packageInfo.version;
        String buildNumber = packageInfo.buildNumber;
      });

      String serverVersion = "";

      if (Platform.isAndroid) {

          await FirebaseFirestore.instance.collection("server").get().then((querySnapshot) {
                    querySnapshot.docs.forEach((result) {
                        serverVersion = result.data()["android_version"];
                        if(this.mounted)
                        setState(() {
                          isInMaintenance = result.data()["maintenance"];
                          if(isInMaintenance == true){
                            error = true;
                            error_reason = "maintenance";
                          }
                        });
                    });
          });

      }
      else{

        await FirebaseFirestore.instance.collection("server").get().then((querySnapshot) {
                    querySnapshot.docs.forEach((result) {
                        serverVersion = result.data()["ios_version"];
                        if(this.mounted)
                        setState(() {
                          isInMaintenance = result.data()["maintenance"];
                          if(isInMaintenance == true){
                            error = true;
                            error_reason = "maintenance";
                          }
                        });
                    });
       });
      }

      if(version != serverVersion){

        log("serv: " + serverVersion);
        log("app: " + version);

        final isYes = await showCupertinoDialog(
              context: context, 
              builder: createDialog
        ); 

        if(isYes){
          StoreRedirect.redirect();
        }
      }
      
    }
    catch(e){}
  }
}


 Widget createDialog(BuildContext context) => CupertinoAlertDialog(
         title: const Text("Mise à jour disponible", style: TextStyle(fontSize:18)),
         content: Column(
           children: [
             Lottie.asset(
              "assets/update.json",
              animate: true,
              height: 100,
             ), 
             const Text("il est fortement recommandé de mettre votre application à jour.", style: TextStyle(fontSize:16)),
           ],
         ),
         actions: [
           CupertinoDialogAction(
             child: const Text("Plus tard"),
             onPressed: () => Navigator.pop(context,false),
           ),
           CupertinoDialogAction(
             child: const Text("Ok !"),
             onPressed: () => Navigator.pop(context,true),
           ),
         ],
  );

  Widget createMessage(BuildContext context) => CupertinoAlertDialog(
         title: Text("Erreur", style: TextStyle(fontSize:18)),
         content: Column(
           children: [
             Lottie.asset(
              "assets/wifi.json",
              animate: true,
              height: 60,
             ), 
             const Text("Vous n'etes pas connecté à internet.", style: TextStyle(fontSize:16)),
           ],
         ),
         actions: [
           CupertinoDialogAction(
             child: const Text("Ok"),
             onPressed: () => Navigator.pop(context,false),
           ),
         ],
  );