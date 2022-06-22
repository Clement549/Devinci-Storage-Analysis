

import 'dart:developer';

import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier{

  ThemeMode themeMode = ThemeMode.system;

  bool get isDarkMode => themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) async {

    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    if(themeMode == ThemeMode.dark){
      //await FlutterStatusbarManager.setStyle(StatusBarStyle.LIGHT_CONTENT);
    }
    else{
      //await FlutterStatusbarManager.setStyle(StatusBarStyle.DARK_CONTENT);
    }
    notifyListeners();
  }
}

class MyThemes{

  static final lightTheme = ThemeData(
    
    scaffoldBackgroundColor: const Color.fromRGBO(10,10,10,1),
    primaryColor: Colors.white,
    backgroundColor: const Color.fromRGBO(245,245,245,1),
    colorScheme: const ColorScheme.light(),
    iconTheme: const IconThemeData(color: Colors.black,),
    shadowColor: const Color.fromRGBO(50,50,50, 0.7),
    checkboxTheme: CheckboxThemeData(overlayColor: MaterialStateProperty.all(const Color(0xff9F69C6))),
    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.white, modalBackgroundColor: Colors.white, elevation: 2, shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
         ),
      ),),
    //dialogTheme: const DialogTheme(contentTextStyle: TextStyle(color: Colors.green,)),

    /*textSelectionTheme: TextSelectionThemeData(
      cursorColor: const Color(0xff9F69C6).withOpacity(1),
      selectionColor: const Color(0xff9F69C6).withOpacity(.6),
      selectionHandleColor: const Color(0xff9F69C6).withOpacity(1),
    ),*/

  );


  static final darkTheme = ThemeData(

    scaffoldBackgroundColor: const Color.fromRGBO(10,10,10,1),
    primaryColor: Colors.black,
    backgroundColor: const Color.fromRGBO(10,10,10,1),
    colorScheme: const ColorScheme.dark(),
    iconTheme: IconThemeData(color: Colors.white.withOpacity(0.9),),
    shadowColor: const Color.fromRGBO(50,50,50, 0.7),
    dialogBackgroundColor: const Color.fromRGBO(20,20,20,1),
    checkboxTheme: CheckboxThemeData(overlayColor: MaterialStateProperty.all(const Color(0xff9F69C6))),
    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.black, modalBackgroundColor: Colors.black, elevation: 2, shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
         ),
      ),),

    /*textSelectionTheme: TextSelectionThemeData(
      cursorColor: const Color(0xff9F69C6).withOpacity(1),
      selectionColor: const Color(0xff9F69C6).withOpacity(.6),
      selectionHandleColor: const Color(0xff9F69C6).withOpacity(1),
    ),*/

  );
}