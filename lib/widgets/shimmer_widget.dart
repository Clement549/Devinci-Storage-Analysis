import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';


class ShimmerWidget extends StatelessWidget{

  final double width;
  final double height;
  final ShapeBorder shapeBorder;
  final double borderRadius;

  ShimmerWidget.rectangular({
    this.width=double.infinity,
    this.height,
    this.borderRadius,
  }) : this.shapeBorder = RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(borderRadius)));

  const ShimmerWidget.circular({
    this.width,
    this.height,
    this.borderRadius,
    this.shapeBorder = const CircleBorder(),
  });

@override
Widget build(BuildContext context) => Shimmer.fromColors(
  baseColor: Colors.grey[400],
  highlightColor: Colors.grey[300],
  child: Container(
    padding: EdgeInsets.all(0),
    margin: EdgeInsets.all(0),
    width: width,
    height: height,
    decoration: ShapeDecoration(
            color: Colors.grey[400],
            shape: shapeBorder,
          ),
    ),
  );
}