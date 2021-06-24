import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class DisplayImage extends StatefulWidget {
  final PickedFile image;

  DisplayImage({required this.image});
  State<StatefulWidget> createState() {
    return DisplayImageState();
  }
}

class DisplayImageState extends State<DisplayImage> {
  
  Widget build(BuildContext context) {
    return RotatedBox(
      quarterTurns: 0,
      child: FittedBox(
        fit:BoxFit.contain,
        child: SizedBox(
          height: MediaQuery.of(context).size.height/1.35,
          width: MediaQuery.of(context).size.width/1,
                  child: Center(
            child: Image.file(File(widget.image.path)),
          ),
        ),
      ),
    );
  }
}
