# camera_roll_uploader

A flutter plugin to pick an image from iOS camera roll or Android image gallery.

![screenshot](https://user-images.githubusercontent.com/14978705/123599875-5ef56800-d7f6-11eb-888c-76cdbd3280da.jpg)


## Usage example

```
import 'package:camera_roll_uploader/camera_roll_uploader.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (BuildContext context) => Scaffold(
          appBar: AppBar(
            title: Text("Embedded Camera Roll Picker"),
          ),
          body: CameraRollUploader(
            selectedImageCallback: (imagePath) {
              print(imagePath);
              // you can create an Image with this local path
              // Image.file(
              //   File(imagePath!),
              //   fit: BoxFit.cover,
              // )
            },
          ),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: FloatingActionButton(
                    heroTag: "modal",
                    child: Text(
                      "SHOW\nMODAL",
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () => _openPicker(context),
                  ),
                ),
              ),
              SizedBox(
                width: 80,
                height: 80,
                child: FloatingActionButton(
                  heroTag: "push",
                  backgroundColor: Colors.black,
                  child: Text(
                    "SHOW\nPUSH",
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () => _openPicker(context, isModal: false),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _openPicker(BuildContext context, {bool isModal = true}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: isModal,
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(),
            body: CameraRollUploader(),
          );
        },
      ),
    );
  }
}
```
