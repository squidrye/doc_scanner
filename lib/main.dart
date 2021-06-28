import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'Routes/cropperScreen.dart';
import 'Routes/showCroppedImage.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.transparent,
          
          textTheme: TextTheme(
            headline6:TextStyle(
                  fontSize: 24,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w700,
                  color: Colors.black) ,
              bodyText2: TextStyle(
                  fontSize: 24,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
              bodyText1: TextStyle(
                  fontSize: 24,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w700,
                  color: Colors.white),),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.teal[900]!,
            textTheme: TextTheme(headline6: TextStyle(color: Colors.black,fontWeight:FontWeight.bold,fontSize: 24)),
          )),
      title: "Document Scanner",
      home: LandingPage(),
      onGenerateRoute: routes,
    );
  }
}

PickedFile? image;
Route routes(RouteSettings settings) {
  if (settings.name == 'Routes/cropperScreen.dart') {
    return MaterialPageRoute(builder: (context) {
      return MyImageCropper(image: image!);
    });
  } else if (settings.name == 'Routes/showCroppedImage.dart') {
    return MaterialPageRoute(builder: (context) {
      return ShowCropImage(image!);
    });
  } else
    return MaterialPageRoute(builder: (context) {
      return ShowCropImage(image!);
    });
}

class LandingPage extends StatefulWidget {
  State<StatefulWidget> createState() {
    return LandingPageState();
  }
}

class LandingPageState extends State<LandingPage> {
  // PickedFile? _pickedimage, _imageFromCam, _imageFromGallery;
  File? imageFile;

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
    return Container(
      decoration: BoxDecoration(
        // gradient: LinearGradient(
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        //   // Colors.purple
        //   colors: [Colors.black38,Colors.black12],
        // ),
        image: DecorationImage(
          image: AssetImage("./assets/images/download.jpg"),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Doc Scanner"),
        ),
        body: Center(
          child: InkWell(
            borderRadius: BorderRadius.all(Radius.circular(23)),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.width * 0.7,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.teal[900]!, Colors.purple[600]!],
                ),
                // border: Border.all(style: BorderStyle.solid, width: 2),
                borderRadius: BorderRadius.all(Radius.circular(23)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("Click Here to add image"),
                  Icon(
                    Icons.add_a_photo_rounded,
                    size: 64,
                  ),
                ],
              ),
            ),
            onTap: () {
              showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext ctx) {
                    return Container(
                      color: Colors.black,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.teal[900],
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            )),
                        height: MediaQuery.of(context).size.height*0.2,
                        child: Column(
                          children: [
                            ListTile(
                                leading: Icon(
                                  Icons.camera,
                                  size: 50,
                                  color:Colors.black,
                                ),
                                title: Text("Camera",style: Theme.of(context).textTheme.headline6),
                                onTap: () async {
                                  //Image Picker
                                  if (await Permission.camera
                                      .request()
                                      .isGranted) {
                                    String? _localCameraPath =
                                        await imagePicker(ImageSource.camera);
                                    // _pickedimage = _imageFromCam;
                                    setState(() {
                                      if (_localCameraPath != null) {
                                        image = PickedFile(_localCameraPath);
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (BuildContext ctx) {
                                          return MyImageCropper(
                                              image:
                                                  image!); //new Page where we can see the image
                                        }));
                                      }
                                    });
                                    // Navigator.of(ctx).pop();
                                  }
                                }),
                            ListTile(
                                minVerticalPadding: 30,
                                leading: Icon(
                                  Icons.photo_library,
                                  size: 50,
                                  color:Colors.black,
                                ),
                                title: Text("Gallery",style: Theme.of(context).textTheme.headline6),
                                onTap: () async {
                                  if (await Permission.storage
                                      .request()
                                      .isGranted) {
                                    String? _localGalleryPath =
                                        await imagePicker(ImageSource.gallery);
                                    // Navigator.of(ctx).pop();
                                    setState(() {
                                      if (_localGalleryPath != null) {
                                        image = PickedFile(_localGalleryPath);
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (BuildContext ctx) {
                                          return MyImageCropper(image: image!);
                                        }));
                                      }
                                    });
                                  }
                                })
                          ],
                        ),
                      ),
                    );
                  });
            },
          ),
        ),
      ),
    );
  }
}
