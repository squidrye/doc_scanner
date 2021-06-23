import 'package:flutter/material.dart';

class MyImageCropper extends StatefulWidget {
  final String path;
  MyImageCropper(this.path);
  State<StatefulWidget> createState() {
    return MyImageCropperState();
  }
}

class MyImageCropperState extends State<MyImageCropper> {
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Cropping Screen"),
        ),
        body: Center(child: Text("Image cropper will be built here")));
  }
}
