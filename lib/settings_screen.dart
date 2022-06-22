
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsScreen extends StatefulWidget {

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  bool isDarkMode;

   @override
   void initState() {

      var brightness = SchedulerBinding.instance.window.platformBrightness;
      isDarkMode = brightness == Brightness.dark;
      
      super.initState();
   }

  @override
  Widget build(BuildContext context) =>

     Scaffold(
        appBar: AppBar(
          systemOverlayStyle: isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
          foregroundColor: Theme.of(context).iconTheme.color,
          backgroundColor: Colors.transparent,
          toolbarHeight: 40,
          elevation: 0,
          flexibleSpace: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).backgroundColor.withOpacity(1),
                  ),
              ),
          centerTitle: true,
          title: Text('Paramètres', style: TextStyle(color: Theme.of(context).iconTheme.color,)),
          ),
        body: SettingsList(
                sections: [
                  SettingsSection(
                    title: const Text('Interface'),
                    tiles: <SettingsTile>[
                      SettingsTile.navigation(
                        leading: Icon(Icons.language),
                        title: Text('Langage'),
                        value: Text('Français'),
                      ),
                      SettingsTile.switchTile(
                        onToggle: (value) async {

                           log("CLICKEDD");
                           //await FlutterStatusbarManager.setStyle(StatusBarStyle.DARK_CONTENT);
                        },
                        initialValue: true,
                        leading: Icon(Icons.format_paint),
                        title: Text('Thème personnalisé'),
                      ),
                    ],
                  ),
                ],
              ),
     );
}