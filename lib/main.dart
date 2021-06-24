import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'Routes/cropperScreen.dart';
import 'Routes/displayImage.dart';
import 'package:permission_handler/permission_handler.dart';

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
  PickedFile? image;
  bool isCropped = false;
  Future<String?> imagePicker(ImageSource source) async {
    PickedFile? _temp = await ImagePicker().getImage(source: source);
    if (_temp != null) {
      return _temp.path;
    }
    return null;
  }

  // void display(){
  //   if(isCropped==true)setState((){});
  // }
  //######BUILD WIDGET STARTS HERE#########//

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Doc Scanner"),
      ),
      body: image == null
          ? Text("Image Will be shown here")
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                DisplayImage(image: image!),
                Container(
                  height: 65,
                  width: 65,
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    child: ClipOval(
                      child: Material(
                        color:Theme.of(context).primaryColor,
                        child: InkWell(
                          
                          child: SizedBox(
                            child: Icon(Icons.check,
                                size:40,
                                color: Theme.of(context).scaffoldBackgroundColor),
                          ),
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              // print(imagePath);
                              return MyImageCropper(image: image!);
                            }));
                            // display();
                          },
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
                                if(await Permission.camera.request().isGranted){
                                String? _localCameraPath =
                                    await imagePicker(ImageSource.camera);
                                // _pickedimage = _imageFromCam;
                                setState(() {
                                  if (_localCameraPath != null)
                                    image = PickedFile(_localCameraPath);
                                });
                                Navigator.of(ctx).pop();
                              }}),
                          ListTile(
                              minVerticalPadding: 7,
                              leading: Icon(
                                Icons.photo_album,
                                size: 38,
                              ),
                              title: Text("Gallery"),
                              onTap: () async {
                                if(await Permission.storage.request().isGranted){
                                String? _localGalleryPath =
                                    await imagePicker(ImageSource.gallery);
                                Navigator.of(ctx).pop();
                                
                                setState(() {
                                  if (_localGalleryPath != null)
                                    image = PickedFile(_localGalleryPath);
                                });
                              }})
                        ],
                      ),
                    ),
                  );
                });
          }),
    );
  }
}
