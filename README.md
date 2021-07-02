# Camera Roll Uploader

## A flutter plugin to pick an image from iOS camera roll or Android image gallery. Layout on flutter side, business logic on native side.

![v1](https://user-images.githubusercontent.com/14978705/124298979-30142480-db5d-11eb-8f57-127b4d47e230.png)

Made with 💙 by **Loka Inc.** [https://loka.com](https://loka.com)

<hr>

### Description

You just need to add `CameraRollUploader()` in any place you want in your screen or you can open it modally like any other picker

```
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (BuildContext context) {
      return Scaffold(
        body: CameraRollUploader(),
      );
    },
  ),
);
```

- It can be used as an embedded widget wherever you want, so you can use your own AppBar's actions buttons or you can open it modally as any other picker.

- You can control wether the image is ready or not, for example, when it's stored on iCloud and should be downloaded from there first.

- Background color can be changed by changing the color of it parent widget.

- **Permissions** requests are already handled natively, you don't need to ask for them, the plugin do it itself, just add

on Android manifest...

```
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.ACCESS_MEDIA_LOCATION"/>
```

and on iOS Info.plist

```
<key>NSPhotoLibraryUsageDescription</key>
<string>Your permissions explanation here</string>
```

<hr>

![screenshot](https://user-images.githubusercontent.com/14978705/123599875-5ef56800-d7f6-11eb-888c-76cdbd3280da.jpg)

## Usage example

```
import 'dart:io';

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
            isDownloadingImage: (downloading) {
              print("downloading $downloading");
            },
            selectedImageCallback: (imagePath) {
              print("imagePath $imagePath");
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
              (Platform.isIOS)
                  ? Padding(
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
                    )
                  : Container(
                      width: 0.0,
                      height: 0.0,
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
