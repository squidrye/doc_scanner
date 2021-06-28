import 'package:flutter/material.dart';
import './displayImage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:pdf/widgets.dart' as pw;

class ShowCropImage extends StatefulWidget {
  final PickedFile image;
  ShowCropImage(this.image);
  State<StatefulWidget> createState() {
    return ShowCropImageState();
  }
}

class ShowCropImageState extends State<ShowCropImage> {
  bool save = false;
  Widget build(BuildContext context) {
    final pdf = pw.Document();

    String val = DateTime.now().millisecond.toString();
    String? dirPath;
    void _savePdf() async {
      var imageFile = pw.MemoryImage(File(widget.image.path).readAsBytesSync());
      pdf.addPage(pw.Page(build: (pw.Context context) {
        return pw.Center(child: pw.Image(imageFile));
      }));
      final file = File("$dirPath/fil$val.pdf");
      await file.writeAsBytes(await pdf.save());
      setState(() {
        save = true;
      });
    }

    Future _createFolder() async {
      final directory = Directory("storage/emulated/0/Flutter_Scanner");
      if (await directory.exists()) {
        print("Exist");
        // var imgFile=new File("${directory.path}/image_$rand")
        dirPath = directory.path;
        _savePdf();
      } else {
        print("creating");
        directory.create();
        dirPath = directory.path;
        _savePdf();
      }
    }

    Widget orCond() {
      return Column(children: [
        DisplayImage(widget.image),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FloatingActionButton(
              child: Icon(Icons.refresh),
              onPressed: () {
                imageCache!.clearLiveImages();
                imageCache!.clear();
                Navigator.pop(context);
              },
            ),
            FloatingActionButton(
              child: Icon(Icons.download),
              onPressed: () async {
                await _createFolder();
                Timer(Duration(milliseconds: 1200), () {
                  Navigator.pop(context);
                });
              },
            )
          ],
        ),
      ]);
    }

    return Scaffold(
      appBar: AppBar(title: Text("Display")),
      body: save
          ? Center(
              child: Text("Image Saved at Internal Storage/Flutter_Scanner"))
          : orCond(),
    );
  }
}
