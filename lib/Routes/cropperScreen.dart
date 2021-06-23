import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:simple_edge_detection/edge_detection.dart';
import '../widgets/customPainter.dart';

class MyImageCropper extends StatefulWidget {
  final String path;
  MyImageCropper(this.path);
  State<StatefulWidget> createState() {
    print(path);
    return MyImageCropperState();
  }
}

class MyImageCropperState extends State<MyImageCropper> {
  List<Offset> redDotList = [];
  bool cropImage = false;
  int touched = -1; //will keep track of red dot which we have touched
  ui.Image? image;
  bool isImageLoaded = false;
  int rotation = 0;

  Future<Null> init() async {
    print("init");
    image = await loadImage(File(widget.path).readAsBytesSync());
  }

  initState() {
    super.initState();
    init();
  }

  Future<ui.Image> loadImage(List<int> img) async {
    final Completer<ui.Image> completer =
        new Completer(); //returns a promise as ie if image gets loaded it returns image else it returns a promise that once image is selected it will be returned
    ui.decodeImageFromList(Uint8List.fromList(img), (ui.Image img) {
      setState(() {
        isImageLoaded = true;
      });
      return completer.complete(img);
    });
    return completer.future;
  }

  _openCropper() async {
    List<Offset> list = await points();
    Offset tl, tr, br, bl;
    setState(() {
      tl = list[0];
      tr = list[1];
      br = list[2];
      bl = list[3];
      redDotList.add(tl);
      redDotList.add(new Offset((tr.dx + tl.dx) / 2,(tr.dy+tl.dy)/2));
      redDotList.add(tr);
      redDotList.add(new Offset((tr.dx + br.dx) / 2,(tr.dy+br.dy)/2));
      redDotList.add(br);
      redDotList.add(new Offset((br.dx + bl.dx) / 2,(bl.dy+br.dy)/2));
      redDotList.add(bl);
      redDotList.add(new Offset((tl.dx + bl.dx) / 2,(bl.dy+tl.dy)/2));
    });
  }

  points() async {
    List<Offset> list = [];
    list.add(new Offset(
        10 * (image!.width / MediaQuery.of(context).size.width),
        10 * (image!.height / MediaQuery.of(context).size.height)));

    list.add(new Offset(
       (image!.width.toDouble()) -
            (10 * (image!.width / MediaQuery.of(context).size.width)),
        10 * (image!.height / MediaQuery.of(context).size.height)));

    list.add(new Offset(
        image!.width.toDouble() -
            (10 * (image!.width / MediaQuery.of(context).size.width)),
        image!.height.toDouble() -
            10 * (image!.height / MediaQuery.of(context).size.height)));

    list.add(new Offset(
        (10 * (image!.width / MediaQuery.of(context).size.width)),
        image!.height.toDouble() -
            10 * (image!.height / MediaQuery.of(context).size.height)));

    print(list);
    return list;
  }

  Widget _buildImage() {
    if (isImageLoaded) {
      if (redDotList.length == 0) {
        _openCropper();
      }
      print(redDotList);
      return Center(
          child: RotatedBox(
              quarterTurns: rotation,
              child: FittedBox(
                child: SizedBox(
                    height: image!.height.toDouble(),
                    width: image!.width.toDouble(),
                    child: new CustomPaint(
                        painter: MyImagePainter(
                            image: image,
                            offsetlist: redDotList,
                            crop: cropImage,
                            context: context,
                            height: MediaQuery.of(context).size.height.toInt()))) //takes a painter so that we can paint the image on the screen
                ,
              )));
    }
    return Center(child: Text("Image not loaded yet muda muda muda"));
  }

  //Custom Painter

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Cropping Screen"),
        ),
        body: _buildImage());
  }
}
