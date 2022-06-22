import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_course/connexion_page.dart';
import 'package:flutter_course/settings_screen.dart';
import 'package:flutter_course/widgets/webview_page.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MenuScreen extends StatefulWidget {

  String commune;
  Function reloadData;

  @override
  _MenuScreenState createState() => _MenuScreenState();

  MenuScreen({
    this.commune,
    this.reloadData,
  });
}

class _MenuScreenState extends State<MenuScreen> {

Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

final storage = const FlutterSecureStorage();
final storage_options = const IOSOptions(accessibility: IOSAccessibility.first_unlock);

@override
Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Theme.of(context).backgroundColor,
      child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 50.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(height: 0,),

          IconButton(
            icon: Icon(Icons.close, size: 20.0, color: Theme.of(context).iconTheme.color),
            onPressed: () async {

               ZoomDrawer.of(context).toggle();
            },
          ),

          Container(height: 50,),

          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Secteur de " + widget.commune,
                  style: TextStyle(color: Theme.of(context).iconTheme.color),
                ),
                const SizedBox(height: 20.0),
              ],
            ),
          ),

          ListTile(
            onTap: () async {

               
                //prefs.setString("topic", "none");
                //prefs.setString("captcha", "true");
                await storage.write(key: "topic", value: "none");
                await storage.write(key: "captcha", value: "true");
             

              await Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => ConnexionPage()));
            },
            leading: Icon(Icons.home, size: 20.0, color: Theme.of(context).iconTheme.color),
            title: const Text("Menu"),
            textColor: Theme.of(context).iconTheme.color,
            dense: true,
          ),
          ListTile(
            onTap: () async => widget.reloadData,
            leading: Icon(Icons.refresh,
                size: 20.0, color: Theme.of(context).iconTheme.color),
            title: const Text("Actualiser"),
            textColor: Theme.of(context).iconTheme.color,
            dense: true,

            // padding: EdgeInsets.zero,
          ),
          ListTile(
            onTap: () async {
              
              /*final Email email = Email(
                body: '',
                subject: 'DSA',
                recipients: ['clementroure@orange.fr'],
                cc: ['cc@example.com'],
                bcc: ['bcc@example.com'],
                //attachmentPaths: ['/path/to/attachment.zip'],
                isHTML: false,
              );

              await FlutterEmailSender.send(email);*/

              final Uri emailLaunchUri = Uri(
              scheme: 'mailto',
              path: 'clementroure@orange.fr',
              query: encodeQueryParameters(<String, String>{
                'subject': 'DSA - Formulaire de contact'
              }),
            );

            launch(emailLaunchUri.toString());
            },
            leading: Icon(Icons.mail,
                size: 20.0, color: Theme.of(context).iconTheme.color),
            title: const Text("Contact"),
            textColor: Theme.of(context).iconTheme.color,
            dense: true,

            // padding: EdgeInsets.zero,
          ),
          if(!kIsWeb)
          ListTile(
            onTap: () async {

              final InAppReview inAppReview = InAppReview.instance;

              if (await inAppReview.isAvailable()) {
                  inAppReview.requestReview();
              }
            },
            leading: Icon(Icons.rate_review,
                size: 20.0, color: Theme.of(context).iconTheme.color),
            title: const Text("Évaluer"),
            textColor: Theme.of(context).iconTheme.color,
            dense: true,

            // padding: EdgeInsets.zero,
          ),
          if(!kIsWeb)
          ListTile(
            onTap: () async {

              await Share.share('Optimisez le ramassage des déchets avec l\'application DSA maintenant !');
            },
            leading: Icon(Icons.share,
                size: 20.0, color: Theme.of(context).iconTheme.color),
            title: const Text("Partager"),
            textColor: Theme.of(context).iconTheme.color,
            dense: true,

            // padding: EdgeInsets.zero,
          ),
          ListTile(
            onTap: () async {

              if(!kIsWeb){
                
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WebViewPage(url: "https://www.esilv.fr/formations/cycle-ingenieur/")),
                  );
              }
              else{

                const url = "https://www.esilv.fr/formations/cycle-ingenieur/";
                if (await canLaunch(url)){
                  await launch(url);
                }
              }
            },
            leading:
                Icon(Icons.web, size: 20.0, color: Theme.of(context).iconTheme.color),
            title: const Text("Site Web"),
            textColor: Theme.of(context).iconTheme.color,
            dense: true,

            // padding: EdgeInsets.zero,
          ),
          ListTile(
            onTap: () async {

               await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
            leading:
                Icon(Icons.settings, size: 20.0, color: Theme.of(context).iconTheme.color),
            title: const Text("Paramètres"),
            textColor: Theme.of(context).iconTheme.color,
            dense: true,

            // padding: EdgeInsets.zero,
          ),
        ],
      ),
    ));
  }  

      String encodeQueryParameters(Map<String, String> params) {
        return params.entries
            .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
            .join('&');
      }
}
