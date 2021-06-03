import 'dart:async';

import 'package:flutter/services.dart';

class CameraRollViewOptions {
  String bgColor = "FFFFFF";
  String title = "";
  String titleColor = "000000";
  String iosBackButtonImage = "arrow.backward.circle";
  String androidBackButtonImage = "arrow.backward.circle";
  String backButtonColor = "2D3640";
  String nextButtonColor = "006D77";
  int itemsPerRow = 3;

  Map<String, dynamic> toJson() {
    return {
      'bgColor': bgColor,
      'title': title,
      'titleColor': titleColor,
      'iosBackButtonImage': iosBackButtonImage,
      'androidBackButtonImage': androidBackButtonImage,
      'backButtonColor': backButtonColor,
      'nextButtonColor': nextButtonColor,
      'itemsPerRow': itemsPerRow,
    };
  }
}

class CameraRollUploader {
  static const MethodChannel _channel =
      const MethodChannel('camera_roll_uploader');

  static Future<void> openCameraRoll([CameraRollViewOptions options]) async {
    var viewOptions = options?.toJson() ?? CameraRollViewOptions().toJson();
    await _channel.invokeMethod('openCameraRoll', viewOptions);
  }
}
