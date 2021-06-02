import 'dart:async';

import 'package:flutter/services.dart';

class CameraRollUploader {
  static const MethodChannel _channel =
      const MethodChannel('camera_roll_uploader');

  static Future<void> openCameraRoll() async {
    await _channel.invokeMethod('openCameraRoll');
  }
}
