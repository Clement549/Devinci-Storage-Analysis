// CTRL k + CTRL c
// CTRL + /

// import 'dart:async';
// import 'dart:html';
// import 'dart:math';
// import 'dart:typed_data';

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:connectivity/connectivity.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_course/api/upload_images.dart';
// import 'package:flutter_course/graph_screen.dart';
// import 'package:flutter_course/map_page_picker.dart';
// import 'package:flutter_course/models/capteur.dart';
// import 'package:flutter_course/models/directions_model.dart';
// import 'package:flutter_course/models/utils.dart';
// import 'package:flutter_course/widgets/dialog_widget.dart';
// import 'package:flutter_course/widgets/gallery_screen.dart';
// import 'package:flutter_course/widgets/menu_widget.dart';
// import 'package:flutter_course/widgets/shimmer_widget.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:geolocator/geolocator.dart' as gps;
// import 'package:google_maps/google_maps.dart' as gmap hide Icon;
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:location/location.dart';
// import 'package:map_launcher/map_launcher.dart';
// //import 'dart:html';
// import 'dart:ui' as ui;

// import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// import 'const/manager.dart';

// class MapScreenPickerWeb extends StatefulWidget {

//    String commune;
//    bool hasInternet;

//    MapScreenPickerWeb({
//     this.commune, this.hasInternet,
//   });

//   @override
//   _MapScreenPickerWebState createState() => _MapScreenPickerWebState();
// }

// class _MapScreenPickerWebState extends State<MapScreenPickerWeb> {

//   StreamSubscription subscription;

//   gmap.LatLng currentPos;
//   String currentPosString = "";

//   List<FlSpot> graph_values = [ 
//       FlSpot(0,0),
//       FlSpot(1, 2),
//       FlSpot(2, 3),
//       FlSpot(3, 4),
//       FlSpot(4, 9),
//       FlSpot(5, 0),
//       FlSpot(6, 4),
//   ];

//   gmap.Marker _origin;
//   List<gmap.Marker> _destinations = [];
//   Directions _info;

//   List<Capteur> capteurs = [];

//   dynamic availableMaps = null;

//   double rotation = 0;

//   bool isInitialized = false;
  
//   bool isLoading = false;

//   bool isDarkMode;
//   bool ignoreFirstConnexion = false;

//   gmap.GMap map;

//   final gps.LocationSettings locationSettings = const gps.LocationSettings(
//     accuracy: gps.LocationAccuracy.high,
//     distanceFilter: 100,
//   );

//   @override
//   void initState() {

//     var brightness = SchedulerBinding.instance.window.platformBrightness;
//     isDarkMode = brightness == Brightness.dark;

//     subscription = Connectivity().onConnectivityChanged.listen(showConnectivityBar);

//     LoadData();

//     super.initState();
//   }
//   @override
//   void dispose() {
//     super.dispose();
//   }

//   void showConnectivityBar(ConnectivityResult result) async {

//     if(!kIsWeb){

//       final _hasInternet = result != ConnectivityResult.none;
//       final message = _hasInternet
//         ? "Reconnecté à Internet"
//         : "Connexion Perdue";
//       final color = _hasInternet ? Colors.green : Colors.red;

//       if(ignoreFirstConnexion == true){

//         Utils.showTopSnackBar(context, message, message, color); 
//       }

//       ignoreFirstConnexion = true;
//     }
//   }


//   double calculateDistance(lat1, lon1, lat2, lon2){
//     var p = 0.017453292519943295;
//     var a = 0.5 - cos((lat2 - lat1) * p)/2 + 
//           cos(lat1 * p) * cos(lat2 * p) * 
//           (1 - cos((lon2 - lon1) * p))/2;
//     return 12742 * asin(sqrt(a));
//   } 


//   PermissionStatus _permissionGranted;
//   bool _serviceEnabled;


//   Future LoadData() async {

//     try{
      
//        await FirebaseFirestore.instance.collection("capteurs").get().then((querySnapshot) {
//               querySnapshot.docs.forEach((result) {

