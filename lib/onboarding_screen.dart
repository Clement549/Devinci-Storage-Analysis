import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:fancy_on_boarding/fancy_on_boarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_course/connexion_page.dart';

class OnboardingScreen extends StatefulWidget {

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {

    final pageList = [
      PageModel(
          color: const Color(0xFF678FB4),
          heroImagePath: 'assets/hotels.png',
          title: Text('SURVEILLANCE',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontSize: 28.0,
              )),
          body: Text('Les poubelles équipées de capteur sont affichées en temps réel sur la carte.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              )),
          iconImagePath: 'assets/key.png'),
      PageModel(
          color: const Color(0xFF65B0B4),
          heroImagePath: 'assets/banks.png',
          title: Text('ANALYSE',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontSize: 34.0,
              )),
          body: Text(
              'Les poubelles bientot pleine vous seront indiquées.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              )),
          iconImagePath: 'assets/wallet.png'),
      PageModel(
        color: const Color(0xFF9B90BC),
        heroImagePath: 'assets/stores.png',
        title: Text('OPTIMISATION',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontSize: 34.0,
            )),
        body: Text('Ne perdez plus votre temps et rendez-vous seulement sur les lieues nécessitant votre intervention.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
            )),
        icon: Icon(
          Icons.shopping_cart,
          color: const Color(0xFF9B90BC),
        ),
      ),
    ];


    @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DoubleBackToCloseApp(
        snackBar: SnackBar(
            backgroundColor: Theme.of(context).backgroundColor,
            content: Text('Appuyez à nouveau pour quitter.', style: TextStyle(color: Theme.of(context).iconTheme.color),),
      ),
      child: FancyOnBoarding(
        doneButtonText: "GO !",
        skipButtonText: "Passer",
        pageList: pageList,
        onDoneButtonPressed: () =>
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => ConnexionPage(hasInternet: true,))),
        onSkipButtonPressed: () =>
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => ConnexionPage(hasInternet: true,))),
      ),
    ));
  }
}