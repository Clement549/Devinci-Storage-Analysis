import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart' show Factory, defaultTargetPlatform, kIsWeb;

// flutter build web
// flutter run -d chrome --web-renderer html

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_course/api/upload_images.dart';
import 'package:flutter_course/connexion_page.dart';
import 'package:flutter_course/const/manager.dart';
import 'package:flutter_course/graph_screen.dart';
import 'package:flutter_course/models/directions_model.dart';
import 'package:flutter_course/models/directions_repository.dart';
import 'package:flutter_course/models/utils.dart';
import 'package:flutter_course/widgets/dialog_widget.dart';
import 'package:flutter_course/widgets/gallery_screen.dart';
import 'package:flutter_course/widgets/line_chart_widget.dart';
import 'package:flutter_course/widgets/loading_screen.dart';
import 'package:flutter_course/widgets/menu_widget.dart';
import 'package:flutter_course/widgets/rounded_button_widget.dart';
import 'package:flutter_course/widgets/shimmer_widget.dart';
import 'package:flutter_course/widgets/webview_page.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:location/location.dart';
import 'package:map_launcher/map_launcher.dart' as mapLauncher;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share/share.dart';
import 'package:shrink_sidemenu/shrink_sidemenu.dart';

import 'models/capteur.dart';

class MapScreenPicker extends StatefulWidget {

  static Timer timer;
  String commune;
  bool hasInternet;
  @override
  _MapScreenPickerState createState() => _MapScreenPickerState();

  MapScreenPicker({
    this.commune, this.hasInternet,
  });
}

class _MapScreenPickerState extends State<MapScreenPicker> {

  StreamSubscription subscription;

  CameraPosition _cam;
  CameraPosition _camZoom;

  LatLng currentPos;
  String currentPosString = "";

  List<FlSpot> graph_values = [ 
      FlSpot(0,0),
      FlSpot(1, 2),
      FlSpot(2, 3),
      FlSpot(3, 4),
      FlSpot(4, 9),
      FlSpot(5, 0),
      FlSpot(6, 4),
  ];

  CameraPosition setCameraPosition(pos){
     return CameraPosition(
        target: pos,
        //target: pos!,
        zoom: 13,
        tilt: 0,
      );
  }
  CameraPosition setCameraPositionZoom(pos){
     return CameraPosition(
        target: pos,
        //target: pos!,
        zoom: 16,
        tilt: 0,
      );
  }

  GoogleMapController _googleMapController;
  Marker _origin;
  List<Marker> _destinations = [];
  Directions _info;

  List<Capteur> capteurs = [];

  dynamic availableMaps = null;

  BitmapDescriptor _binIcon1;
  BitmapDescriptor _binIcon2;
  BitmapDescriptor _binIcon3;
  BitmapDescriptor _truckIcon1;
  BitmapDescriptor _truckIcon2;
  BitmapDescriptor _markerIcon;

  double rotation = 0;

  bool isInitialized = false;
  
  bool isLoading = true;

  bool isDarkMode;
  bool ignoreFirstConnexion = false;

  @override
  void initState() {

    var brightness = SchedulerBinding.instance.window.platformBrightness;
    isDarkMode = brightness == Brightness.dark;

    subscription = Connectivity().onConnectivityChanged.listen(showConnectivityBar);

    _cam = setCameraPosition(const LatLng(48.8960876, 2.2334706));
    _camZoom = setCameraPositionZoom(const LatLng(48.8960876, 2.2334706));

    FlutterCompass.events.listen(_onData);

    LoadData();

    super.initState();
  }
  @override
  void dispose() {
    if(_googleMapController != null)
    _googleMapController.dispose();
    //MapScreenPicker.timer.cancel();
    super.dispose();
  }

