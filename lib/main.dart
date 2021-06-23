import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'Routes/cropperScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Document Scanner",
      home: LandingPage(),
    );
  }
}

class LandingPage extends StatefulWidget {
  State<StatefulWidget> createState() {
    return LandingPageState();
  }
}

class LandingPageState extends State<LandingPage> {
  // PickedFile? _pickedimage, _imageFromCam, _imageFromGallery;
  File? imageFile;
  String? imagePath;
  Future<String?> imagePicker(ImageSource source) async {
    PickedFile? _temp = await ImagePicker().getImage(source: source);
    if (_temp != null) {
      return _temp.path;
    }
    return null;
  }
  //######BUILD WIDGET STARTS HERE#########//

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Doc Scanner"),
      ),
      body: imagePath == null
          ? Text("Image Will be shown here")
          : SingleChildScrollView(
              child: Center(
                child: Column(children: [
                  Image.file(File(imagePath!)),
                  IconButton(
                    icon: Icon(Icons.check_circle),
                    onPressed: () {
                      Navigator.push(context,MaterialPageRoute(builder:(context){
                        print(imagePath);
                        return MyImageCropper(imagePath!);
                      }));
                    },
                  )
                ]),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext ctx) {
                  return Container(
                    color: Color(0xFF737373),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          )),
                      height: 120,
                      child: Column(
                        children: [
                          ListTile(
                              leading: Icon(
                                Icons.camera,
                                size: 38,
                              ),
                              title: Text("Camera"),
                              onTap: () async {
                                //Image Picker
                                String? _localCameraPath =
                                    await imagePicker(ImageSource.camera);
                                // _pickedimage = _imageFromCam;
                                setState(() {
                                  if (_localCameraPath != null)
                                    imagePath = _localCameraPath;
                                });
                                Navigator.of(ctx).pop();
                              }),
                          ListTile(
                              minVerticalPadding: 7,
                              leading: Icon(
                                Icons.photo_album,
                                size: 38,
                              ),
                              title: Text("Gallery"),
                              onTap: () async {
                                String? _localGalleryPath =
                                    await imagePicker(ImageSource.gallery);
                                Navigator.of(ctx).pop();

                                setState(() {
                                  if (_localGalleryPath != null)
                                    imagePath = _localGalleryPath;
                                });
                              })
                        ],
                      ),
                    ),
                  );
                });
          }),
    );
  }
}
