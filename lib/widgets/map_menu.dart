import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_course/connexion_page.dart';
import 'package:flutter_course/map_page_picker_web.dart';
import 'package:flutter_course/menu_screen.dart';
import 'package:flutter_course/widgets/webview_page.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share/share.dart';
import 'package:flutter/foundation.dart' show Factory, defaultTargetPlatform, kIsWeb;


import '../map_page_picker.dart';

class MenuPage extends StatefulWidget {

  String commune;
  Function reloadData;

  @override
  _MenuPageState createState() => _MenuPageState();

  MenuPage({
    this.commune,
    this.reloadData,
  });
}

class _MenuPageState extends State<MenuPage> {

  @override
  Widget build(BuildContext context) {

    if(!kIsWeb){

        return ZoomDrawer(
          backgroundColor: Theme.of(context).backgroundColor,
          style: DrawerStyle.Style1,
          menuScreen: MenuScreen(commune: widget.commune, reloadData: widget.reloadData,), 
          mainScreen: MapScreenPicker(commune: widget.commune,),
        );
    }
    else{

      /*return ZoomDrawer(
          backgroundColor: Theme.of(context).backgroundColor,
          style: DrawerStyle.Style1,
          menuScreen: MenuScreen(commune: widget.commune, reloadData: widget.reloadData,), 
          mainScreen: MapScreenPickerWeb(commune: widget.commune,),
        );*/
    }

  }
}