  void showConnectivityBar(ConnectivityResult result) async {

    final _hasInternet = result != ConnectivityResult.none;
    final message = _hasInternet
       ? "Reconnecté à Internet"
       : "Connexion Perdue";
    final color = _hasInternet ? Colors.green : Colors.red;

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {

        await LoadData();
        developer.log("RELOADD");
    } 

    if(ignoreFirstConnexion == true){

       if (this.mounted){
       Utils.showTopSnackBar(context, message, message, color);
       }
    }

    ignoreFirstConnexion = true;
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png)).buffer.asUint8List();
  }

  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var a = 0.5 - cos((lat2 - lat1) * p)/2 + 
          cos(lat1 * p) * cos(lat2 * p) * 
          (1 - cos((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  } 

  void _onData(CompassEvent x) async { 

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {

        if(isInitialized){
        
          if (this.mounted){
          setState(() { 
            rotation = x.heading; 
          }); 
          }

          await _updateOriginRotation(currentPos);
        }
    }
  }

  PermissionStatus _permissionGranted;
  bool _serviceEnabled;
  Location location = Location();

  Future activateGPS() async {

    developer.log("ACTIVATE GPS");

    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();

    currentPos =  LatLng(_locationData.latitude, _locationData.longitude);
    currentPosString = _locationData.latitude.toString()+","+_locationData.longitude.toString();

    _cam = setCameraPosition(currentPos);
    _camZoom = setCameraPositionZoom(currentPos);

    await _updateOrigin(currentPos);

     if(_googleMapController != null){
      _googleMapController.animateCamera(
              _info != null
                  ? CameraUpdate.newLatLngBounds(_info.bounds, 100.0)
                  : CameraUpdate.newCameraPosition(_cam),
      );   
     }

     isInitialized = true;
  }

  Future trackGPS() async {

    LocationData _locationData;

    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();

    currentPos =  LatLng(_locationData.latitude, _locationData.longitude);
    currentPosString = _locationData.latitude.toString()+","+_locationData.longitude.toString();

    _cam = setCameraPosition(currentPos);
    _camZoom = setCameraPositionZoom(currentPos);

    await _updateOrigin(currentPos);

    developer.log("GPS Update !" + rotation.toString());
  }

  Future LoadData() async {

    if(!kIsWeb){

          final Uint8List markerIcon = await getBytesFromAsset('assets/direction.png', 90);
          _markerIcon = BitmapDescriptor.fromBytes(markerIcon);

          final Uint8List binIcon1 = await getBytesFromAsset('assets/bin1.png', 90);
          _binIcon1 = BitmapDescriptor.fromBytes(binIcon1);
          final Uint8List binIcon2 = await getBytesFromAsset('assets/bin2.png', 140);
          _binIcon2 = BitmapDescriptor.fromBytes(binIcon2);
          final Uint8List binIcon3 = await getBytesFromAsset('assets/bin3.png', 110);
          _binIcon3 = BitmapDescriptor.fromBytes(binIcon3);

          final Uint8List truckIcon1 = await getBytesFromAsset('assets/camion1.png', 130);
          _truckIcon1 = BitmapDescriptor.fromBytes(truckIcon1);
          final Uint8List truckIcon2 = await getBytesFromAsset('assets/camion2.png', 130);
          _truckIcon2 = BitmapDescriptor.fromBytes(truckIcon2);
      }

   var connectivityResult = await (Connectivity().checkConnectivity());
   if (connectivityResult != ConnectivityResult.none) {

      try{
        
        await FirebaseFirestore.instance.collection("capteurs").get().then((querySnapshot) {
                querySnapshot.docs.forEach((result) {

                        if(result.data()["commune"] == widget.commune){ // affciher seulement infos relative a la commune (topic)

                          if (this.mounted){
                          setState((){
                            capteurs.add(Capteur(
                              id: result.data()["id"],
                              name: result.data()["name"],
                              img1: result.data()["img1"],
                              img2: result.data()["img2"],
                              img3: result.data()["img3"],
                              date_installation: result.data()["date_installation"],
                              date_last_update: result.data()["date_last_update"],
                              fill_rate: result.data()["fill_rate"],
                              battery: result.data()["battery"],
                              localisation: result.data()["localisation"],
                              commune: result.data()["commune"],
                            ));
                          });
                          }

                        }
                });
        });

        /// Initilisation
  
          availableMaps = await mapLauncher.MapLauncher.installedMaps;

          for(int i=0;i<capteurs.length;i++){

            List<String> localisation = capteurs[i].localisation.split(',');

            await _addMarker(LatLng(double.parse(localisation[0]), double.parse(localisation[1])), i);
          }

          await activateGPS();

          MapScreenPicker.timer = Timer.periodic(const Duration(seconds: 5), (Timer t) async => trackGPS());

          await Future.delayed(const Duration(milliseconds: 1000));

          isLoading = false;

      }
      catch(e){}

    }
    else{

      isLoading = false;
    }
  }

  

    Future ReloadData() async {

      isLoading = true;

      capteurs = [];
      _destinations = [];

    try{
      
       await FirebaseFirestore.instance.collection("capteurs").get().then((querySnapshot) {
              querySnapshot.docs.forEach((result) {
                     if(result.data()["commune"] == widget.commune){ // affciher seulement infos relative a la commune (topic)

                        if (this.mounted){
                        setState((){
                          capteurs.add(Capteur(
                            id: result.data()["id"],
                            name: result.data()["name"],
                            img1: result.data()["img1"],
                            img2: result.data()["img2"],
                            img3: result.data()["img3"],                           
                            date_installation: result.data()["date_installation"],
                            date_last_update: result.data()["date_last_update"],
                            fill_rate: result.data()["fill_rate"],
                            battery: result.data()["battery"],
                            localisation: result.data()["localisation"],
                            commune: result.data()["commune"],
                          ));
                        });
                        }

                      }
              });
       });

        for(int i=0;i<capteurs.length;i++){

          List<String> localisation = capteurs[i].localisation.split(',');

          await _addMarker(LatLng(double.parse(localisation[0]), double.parse(localisation[1])), i);
        }

        LocationData _locationData = await location.getLocation();

        currentPos =  LatLng(_locationData.latitude, _locationData.longitude);
        currentPosString = _locationData.latitude.toString()+","+_locationData.longitude.toString();

        await _updateOrigin(currentPos);

    }
    catch(e){}

    isLoading = false;

  }

  @override
  Widget build(BuildContext context) =>
    isLoading ?  LoadingScreen()
    : WillPopScope(
      onWillPop: () async => false,//_willPop(context),
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        floatingActionButtonAnimator: NoScalingAnimation(),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          systemOverlayStyle: isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
          backgroundColor: Colors.transparent,
          toolbarHeight: 40,
          elevation: 0,
          flexibleSpace: Container(
                  decoration: BoxDecoration(
                    /*gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor.withOpacity(0.5),
                        Theme.of(context).primaryColor.withOpacity(0.5),
                      ],
                    ),*/
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                    color: Theme.of(context).backgroundColor.withOpacity(0.5),
                    /*boxShadow: [
                      //background color of box
                      BoxShadow(
                        color: Color.fromRGBO(150, 150, 150, 1),
                        blurRadius: 5.0, // soften the shadow
                        spreadRadius: 1.0, //extend the shadow
                        offset: Offset(
                          0, // Move to right 10  horizontally
                          0, // Move to bottom 10 Vertically
                        ),
                      )
                    ],*/
                  ),
              ),
          centerTitle: true,
          title: Text('DSA', style: TextStyle(color: Theme.of(context).iconTheme.color,)),
          leading: MenuWidget(),
        ),
          /*actions: [

            IconButton(
              icon: Icon(Icons.more_vert, color: Theme.of(context).iconTheme.color,),
              onPressed: () async {


                await ReloadData();
              }
            ),

            /*if (_origin != null)
             TextButton(
                onPressed: () => _googleMapController!.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: _origin!.position,
                      zoom: 14.5,
                      tilt: 50.0,
                    ),
                  ),
                ),
                style: TextButton.styleFrom(
                  primary: Colors.green,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
                child: const Text('ORIGIN'),
              ), 
              TextButton(
                onPressed: () => Navigator.pop(context, currentPosString),
                style: TextButton.styleFrom(
                  primary: Colors.blue,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
                child: const Text('DEST'),
              )*/
          ], */
        body: WillPopScope(
        onWillPop: () async => false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GoogleMap(
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                    Factory<OneSequenceGestureRecognizer>(() => new EagerGestureRecognizer(),),
              ].toSet(),
              minMaxZoomPreference: const MinMaxZoomPreference(6,22),
              trafficEnabled: false,
              mapToolbarEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              initialCameraPosition: _cam,
              onMapCreated: (controller) { 
                
                _googleMapController = controller;
              },
              markers: {
                if (_origin != null) _origin,
                if (_destinations != null) ..._destinations, // convert List to Set
              },
              polylines: {
                if (_info != null)
                  Polyline(
                    polylineId: const PolylineId('overview_polyline'),
                    color: Colors.red,
                    width: 5,
                    points: _info.polylinePoints
                        .map((e) => LatLng(e.latitude, e.longitude))
                        .toList(),
                  ),
              },
              //onTap: _addMarker,
            ),
            if (_info != null)
              Positioned(
                top: 20.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6.0,
                    horizontal: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.yellowAccent,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 6.0,
                      )
                    ],
                  ),
                  child: Text(
                    '${_info.totalDistance}, ${_info.totalDuration}',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        )),
        
        floatingActionButton: FloatingActionButton(
          
          backgroundColor: Colors.transparent,
          elevation: 0,
          heroTag: "floatingButton",
          mini: true,
          child: Container(
            padding: const EdgeInsets.all(6),
            child: Icon(Icons.center_focus_strong, color: Theme.of(context).iconTheme.color, size: 24,),
            decoration: BoxDecoration(
                  shape: BoxShape.circle, // circular shape
                  color: Theme.of(context).backgroundColor.withOpacity(0.5),
                  /*boxShadow: [
                      //background color of box
                      BoxShadow(
                        color: Color.fromRGBO(150, 150, 150, 1),
                        blurRadius: 3.0, // soften the shadow
                        spreadRadius: 0.8, //extend the shadow
                        offset: Offset(
                          0, // Move to right 10  horizontally
                          0, // Move to bottom 10 Vertically
                        ),
                      )
                  ],*/
            ),

          ),
          onPressed: () => _googleMapController.animateCamera(
              _info != null
                  ? CameraUpdate.newLatLngBounds(_info.bounds, 100.0)
                  : CameraUpdate.newCameraPosition(_camZoom),
            ),     
        ),
      ));

  Future _updateOrigin(LatLng pos) async {
    
      // Origin is not set OR Origin/Destination are both set
      // Set origin
      if (this.mounted){
      setState(() {
        _origin = Marker(
          markerId: const MarkerId('origin'),
          infoWindow: const InfoWindow(title: 'Votre Position'),
          icon: !kIsWeb ? _markerIcon : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          rotation: rotation,
              // https://www.flaticon.com/search?word=gps%20arrow&order_by=4&type=icon
          position: pos,
        );
        // Reset destination
        //_destination = null;

        // Reset info
        _info = null;
      });
      }

      currentPos =  LatLng(pos.latitude, pos.longitude);
      currentPosString = pos.latitude.toString()+","+ pos.longitude.toString();

      _cam = setCameraPosition(pos);
      _camZoom = setCameraPositionZoom(pos);

      //returnPos(pos);
  }

  Future _updateOriginRotation(LatLng pos) async {
    
      if (this.mounted){
      setState(() {
        _origin = Marker(
          markerId: const MarkerId('origin'),
          infoWindow: const InfoWindow(title: 'Votre Position'),
          //icon: _markerIcon,
          icon: !kIsWeb ? _markerIcon : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          rotation: rotation,
          position: pos,
        );
        // Reset destination
        //_destination = null;

        // Reset info
        _info = null;
      });
      }
  }

  Future _addMarker(LatLng pos, int i) async {
    
      // Origin is not set OR Origin/Destination are both set
      // Set origin
      if (this.mounted){
      setState(() {
        _destinations.add( Marker(
          markerId: MarkerId(i.toString()),
          infoWindow: InfoWindow(title: capteurs[i].name + " " + capteurs[i].fill_rate.toString()+"%"),
          //icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          icon: !kIsWeb ? _binIcon1 : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          position: pos,
          onTap: () async {

               //double dist = calculateDistance(currentPos.latitude, currentPos.longitude, pos.latitude, pos.longitude);
               //developer.log("Distance: " + dist.toString()+ " km");

               showMaterialModalBottomSheet(
                 backgroundColor: Colors.transparent,
                 shape: 
                    const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))
                    ),
                 elevation: 3,
                  context: context,
                  builder: (context) => SingleChildScrollView(
                    controller: ModalScrollController.of(context),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.45, //* 0.45
                      decoration: BoxDecoration(
                                        color: Theme.of(context).backgroundColor.withOpacity(0.9),
                                        borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(25.0),
                                              topRight: Radius.circular(25.0))),
                      child: Column(

                        //padding: const EdgeInsets.all(10),
                        children: [
                          
                          //Spacer(flex: 20,)  Placer au Bottom
                          Container(height: 10,),

                          /*Container(
                            margin: EdgeInsets.all(0),
                            padding: EdgeInsets.all(0),
                            height: 14,
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              onPressed: () => Navigator.pop(context), 
                              icon: const Icon(Icons.close, size: 14,)
                            ),
                          ),*/
                         GestureDetector(
                           child: Center(
                               child: Text(capteurs[i].name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                            ),
                           onTap: () async {
                                   
                                  String output = "";
                                  if(!kIsWeb){
                                      output = await DialogWidget.input_dialog(context, "Renommer");
                                  }
                                  if(output != ""){
                                    if (this.mounted){
                                    setState(() {
                                        capteurs[i].name = output;
                                    });
                                    }
                                    await FirebaseFirestore.instance.collection('capteurs').doc(capteurs[i].id).update({"name": output});
                                    //await ReloadData();
                                    await Fluttertoast.showToast(
                                      msg: "Capteur renomé !",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.black.withOpacity(0.8),
                                    );
                                    Navigator.pop(context);
                                  }
                               },
                          ),

                          Container(height: 10,),

                            if(capteurs[i].img1 != "")
                            SizedBox(
                              height: 100,
                              child: Center(
                                        child: GestureDetector(
                                          child: ClipRRect(
                                                borderRadius: BorderRadius.circular(10),
                                                child: Container(
                                                  width: MediaQuery.of(context).size.width / 1.5,
                                                  child: buildImage(i),
                                                ),
                                          ),
                                          onTap: () async {

                                           await openGallery(i);
                                          },
                                          onLongPress: () async {

                                            var connectivityResult = await (Connectivity().checkConnectivity());
                                            if (connectivityResult != ConnectivityResult.none) {

                                              double dist = calculateDistance(currentPos.latitude, currentPos.longitude, pos.latitude, pos.longitude);
                                              if(dist > 10){

                                                  bool output = false;
                                                  if(!kIsWeb){
                                                    if(output!=null){
                                                      output = await DialogWidget.dialog(context, false, "Vous êtes trop loin", "Rapprochez vous à moins de 100m du capteur afin de supprimer cette photo.");
                                                    }
                                                  }
                                                  if(kIsWeb){
                                                      await DialogWidget.dialogAwesome(context, false, "Vous êtes trop loin", "Rapprochez vous à moins de 100m du capteur afin de supprimer cette photo.");
                                                  }
                                              }
                                              else{

                                                 bool output = false;
                                                  if(!kIsWeb){
                                                    if(output!=null){
                                                      output = await DialogWidget.dialog(context, true, "Voulez-vous supprimer cette photo ?", "Vous pourrez ensuite en prendre une nouvelle.");
                                                    }
                                                  }
                                                  if(kIsWeb){
                                                      await DialogWidget.dialogAwesome(context, true, "Voulez-vous supprimer cette photo ?", "Vous pourrez ensuite en prendre une nouvelle.");
                                                  }

                                                  if(output == true){

                                                    UploadImages.DeleteFile(capteurs[i].img1, capteurs[i].id);
                                                    if (this.mounted)
                                                    setState(() {
                                                      capteurs[i].img1 = "";
                                                    });
                                                    Fluttertoast.showToast(
                                                            msg: "Photo supprimée !",
                                                            toastLength: Toast.LENGTH_SHORT,
                                                            gravity: ToastGravity.BOTTOM,
                                                            timeInSecForIosWeb: 1,
                                                            backgroundColor: Colors.black.withOpacity(0.8),
                                                    );
                                                    Navigator.pop(context);
                                                }
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                 // ],
                              //  ),
                            ),
                          if(capteurs[i].img1 == "")
                          SizedBox(
                              height: 100,
                                    child: Center(
                                        child: GestureDetector(
                                          child:Container(
                                            height: 100,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: Theme.of(context).iconTheme.color)
                                            ),
                                          child: ClipRRect(
                                                borderRadius: BorderRadius.circular(10),
                                                child: Container(
                                                  width: MediaQuery.of(context).size.width / 1.5,
                                                  child: const Icon(Icons.add_a_photo, size: 24,),
                                                ),
                                          )),
                                          onTap: () async {

                                            var connectivityResult = await (Connectivity().checkConnectivity());
                                            if (connectivityResult != ConnectivityResult.none) {

                                           /*if(kIsWeb){
                                                showModalBottomSheet();
                                              }
                                              else{
                                                if (defaultTargetPlatform == TargetPlatform.android) {
                                                  showModalBottomSheet();
                                                }
                                                else{
                                                  showModalBottomSheetIOS();
                                                }
                                              }*/

                                              double dist = calculateDistance(currentPos.latitude, currentPos.longitude, pos.latitude, pos.longitude);
                                              if(dist > 10){

                                                  bool output = false;
                                                  if(!kIsWeb){
                                                    if(output!=null){
                                                      output = await DialogWidget.dialog(context, false, "Vous êtes trop loin", "Rapprochez vous à moins de 100m du capteur afin d'ajouter une photo.");
                                                    }
                                                  }
                                                  if(kIsWeb){
                                                      await DialogWidget.dialogAwesome(context, false, "Vous êtes trop loin", "Rapprochez vous à moins de 100m du capteur afin d'ajouter une photo.");
                                                  }
                                              }
                                              if(dist <= 10){

                                                isLoading = true;

                                                 String _imageUrl = await UploadImages.pickImage(ImageSource.camera, false, true, capteurs[i].id);
                                                 //developer.log(_imageUrl);
                                                 if(_imageUrl != null){

                                                    if (this.mounted){
                                                    setState(() {
                                                      capteurs[i].img1 = _imageUrl;
                                                    });
                                                    }
                                                    Navigator.pop(context);
                                                    isLoading = false;
                                                    Fluttertoast.showToast(
                                                        msg: "Photo ajoutée !",
                                                        toastLength: Toast.LENGTH_SHORT,
                                                        gravity: ToastGravity.BOTTOM,
                                                        timeInSecForIosWeb: 1,
                                                        backgroundColor: Colors.black.withOpacity(0.8),
                                                    );
                                                 }
                                                 isLoading = false;

                                              }
                                          }
                                          }
                                        ),
                                      ),
                                      ),

                          Container(height: 10,),

                          Container(
                            margin: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.24, 0, 0, 0),
                            child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            
                            Row(children: [
                               const Icon(Icons.graphic_eq, size: 16,),
                               Text(" Remplissage: " + capteurs[i].fill_rate.toString()+"%", style: const TextStyle(fontSize: 14,),),
                            ]),
                            Container(height: 5,),
                             
                            Row(children: [
                               const Icon(Icons.battery_alert, size: 16,),
                               Text(" Batterie: " + capteurs[i].battery.toString() +"%", style: const TextStyle(fontSize: 14,),),
                            ]),
                            Container(height: 10,),

                            Row(children: [
                               const Icon(Icons.calendar_today,size: 14,),
                               Text(" Dernier Signal: " + DateFormat('dd/MM/yy HH:mm').format(capteurs[i].date_last_update.toDate()), style: const TextStyle(fontSize: 13,),),
                            ]),
                            Container(height: 5,),
                            
                            Row(children: [
                               const Icon(Icons.calendar_today,size: 14,),
                               Text(" Prochain Signal: " + DateFormat('dd/MM/yy HH:mm').format(capteurs[i].date_last_update.toDate().add(const Duration(hours: 8))), style: const TextStyle(fontSize: 13,),),
                            ]),
                            Container(height: 10,),

                            Row(children: [
                               const Icon(Icons.vpn_key, size: 14,),
                               Text(" Numéro: " + capteurs[i].id.toString(), style: const TextStyle(fontSize: 13,),),
                            ]),

                          ])),

                          Container(height: 7,),

                          TextButton(
                                onPressed: () async {
                                  
                                  await LaunchMap(i);
                                  /*
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => GraphScreen(values: graph_values)),
                                  );*/
                                },
                                child: const Text(
                                  "                         GPS                         ",
                                  style: TextStyle(fontSize: 14, color: Colors.blue)
                                ),
                                style: ButtonStyle(
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: const BorderSide(color: Colors.blue)
                                  )
                                ),
                              )
                          ),

                          //Container(height: 10,),
                        ]
                      ),
                    ),
                  ),
                );
          }
        ));
    
        // Reset info
        _info = null;
      });
      }

      currentPos =  LatLng(pos.latitude, pos.longitude);
      currentPosString = pos.latitude.toString()+","+ pos.longitude.toString();

      _cam = setCameraPosition(pos);
      _camZoom = setCameraPositionZoom(pos);

      //returnPos(pos);
      developer.log("Capteur Ajouté ! " + i.toString());
  }

  Future LaunchMap(int i) async {

        if(availableMaps!=null){

          List<String> localisation = capteurs[i].localisation.split(',');

          await availableMaps.first.showDirections(
            destination: mapLauncher.Coords(double.parse(localisation[0]), double.parse(localisation[1])),
          );
        }
  }

  String returnPos(pos){

      List<String> l = [pos.latitude.toString(), pos.longitude.toString()];

      developer.log(l[0]+","+l[1]);
      
      return l[0]+","+l[1];
  }


  Future<bool> _willPop(BuildContext context) {
    
    final completer = Completer<bool>();
    completer.complete(true);

    if(currentPosString.isNotEmpty)
      Navigator.pop(context, currentPosString);
    if(currentPosString.isEmpty)
      Navigator.pop(context);

    return completer.future;
  }

  void openGallery(i) => Navigator.of(context).push(MaterialPageRoute(

        builder: (_) => GalleryWidget(urlImage: capteurs[i].img1, index: i),
      ),
    );

    Widget buildImage(int index) => ClipRRect(
      child: CachedNetworkImage(
          cacheManager: Manager.customCacheManager,
          key: UniqueKey(),
          imageUrl: capteurs[index].img1,
          fit: BoxFit.cover,       
          //maxHeightDiskCache: 1024,
          fadeInDuration: const Duration(milliseconds: 0),
          fadeOutDuration: const Duration(milliseconds: 0),
          placeholder: (context, url) =>  ShimmerWidget.rectangular(height: 200, borderRadius: 10,),
          errorWidget: (context,url,error) => Icon(Icons.error),
      ),
    );

    void showModalBottomSheet() => showMaterialModalBottomSheet(
      enableDrag: false,
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.camera),
            title: Text("Camera"),
            onTap: () async {
              //String imageUrl = await UploadImages.pickImage(ImageSource.camera, false, false, capteurs[i]);
            },
          ),
          ListTile(
            leading: Icon(Icons.landscape),
            title: Text("Gallery"),
            onTap: () async {
             // String imageUrl = await UploadImages.pickImage(ImageSource.gallery, false, false);
            },
          ),
        ],
      )
  );
  void showModalBottomSheetIOS() => showCupertinoModalBottomSheet(
      barrierColor: Colors.black.withOpacity(0.1),
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.camera, color: Theme.of(context).iconTheme.color),
            title: Text("Camera", style: TextStyle(color: Theme.of(context).iconTheme.color),),
            onTap: () async {
             // String imageUrl = await UploadImages.pickImage(ImageSource.camera, false, false);
              Navigator.of(context).pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.landscape, color: Theme.of(context).iconTheme.color),
            title: Text("Gallery", style: TextStyle(color: Theme.of(context).iconTheme.color),),
            onTap: () async {
             // String imageUrl = await UploadImages.pickImage(ImageSource.gallery, false, false);
              Navigator.of(context).pop(context);
            },
          ),
        ],
      )
  );

}


class NoScalingAnimation extends FloatingActionButtonAnimator{
  double _x;
  double _y;
  @override
  Offset getOffset({Offset begin, Offset end, double progress}) {
  _x = begin.dx +(end.dx - begin.dx)*progress ;
  _y = begin.dy +(end.dy - begin.dy)*progress;
    return Offset(_x,_y);
  }

  @override
  Animation<double> getRotationAnimation({Animation<double> parent}) {
    return Tween<double>(begin: 1.0, end: 1.0).animate(parent);
  }

  @override
  Animation<double> getScaleAnimation({Animation<double> parent}) {
    return Tween<double>(begin: 1.0, end: 1.0).animate(parent);
  }

  
}