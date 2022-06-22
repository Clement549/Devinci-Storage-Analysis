

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_course/widgets/line_chart_widget.dart';

class GraphScreen extends StatefulWidget {

  List<FlSpot> values = [];

  GraphScreen({
    this.values
  });

  @override
  _GraphScreenState createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {

  final List<Color> gradientColors = [
     const Color(0xff23b6e6),
     const Color(0xff02d39a),
  ];

  bool isDarkMode;

  @override
   void initState() {

      var brightness = SchedulerBinding.instance.window.platformBrightness;
      isDarkMode = brightness == Brightness.dark;
      
      super.initState();
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
          systemOverlayStyle: isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
          foregroundColor: Theme.of(context).iconTheme.color,
          backgroundColor: Colors.transparent,
          toolbarHeight: 40,
          elevation: 0,
          flexibleSpace: Container(
                  decoration: BoxDecoration(
                    //borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                    color: Theme.of(context).backgroundColor.withOpacity(1),
                  ),
              ),
          centerTitle: false,
          title: Text('Remplissage', style: TextStyle(color: Theme.of(context).iconTheme.color,)),
      ),
      body:Container(
      color: Theme.of(context).backgroundColor,
      child: Column(
      children:[ 
        Container(height: MediaQuery.of(context).size.height / 10,),
        SizedBox(
        height: MediaQuery.of(context).size.height / 1.6,
        width: MediaQuery.of(context).size.width/ 1.1,
        child: LineChart(
             LineChartData(
                               minX: 0,
                               maxX: 6,
                               minY: 0,
                               maxY: 10,
                               titlesData: LineTitles.getTitleData(),
                               gridData: FlGridData(
                                 show: true,
                                 getDrawingHorizontalLine: (value){
                                   if(value == 8)
                                   return FlLine(
                                     color: Colors.red.withOpacity(0.5),
                                     strokeWidth: 2,
                                   );
                                   if(value!=8)
                                   return FlLine(
                                     color: Colors.blue.withOpacity(0.5),
                                     strokeWidth: 1,
                                   );
                                 },
                                 drawVerticalLine: true,
                                 getDrawingVerticalLine: (value){
                                   return FlLine(
                                     color: Colors.blue.withOpacity(0.5),
                                     strokeWidth: 1,
                                   );
                                 }
                               ),
                               borderData: FlBorderData(
                                 show: true,
                                 border: Border.all(color: Colors.blue, width: 1),
                               ),
                               lineBarsData: [
                                 LineChartBarData(
                                   spots: widget.values,
                                   isCurved: true,
                                   colors: gradientColors,
                                   barWidth: 5,
                                   dotData: FlDotData(show: false),
                                   belowBarData: BarAreaData(
                                     show: true,
                                     colors: gradientColors
                                             .map((color) => color.withOpacity(0.3))
                                             .toList(),
                                   ),
                                 )
                               ]
                            ),
                          ))],
      )
    ));
  }            
}