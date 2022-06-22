

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineTitles{

  static getTitleData() => FlTitlesData(
    show: true,
    rightTitles: SideTitles(
      showTitles: false,
    ),
    topTitles: SideTitles(
      showTitles: false,
    ),
    bottomTitles: SideTitles(

      showTitles: true,
      margin: 10,
      reservedSize: 10,
      getTextStyles: (context, value) => TextStyle(
        color: Theme.of(context).iconTheme.color,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      getTitles: (value) {

        switch(value.toInt()){
          case 0:
            return "Lun";
          case 1:
            return "Mar";
          case 2:
            return "Merc";
          case 3:
            return "Jeu";
          case 4:
            return "Ven";
          case 5:
            return "Sam";
          case 6:
            return "Dim";
        }

        return "";
      }
    ),
    leftTitles: SideTitles(
      showTitles: true,
      getTextStyles: (context, value) => TextStyle(
        color: Theme.of(context).iconTheme.color,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      getTitles: (value) {
        switch(value.toInt()) {
          case 1:
            return "10%";
          case 2:
            return "20%";
          case 3:
            return "30%";
          case 4:
            return "40%";
          case 5:
            return "50%";
          case 6:
            return "60%";
          case 7:
            return "70%";
          case 8:
            return "80%";
          case 9:
            return "90%";
          case 10:
            return "100%";
        }
        return "";
      },
      reservedSize: 30,
      margin: 5,
    ),
  );
}