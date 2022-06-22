
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class LoadingScreen extends StatefulWidget {

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {

  @override
  Widget build(BuildContext context) =>

     WillPopScope(
      onWillPop: () async => false,//_willPop(context),
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Center(
          child: Container(
            width: 50,
            height: 50,
            child: Opacity(
              opacity: 1,
              child: LoadingIndicator(
              indicatorType: Indicator.ballTrianglePath, /// Required, The loading type of the widget
              colors: [Theme.of(context).iconTheme.color],       /// Optional, The color collections
              strokeWidth: 2,                     /// Optional, The stroke of the line, only applicable to widget which contains line
              backgroundColor: Colors.transparent,      /// Optional, Background of the widget
              pathBackgroundColor: Colors.transparent   /// Optional, the stroke backgroundColor
          )))
        )
      )
    );
}