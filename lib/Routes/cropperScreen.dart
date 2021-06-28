import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui';
import 'dart:ui' as ui;
import 'dart:async';
import 'package:simple_edge_detection/edge_detection.dart';
import '../widgets/customPainter.dart';
import 'package:image_picker/image_picker.dart';
import './showCroppedImage.dart';

class MyImageCropper extends StatefulWidget {
  final PickedFile image;

  MyImageCropper({
    required this.image,
  });
  State<StatefulWidget> createState() {
    // print(path);
    return MyImageCropperState();
  }
}

class MyImageCropperState extends State<MyImageCropper> {
  List<Offset> redDotList = [];

  int touched = -1; //will keep track of red dot which we have touched
  ui.Image? image;
  bool isImageLoaded = false;
  int rotation = 0;
  bool cropImage = false;
  Future<Null> init() async {
    print("init");
    image = await loadImage(File(widget.image.path).readAsBytesSync());
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
      redDotList.add(new Offset((tr.dx + tl.dx) / 2, (tr.dy + tl.dy) / 2));
      redDotList.add(tr);
      redDotList.add(new Offset((tr.dx + br.dx) / 2, (tr.dy + br.dy) / 2));
      redDotList.add(br);
      redDotList.add(new Offset((br.dx + bl.dx) / 2, (bl.dy + br.dy) / 2));
      redDotList.add(bl);
      redDotList.add(new Offset((tl.dx + bl.dx) / 2, (bl.dy + tl.dy) / 2));
    });
  }

  points() async {
    List<Offset> list = [];
    list.add(new Offset(10 * (image!.width / MediaQuery.of(context).size.width),
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

  int closestOffSet(Offset click) {
    for (int i = 0; i < redDotList.length; i++) {
      if ((redDotList[i] - click).distance <
          20.0 *
              (image!.width.toDouble()) /
              MediaQuery.of(context).size.width) {
        return i;
      }
    }
    return -1;
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
                        height: MediaQuery.of(context).size.height.toInt()),
                    child: GestureDetector(
                      onPanStart: (details) {
                        touched = closestOffSet(details.localPosition);
                      },
                      onPanUpdate: (details) {
                        Offset click = new Offset(
                            details.localPosition.dx, details.localPosition.dy);
                        setState(() {
                          if (touched != -1) {
                            if (touched % 2 != 0) {
                              Offset diff = (redDotList[touched] - click);
                              Offset back =
                                  (redDotList[(touched - 1) % 8] - diff);
                              Offset forward =
                                  (redDotList[(touched + 1) % 8] - diff);
                              Offset bBack =
                                  (redDotList[(touched - 3) % 8] + back) / 2;
                              Offset fForward =
                                  (redDotList[(touched + 3) % 8] + forward) / 2;

                              if (back.dx > 0 &&
                                  back.dx < image!.width &&
                                  back.dy > 0 &&
                                  back.dy < image!.height &&
                                  click.dx > 0 &&
                                  click.dx < image!.width &&
                                  click.dy > 0 &&
                                  click.dy < image!.height) {
                                redDotList.removeAt((touched - 1) % 8);
                                redDotList.insert((touched - 1) % 8, back);
                              }
                              if (forward.dx > 0 &&
                                  forward.dx < image!.width &&
                                  forward.dy > 0 &&
                                  forward.dy < image!.height &&
                                  click.dx > 0 &&
                                  click.dx < image!.width &&
                                  click.dy > 0 &&
                                  click.dy < image!.height) {
                                redDotList.removeAt((touched + 1) % 8);
                                redDotList.insert((touched + 1) % 8, forward);
                              }
                              if (bBack.dx > 0 &&
                                  bBack.dx < image!.width &&
                                  bBack.dy > 0 &&
                                  bBack.dy < image!.height &&
                                  click.dx > 0 &&
                                  click.dx < image!.width &&
                                  click.dy > 0 &&
                                  click.dy < image!.height) {
                                redDotList.removeAt((touched - 2) % 8);
                                redDotList.insert((touched - 2) % 8, bBack);
                              }
                              if (fForward.dx > 0 &&
                                  fForward.dx < image!.width &&
                                  fForward.dy > 0 &&
                                  fForward.dy < image!.height &&
                                  click.dx > 0 &&
                                  click.dx < image!.width &&
                                  click.dy > 0 &&
                                  click.dy < image!.height) {
                                redDotList.removeAt((touched + 2) % 8);
                                redDotList.insert((touched + 2) % 8, fForward);
                              }
                            } else {
                              Offset back =
                                  (redDotList[(touched + 6) % 8] + click) / 2;
                              Offset forward =
                                  (redDotList[(touched + 2) % 8] + click) / 2;

                              if (back.dx > 0 &&
                                  back.dx < image!.width &&
                                  back.dy > 0 &&
                                  back.dy < image!.height &&
                                  click.dx > 0 &&
                                  click.dx < image!.width &&
                                  click.dy > 0 &&
                                  click.dy < image!.height) {
                                redDotList.removeAt((touched + 7) % 8);
                                redDotList.insert((touched + 7) % 8, back);
                              }
                              if (forward.dx > 0 &&
                                  forward.dx < image!.width &&
                                  forward.dy > 0 &&
                                  forward.dy < image!.height &&
                                  click.dx > 0 &&
                                  click.dx < image!.width &&
                                  click.dy > 0 &&
                                  click.dy < image!.height) {
                                redDotList.removeAt((touched + 1) % 8);
                                redDotList.insert((touched + 1) % 8, forward);
                              }
                            }
                            if (click.dx > 0 &&
                                click.dx < image!.width &&
                                click.dy > 0 &&
                                click.dy < image!.height) {
                              redDotList.removeAt(touched);
                              redDotList.insert(touched, click);
                            }
                          }
                        });
                      },
                      onPanEnd: (details) {
                        touched = -1;
                      },
                    ),
                  ),
                ) //takes a painter so that we can paint the image on the screen
                ,
              )));
    }
    return Column(children: [
      Center(
          child: cropImage
              ? Center(child: Text("Image is successfully Cropped\n\n\nProcessing Image Please Wait",style:TextStyle(color:Colors.white)),)
              : Center(child: Text("Image not loaded yet",style:TextStyle(color:Colors.white)))),
      // ElevatedButton(
      //     child: Text("Next"),
      //     onPressed: () {
      //       // Navigator.push(context,MaterialPageRoute(
      //       //   builder:(context){
      //       //     return Scaffold(
      //       //       appBar:AppBar(title:Text("Cropped Image Display")),
      //       //       body:DisplayImage(image: widget.image,)
      //       //     );
      //       //   }
      //       // ));
      //       imageCache!.clearLiveImages();
      //       imageCache!.clear();
      //       Timer(Duration(milliseconds: 1500), () {
      //         Navigator.of(context).pop();
      //       });
      //     }),
    ]);
  }

  void processPop() async {
    for (int i = 0; i < 4; i++) {
      int index = i * 2;
      redDotList[index] = new Offset(redDotList[index].dx / image!.width,
          redDotList[index].dy / image!.height);
    }
    EdgeDetectionResult edgeDetectionResult = new EdgeDetectionResult(
        topLeft: redDotList[0],
        topRight: redDotList[2],
        bottomLeft: redDotList[6],
        bottomRight: redDotList[4]);
    EdgeDetector().processImage(
        widget.image.path, edgeDetectionResult, rotation * 90.0* - 1);

    setState(() {
      isImageLoaded = false;
    });
    Timer(Duration(milliseconds: 2000), () {
      // Navigator.push(context, MaterialPageRoute(builder: (BuildContext ctx) {
      //   return ShowCropImage(widget.image);
      // }));

      Navigator.popAndPushNamed(context, "Routes/showCroppedImage.dart",arguments:widget.image);
    });
  }

  Widget rotate() {
    return BottomAppBar(
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
              onPressed: () {
                setState(() {
                  rotation--;
                });
              },
              icon: Icon(Icons.rotate_left)),
          IconButton(
              onPressed: () {
                setState(() {
                  rotation++;
                });
              },
              icon: Icon(Icons.rotate_right))
        ],
      ),
    );
  }
  //Custom Painter

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cropping Screen"),
      ),
      body: _buildImage(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () {
          setState(() {
            cropImage = true;
          });
          processPop();
        },
      ),
      bottomNavigationBar: rotate(),
    );
  }
}
