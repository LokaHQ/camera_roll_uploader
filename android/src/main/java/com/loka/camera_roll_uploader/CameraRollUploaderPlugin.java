package com.loka.camera_roll_uploader;

import android.app.Activity;
import android.content.Context;

import androidx.annotation.NonNull;

import java.util.HashMap;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;


/** CameraRollUploaderPlugin */
public class CameraRollUploaderPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {

  private MethodChannel channel;
  private Context applicationContext;
  private Activity applicationActivity;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    applicationContext = flutterPluginBinding.getApplicationContext() ;
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "camera_roll_uploader");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull final Result result) {
    final HashMap<String, Object> arguments = call.arguments();

    if (call.method.equals("fetch_photos_camera_roll")) {
      final int limit = (int)arguments.get("limit");
      final int cursor = (int)arguments.get("cursor");
      new CameraRollReader(applicationContext, applicationActivity, result).fetchGalleryImages(limit, cursor);
    }
    else if (call.method.equals("select_photo_camera_roll")) {
      int index = (int)arguments.get("index");
      new CameraRollReader(applicationContext, applicationActivity, result).selectPhoto(index);
    }
    else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    applicationActivity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

  }

  @Override
  public void onDetachedFromActivity() {

  }
}
