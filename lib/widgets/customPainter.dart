
import 'package:flutter/rendering.dart';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';


class MyImagePainter extends CustomPainter{
 ui.Image? image;
 int? height;
  bool crop=false;
  BuildContext? context;
 double? angle=1.5686;
  List<Offset> offsetlist=[];
 MyImagePainter({ this.image,required  this.offsetlist,  this.height, required this.crop,  this.context});
 
  @override 
  void paint(Canvas canvas, Size size){
    if(image!=null){
   canvas.drawImage(image!, new Offset(0.0,0.0),new Paint());
   if(offsetlist.length>0 && !crop){
   canvas.drawPoints(PointMode.polygon, offsetlist,Paint()
   ..strokeWidth=3.0
   ..color=Colors.red
   ..strokeCap=StrokeCap.round,
   
   );
   canvas.drawLine(offsetlist[0],offsetlist[offsetlist.length-1],Paint()
   ..strokeWidth=3.0
   ..color=Colors.red
   ..strokeCap=StrokeCap.round
   
   );
   canvas.drawPoints(PointMode.points,offsetlist,Paint()
   ..strokeWidth=30
   ..strokeCap=StrokeCap.round
   ..color=Colors.red
   );
   }
  print("got in");
  }}
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate){
  return true;
  }
}