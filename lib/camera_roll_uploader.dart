
import 'dart:async';

import 'package:flutter/services.dart';

class CameraRollUploader {
  static const MethodChannel _channel =
      const MethodChannel('camera_roll_uploader');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