//                       if(result.data()["commune"] == widget.commune){ // affciher seulement infos relative a la commune (topic)

//                         if (this.mounted){
//                         setState((){
//                           capteurs.add(Capteur(
//                             id: result.data()["id"],
//                             name: result.data()["name"],
//                             img1: result.data()["img1"],
//                             img2: result.data()["img2"],
//                             img3: result.data()["img3"],
//                             date_installation: result.data()["date_installation"],
//                             date_last_update: result.data()["date_last_update"],
//                             fill_rate: result.data()["fill_rate"],
//                             battery: result.data()["battery"],
//                             localisation: result.data()["localisation"],
//                             commune: result.data()["commune"],
//                           ));
//                         });
//                         }

//                       }
//               });
//        });

//        /// Initilisation

//         for(int i=0;i<capteurs.length;i++){

//           List<String> localisation = capteurs[i].localisation.split(',');

//           await _addMarker(gmap.LatLng(double.parse(localisation[0]), double.parse(localisation[1])), i);
//         }


//         gps.Position position = await gps.Geolocator.getCurrentPosition(desiredAccuracy: gps.LocationAccuracy.high);
        
//         _origin = gmap.Marker(gmap.MarkerOptions()
//             ..position = gmap.LatLng(position.latitude, position.longitude)
//             ..map = map
//             //..icon = "https://firebasestorage.googleapis.com/v0/b/dsa---ping.appspot.com/o/assets%2Fdirection.png?alt=media&token=cd607d0b-bf3e-4d1b-b084-4f742538fc43"
//             );

//             final infoWindow = gmap.InfoWindow(gmap.InfoWindowOptions()
//             ..content = "Votre position"
//             );
//             _origin.onClick.listen((event) => infoWindow.open(map, _origin)
//          );

//         StreamSubscription<gps.Position> positionStream = gps.Geolocator.getPositionStream(locationSettings: locationSettings).listen(
//         (gps.Position position) {
//             print(position == null ? 'Unknown' : '${position.latitude.toString()}, ${position.longitude.toString()}');
//         });

//         //await Future.delayed(const Duration(milliseconds: 500));

//         //isLoading = false;

//     }
//     catch(e){}

//   }

//     Future ReloadData() async {

//       isLoading = true;

//       capteurs = [];
//       _destinations = [];

//     try{
      
//        await FirebaseFirestore.instance.collection("capteurs").get().then((querySnapshot) {
//               querySnapshot.docs.forEach((result) {
//                      if(result.data()["commune"] == widget.commune){ // affciher seulement infos relative a la commune (topic)

//                         if (this.mounted){
//                         setState((){
//                           capteurs.add(Capteur(
//                             id: result.data()["id"],
//                             name: result.data()["name"],
//                             img1: result.data()["img1"],
//                             img2: result.data()["img2"],
//                             img3: result.data()["img3"],                           
//                             date_installation: result.data()["date_installation"],
//                             date_last_update: result.data()["date_last_update"],
//                             fill_rate: result.data()["fill_rate"],
//                             battery: result.data()["battery"],
//                             localisation: result.data()["localisation"],
//                             commune: result.data()["commune"],
//                           ));
//                         });
//                         }

//                       }
//               });
//        });

//         for(int i=0;i<capteurs.length;i++){

//           List<String> localisation = capteurs[i].localisation.split(',');

//           await _addMarker(gmap.LatLng(double.parse(localisation[0]), double.parse(localisation[1])), i);
//         }
//     }
//     catch(e){}

//     isLoading = false;

//   } 

//   Future _addMarker(gmap.LatLng pos, int i) async {

//     //final myLatlng = LatLng(48.8960876, 2.2334706);

//     final marker = gmap.Marker(gmap.MarkerOptions()
//         ..position = pos
//         ..map = map
//         //..title = 
//         //..label = ""
//         ..icon = "https://firebasestorage.googleapis.com/v0/b/dsa---ping.appspot.com/o/assets%2Fbin.png?alt=media&token=c10fd334-1031-4430-a9c4-fee40c624ed1");

