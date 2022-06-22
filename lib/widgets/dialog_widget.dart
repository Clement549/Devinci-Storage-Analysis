

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';

class DialogWidget{

  static Future<bool> dialog(BuildContext context, bool isQuestion, String title, String desc){
      if(isQuestion)
      return showPlatformDialog(
        context: context,
        builder: (context) => BasicDialogAlert(
          title: Text(title),
          content: Text(desc),
          actions: <Widget>[
            BasicDialogAction(
              title: Text("Annuler"),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            BasicDialogAction(
              title: Text("Ok"),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        ),
      );
      if(!isQuestion)
      return showPlatformDialog(
        context: context,
        builder: (context) => BasicDialogAlert(
          title: Text(title),
          content: Text(desc),
          actions: <Widget>[
            BasicDialogAction(
              title: Text("Ok"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }

    static Future<String> input_dialog(BuildContext context, String title,){

      TextEditingController controller = TextEditingController();

      return showPlatformDialog(
        context: context,
        builder: (context) => BasicDialogAlert(
          title: Text(title),
          content: TextField(
            autofocus: true,
            maxLength: 20,
            controller: controller,
            decoration: const InputDecoration(hintText: "Nom du capteur"),
          ),
          actions: <Widget>[
            BasicDialogAction(
              title: Text("Annuler"),
              onPressed: () {
                Navigator.pop(context, "");
              },
            ),
            BasicDialogAction(
              title: Text("Valider"),
              onPressed: () {
                Navigator.pop(context, controller.text);
              },
            ),
          ],
        ),
      );
    }

    static AwesomeDialog dialogAwesome(BuildContext context, bool isQuestion, String title, String desc){
         if(isQuestion)
         return AwesomeDialog(
            context: context,
            dialogType: DialogType.QUESTION,
            animType: AnimType.BOTTOMSLIDE,
            title: title,
            desc: desc,
            btnCancelOnPress: () {},
            btnOkOnPress: () {},
            )..show();
         if(!isQuestion)
         return AwesomeDialog(
            context: context,
            dialogType: DialogType.QUESTION,
            animType: AnimType.BOTTOMSLIDE,
            title: title,
            desc: desc,
            btnOkOnPress: () {},
            )..show();
    }
}