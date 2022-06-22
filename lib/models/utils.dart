

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class Utils{

  static void showTopSnackBar(
    BuildContext context,
    String title,
    String message,
    Color color,
  ) =>
    showSimpleNotification(
      Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
      //subtitle: Text(message, style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal),),
      background: color.withOpacity(0.5),
      slideDismiss: true,
      elevation: 3,
    );
}