//          final infoWindow = gmap.InfoWindow(gmap.InfoWindowOptions()
//          ..content = capteurs[i].name + " " + capteurs[i].fill_rate.toString() + "%"
//          );
//          marker.onClick.listen((event) => infoWindow.open(map, marker));

//         marker.onClick.listen((event) => 
          
//           showMaterialModalBottomSheet(
//                  backgroundColor: Colors.transparent,
//                  shape: 
//                     const RoundedRectangleBorder(
//                       borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))
//                     ),
//                  elevation: !kIsWeb ? 3 : 0,
//                   context: context,
//                   builder: (context) => Container(

//                 child: Padding(
//                   padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0, right: MediaQuery.of(context).size.width * 0),
//                   child: Container(
                  
//                     child:SingleChildScrollView(
//                     controller: ModalScrollController.of(context),
//                     child: Container(
//                       height: MediaQuery.of(context).size.height * 0.45, //* 0.45
//                       decoration: BoxDecoration(
//                                         color: Theme.of(context).backgroundColor.withOpacity(0.9),
//                                         borderRadius: const BorderRadius.only(
//                                               topLeft: Radius.circular(25.0),
//                                               topRight: Radius.circular(25.0))),
//                       child: Column(

//                         //padding: const EdgeInsets.all(10),
//                         children: [
                          
//                           //Spacer(flex: 20,)  Placer au Bottom
//                           Container(height: 10,),

//                           /*Container(
//                             margin: EdgeInsets.all(0),
//                             padding: EdgeInsets.all(0),
//                             height: 14,
//                             alignment: Alignment.centerRight,
//                             child: IconButton(
//                               onPressed: () => Navigator.pop(context), 
//                               icon: const Icon(Icons.close, size: 14,)
//                             ),
//                           ),*/
//                          GestureDetector(
//                            child: Center(
//                                child: Text(capteurs[i].name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
//                             ),
//                            onTap: () async {
                                   
//                                   String output = "";
//                                   if(!kIsWeb){
//                                       output = await DialogWidget.input_dialog(context, "Renommer");
//                                   }
//                                   if(output != ""){
//                                     if (this.mounted){
//                                     setState(() {
//                                         capteurs[i].name = output;
//                                     });
//                                     }
//                                     await FirebaseFirestore.instance.collection('capteurs').doc(capteurs[i].id).update({"name": output});
//                                     //await ReloadData();
//                                     await Fluttertoast.showToast(
//                                       msg: "Capteur renomé !",
//                                       toastLength: Toast.LENGTH_SHORT,
//                                       gravity: ToastGravity.BOTTOM,
//                                       timeInSecForIosWeb: 1,
//                                       backgroundColor: Colors.black.withOpacity(0.8),
//                                     );
//                                     Navigator.pop(context);
//                                   }
//                                },
//                           ),

//                           Container(height: 10,),

//                             if(capteurs[i].img1 != "")
//                             SizedBox(
//                               height: 100,
//                               child: Center(
//                                         child: GestureDetector(
//                                           child: ClipRRect(
//                                                 borderRadius: BorderRadius.circular(10),
//                                                 child: Container(
//                                                   width: MediaQuery.of(context).size.width / 1.5,
//                                                   child: buildImage(i),
//                                                 ),
//                                           ),
//                                           onTap: () async {

//                                            await openGallery(i);
//                                           },
//                                           onLongPress: () async {

//                                             if(!kIsWeb){

//                                               var connectivityResult = await (Connectivity().checkConnectivity());
//                                               if (connectivityResult != ConnectivityResult.none) {

//                                                 double dist = calculateDistance(10,10,10,10);
//                                                 if(dist > 10){

//                                                     bool output = false;
//                                                     if(!kIsWeb){
//                                                       if(output!=null){
//                                                         output = await DialogWidget.dialog(context, false, "Vous êtes trop loin", "Rapprochez vous à moins de 100m du capteur afin de supprimer cette photo.");
//                                                       }
//                                                     }
//                                                     if(kIsWeb){
//                                                         await DialogWidget.dialogAwesome(context, false, "Vous êtes trop loin", "Rapprochez vous à moins de 100m du capteur afin de supprimer cette photo.");
//                                                     }
//                                                 }
//                                                 else{

