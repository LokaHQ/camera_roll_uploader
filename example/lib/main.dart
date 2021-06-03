import 'package:flutter/material.dart';
import 'package:camera_roll_uploader/camera_roll_uploader.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  CameraRollViewOptions viewOptions;

  @override
  void initState() {
    super.initState();

    viewOptions = CameraRollViewOptions();
    viewOptions.bgColor = '000000';
    viewOptions.backButtonColor = 'FFFFFF';
    viewOptions.nextButtonColor = '007AFF';
    viewOptions.iosBackButtonImage = 'xmark';
    viewOptions.title = 'Select Picture';
    viewOptions.titleColor = 'FFFFFF';
    viewOptions.itemsPerRow = 4;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: TextButton(
            onPressed: () {
              CameraRollUploader.openCameraRoll();
            },
            child: Text('Open Camera Roll'),
          ),
        ),
      ),
    );
  }
}
