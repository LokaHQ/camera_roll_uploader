package com.loka.camera_roll_uploader;

import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.provider.MediaStore;
import android.util.Log;

import androidx.annotation.NonNull;

import java.util.ArrayList;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** CameraRollUploaderPlugin */
public class CameraRollUploaderPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private Context applicationContext;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    applicationContext = flutterPluginBinding.getApplicationContext() ;
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "camera_roll_uploader");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("fetch_photos_camera_roll")) {
//      result.success("Android " + android.os.Build.VERSION.RELEASE);
      Log.e("fetch",fetchGalleryImages(applicationContext).size() + " images" );
//      fetchGalleryImages2(applicationContext);
    } else {
      result.notImplemented();
    }
  }

  public static ArrayList<String> fetchGalleryImages(Context context) {
    ArrayList<String> galleryImageUrls;
    final String[] columns = {MediaStore.Images.Media.DATA, MediaStore.Images.Media._ID}; //get all columns of type images
    final String orderBy = MediaStore.Images.Media.DEFAULT_SORT_ORDER;

//    Cursor imageCursor = context.managedQuery(
//            MediaStore.Images.Media.EXTERNAL_CONTENT_URI, columns, null,
//            null, orderBy + " DESC"); //get all data in Cursor by sorting in DESC order
    Cursor imageCursor = context.getContentResolver().query(
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
            columns,
            null,
            null,
            orderBy + " DESC");

    galleryImageUrls = new ArrayList<>();

    for (int i = 0; i < imageCursor.getCount(); i++) {
      imageCursor.moveToPosition(i);
      int dataColumnIndex = imageCursor.getColumnIndex(MediaStore.Images.Media.DATA); //get column index
      galleryImageUrls.add(imageCursor.getString(dataColumnIndex)); //get Image from column index
    }

    imageCursor.close();
    return galleryImageUrls;
  }

  public static void fetchGalleryImages2(Context context) {
    // which image properties are we querying
    String[] projection = new String[] {
            MediaStore.Images.Media._ID,
            MediaStore.Images.Media.BUCKET_DISPLAY_NAME,
            MediaStore.Images.Media.DATE_TAKEN
    };

// content:// style URI for the "primary" external storage volume
    Uri images = MediaStore.Images.Media.EXTERNAL_CONTENT_URI;

// Make the query.
    Cursor cur = context.getContentResolver().query(images,
            projection, // Which columns to return
            null,       // Which rows to return (all rows)
            null,       // Selection arguments (none)
            null        // Ordering
    );

    Log.i("ListingImages"," query count=" + cur.getCount());

    if (cur.moveToFirst()) {
      String bucket;
      String date;
      int bucketColumn = cur.getColumnIndex(
              MediaStore.Images.Media.BUCKET_DISPLAY_NAME);

      int dateColumn = cur.getColumnIndex(
              MediaStore.Images.Media.DATE_TAKEN);

      do {
        // Get the field values
        bucket = cur.getString(bucketColumn);
        date = cur.getString(dateColumn);

        // Do something with the values.
        Log.i("ListingImages", " bucket=" + bucket
                + "  date_taken=" + date);
      } while (cur.moveToNext());

    }
  }


  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