//                                                   bool output = false;
//                                                     if(!kIsWeb){
//                                                       if(output!=null){
//                                                         output = await DialogWidget.dialog(context, true, "Voulez-vous supprimer cette photo ?", "Vous pourrez ensuite en prendre une nouvelle.");
//                                                       }
//                                                     }
//                                                     if(kIsWeb){
//                                                         await DialogWidget.dialogAwesome(context, true, "Voulez-vous supprimer cette photo ?", "Vous pourrez ensuite en prendre une nouvelle.");
//                                                     }

//                                                     if(output == true){

//                                                       UploadImages.DeleteFile(capteurs[i].img1, capteurs[i].id);
//                                                       if (this.mounted)
//                                                       setState(() {
//                                                         capteurs[i].img1 = "";
//                                                       });
//                                                       Fluttertoast.showToast(
//                                                               msg: "Photo supprimée !",
//                                                               toastLength: Toast.LENGTH_SHORT,
//                                                               gravity: ToastGravity.BOTTOM,
//                                                               timeInSecForIosWeb: 1,
//                                                               backgroundColor: Colors.black.withOpacity(0.8),
//                                                       );
//                                                       Navigator.pop(context);
//                                                   }
//                                                 }
//                                               }
//                                             }
//                                           },
//                                         ),
//                                       ),
//                                  // ],
//                               //  ),
//                             ),
//                           if(capteurs[i].img1 == "")
//                           SizedBox(
//                               height: 100,
//                                     child: Center(
//                                         child: GestureDetector(
//                                           child:Container(
//                                             height: 100,
//                                             decoration: BoxDecoration(
//                                               borderRadius: BorderRadius.circular(10),
//                                               border: Border.all(color: Theme.of(context).iconTheme.color)
//                                             ),
//                                           child: ClipRRect(
//                                                 borderRadius: BorderRadius.circular(10),
//                                                 child: Container(
//                                                   width: MediaQuery.of(context).size.width / 1.5,
//                                                   child: const Icon(Icons.add_a_photo, size: 24,),
//                                                 ),
//                                           )),
//                                           onTap: () async {

//                                             if(!kIsWeb){

//                                               var connectivityResult = await (Connectivity().checkConnectivity());
//                                               if (connectivityResult != ConnectivityResult.none) {

//                                             /*if(kIsWeb){
//                                                   showModalBottomSheet();
//                                                 }
//                                                 else{
//                                                   if (defaultTargetPlatform == TargetPlatform.android) {
//                                                     showModalBottomSheet();
//                                                   }
//                                                   else{
//                                                     showModalBottomSheetIOS();
//                                                   }
//                                                 }*/

//                                                 double dist = calculateDistance(10,10,10,10);
//                                                 if(dist > 10){

//                                                     bool output = false;
//                                                     if(!kIsWeb){
//                                                       if(output!=null){
//                                                         output = await DialogWidget.dialog(context, false, "Vous êtes trop loin", "Rapprochez vous à moins de 100m du capteur afin d'ajouter une photo.");
//                                                       }
//                                                     }
//                                                     if(kIsWeb){
//                                                         await DialogWidget.dialogAwesome(context, false, "Vous êtes trop loin", "Rapprochez vous à moins de 100m du capteur afin d'ajouter une photo.");
//                                                     }
//                                                 }
//                                                 if(dist <= 10){

//                                                   isLoading = true;

//                                                   String _imageUrl = await UploadImages.pickImage(ImageSource.camera, false, true, capteurs[i].id);
//                                                   //developer.log(_imageUrl);
//                                                   if(_imageUrl != null){

//                                                       if (this.mounted){
//                                                       setState(() {
//                                                         capteurs[i].img1 = _imageUrl;
//                                                       });
//                                                       }
//                                                       Navigator.pop(context);
//                                                       isLoading = false;
//                                                       Fluttertoast.showToast(
//                                                           msg: "Photo ajoutée !",
//                                                           toastLength: Toast.LENGTH_SHORT,
//                                                           gravity: ToastGravity.BOTTOM,
//                                                           timeInSecForIosWeb: 1,
//                                                           backgroundColor: Colors.black.withOpacity(0.8),
//                                                       );
//                                                   }
//                                                   isLoading = false;

//                                                 }
//                                               }
//                                             }
//                                           }
//                                         ),
//                                       ),
//                                       ),

//                           Container(height: 10,),

//                           Container(
//                             margin: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.24, 0, 0, 0),
//                             child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
                            
//                             Row(children: [
//                                const Icon(Icons.graphic_eq, size: 16,),
//                                Text(" Remplissage: " + capteurs[i].fill_rate.toString()+"%", style: const TextStyle(fontSize: 14,),),
//                             ]),
//                             Container(height: 5,),
                             
//                             Row(children: [
//                                const Icon(Icons.battery_alert, size: 16,),
//                                Text(" Batterie: " + capteurs[i].battery.toString() +"%", style: const TextStyle(fontSize: 14,),),
//                             ]),
//                             Container(height: 10,),

//                             Row(children: [
//                                const Icon(Icons.calendar_today,size: 14,),
//                                Text(" Dernier Signal: " + DateFormat('dd/MM/yy HH:mm').format(capteurs[i].date_last_update.toDate()), style: const TextStyle(fontSize: 13,),),
//                             ]),
//                             Container(height: 5,),
                            
//                             Row(children: [
//                                const Icon(Icons.calendar_today,size: 14,),
//                                Text(" Prochain Signal: " + DateFormat('dd/MM/yy HH:mm').format(capteurs[i].date_last_update.toDate().add(const Duration(hours: 8))), style: const TextStyle(fontSize: 13,),),
//                             ]),
//                             Container(height: 10,),

//                             Row(children: [
//                                const Icon(Icons.vpn_key, size: 14,),
//                                Text(" Numéro: " + capteurs[i].id.toString(), style: const TextStyle(fontSize: 13,),),
//                             ]),

//                           ])),

//                           Container(height: 7,),

//                           TextButton(
//                                 onPressed: () async => Navigator.push(
//                                   context,
//                                   MaterialPageRoute(builder: (context) => GraphScreen(values: graph_values)),
//                                 ),//await LaunchMap(i),
//                                 child: const Text(
//                                   "                         GPS                         ",
//                                   style: TextStyle(fontSize: 14, color: Colors.blue)
//                                 ),
//                                 style: ButtonStyle(
//                                 shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                                   RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(18.0),
//                                     side: const BorderSide(color: Colors.blue)
//                                   )
//                                 ),
//                               )
//                           ),

//                           //Container(height: 10,),
//                         ]
//                       ),
//                     ),
//                   ),
//                 )
//           ))));

//          _destinations.add(marker);
      

//       if (this.mounted){
//         setState(() {  

//         // Reset info
//         _info = null;
//       });
//       }
//   } 

//   @override
//   Widget build(BuildContext context) =>

//     Scaffold(
//       backgroundColor: Theme.of(context).backgroundColor,
//       floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
//       //extendBodyBehindAppBar: true,
//       appBar: AppBar(
//           systemOverlayStyle: isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
//           backgroundColor: Colors.transparent,
//           toolbarHeight: 40,
//           elevation: 0,
//           flexibleSpace: Container(
//                   decoration: BoxDecoration(
//                     borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
//                     color: Theme.of(context).backgroundColor.withOpacity(0.5),
//                   ),
//               ),
//           centerTitle: true,
//           title: Text('DSA', style: TextStyle(color: Theme.of(context).iconTheme.color, fontWeight: FontWeight.w500)),
//           leading: MenuWidget(),
//         ),
//       body: Container(
//         child: getMap(),
//       ),
//     );

//   Widget getMap() {

//     String htmlId = "7";

//     // ignore: undefined_prefixed_name
//     ui.platformViewRegistry.registerViewFactory(htmlId, (int viewId) {

//       final myLatlng = gmap.LatLng(48.8960876, 2.2334706);

//       final mapOptions = gmap.MapOptions()
//         ..clickableIcons = false
//         ..maxZoom = 22
//         ..minZoom=6
//         ..zoom = 13
//         ..center = gmap.LatLng(48.8960876, 2.2334706);
        

//       final elem = DivElement()
//         ..id = htmlId
//         ..style.width = "100%"
//         ..style.height = "100%"
//         ..style.border = 'none';
        

//       map = gmap.GMap(elem, mapOptions);

//       return elem;
//     });
    

//     return HtmlElementView(viewType: htmlId);
//   }



//    Widget buildImage(int index) => ClipRRect(
//       child: CachedNetworkImage(
//           cacheManager: Manager.customCacheManager,
//           key: UniqueKey(),
//           imageUrl: capteurs[index].img1,
//           fit: BoxFit.cover,       
//           //maxHeightDiskCache: 1024,
//           fadeInDuration: const Duration(milliseconds: 0),
//           fadeOutDuration: const Duration(milliseconds: 0),
//           placeholder: (context, url) =>  ShimmerWidget.rectangular(height: 200, borderRadius: 10,),
//           errorWidget: (context,url,error) => Icon(Icons.error),
//       ),
//     );

//     void showModalBottomSheet() => 
//       showMaterialModalBottomSheet(
//       enableDrag: false,
//       context: context,
//       builder: (context) => Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ListTile(
//             leading: Icon(Icons.camera),
//             title: Text("Camera"),
//             onTap: () async {
//               //String imageUrl = await UploadImages.pickImage(ImageSource.camera, false, false, capteurs[i]);
//             },
//           ),
//           ListTile(
//             leading: Icon(Icons.landscape),
//             title: Text("Gallery"),
//             onTap: () async {
//              // String imageUrl = await UploadImages.pickImage(ImageSource.gallery, false, false);
//             },
//           ),
//         ],
//       )
//   );
//   void showModalBottomSheetIOS() => showCupertinoModalBottomSheet(
//       barrierColor: Colors.black.withOpacity(0.1),
//       context: context,
//       builder: (context) => Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ListTile(
//             leading: Icon(Icons.camera, color: Theme.of(context).iconTheme.color),
//             title: Text("Camera", style: TextStyle(color: Theme.of(context).iconTheme.color),),
//             onTap: () async {
//              // String imageUrl = await UploadImages.pickImage(ImageSource.camera, false, false);
//               Navigator.of(context).pop(context);
//             },
//           ),
//           ListTile(
//             leading: Icon(Icons.landscape, color: Theme.of(context).iconTheme.color),
//             title: Text("Gallery", style: TextStyle(color: Theme.of(context).iconTheme.color),),
//             onTap: () async {
//              // String imageUrl = await UploadImages.pickImage(ImageSource.gallery, false, false);
//               Navigator.of(context).pop(context);
//             },
//           ),
//         ],
//       )
//   );

//   Future LaunchMap(int i) async {

//         if(availableMaps!=null){

//           List<String> localisation = capteurs[i].localisation.split(',');

//           await availableMaps.first.showDirections(
//             destination: Coords(double.parse(localisation[0]), double.parse(localisation[1])),
//           );
//         }
//   }

//   String returnPos(pos){

//       List<String> l = [pos.latitude.toString(), pos.longitude.toString()];
      
//       return l[0]+","+l[1];
//   }


//   Future<bool> _willPop(BuildContext context) {
    
//     final completer = Completer<bool>();
//     completer.complete(true);

//     if(currentPosString.isNotEmpty)
//       Navigator.pop(context, currentPosString);
//     if(currentPosString.isEmpty)
//       Navigator.pop(context);

//     return completer.future;
//   }

//   void openGallery(i) => Navigator.of(context).push(MaterialPageRoute(

//         builder: (_) => GalleryWidget(urlImage: capteurs[i].img1, index: i),
//       ),
//     );
// } 