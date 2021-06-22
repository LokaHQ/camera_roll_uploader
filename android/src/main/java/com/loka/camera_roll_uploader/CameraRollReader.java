package com.loka.camera_roll_uploader;

import android.app.Activity;
import android.content.Context;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.provider.MediaStore;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import java.io.ByteArrayOutputStream;
import java.util.ArrayList;

import io.flutter.plugin.common.MethodChannel.Result;

import static android.Manifest.permission.ACCESS_MEDIA_LOCATION;
import static android.Manifest.permission.READ_EXTERNAL_STORAGE;
import static android.content.pm.PackageManager.PERMISSION_DENIED;
import static android.content.pm.PackageManager.PERMISSION_GRANTED;

//define callback interface
interface PermissionsGrantedCallback {
    void onPermissionsGranted();
}

public class CameraRollReader {

    private final Context applicationContext;
    private final Activity applicationActivity;
    private final int READ_EXTERNAL_STORAGE_CODE = 1010101;
    private final int ACCESS_MEDIA_LOCATION_CODE = 1010102;
    private final Result result;

    CameraRollReader(Context context, Activity activity, Result result) {
        this.applicationContext = context;
        this.applicationActivity = activity;
        this.result = result;
    }

    private void checkForPermissions(final PermissionsGrantedCallback permissionsGrantedCallback) {
        final ArrayList<Integer> permissionsGranted = new ArrayList<>();

        new ActivityCompat.OnRequestPermissionsResultCallback() {
            @Override
            public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
                if (requestCode == READ_EXTERNAL_STORAGE_CODE) {
                    if (grantResults.length > 0 && grantResults[0] == PERMISSION_GRANTED) {
                        permissionsGranted.add(READ_EXTERNAL_STORAGE_CODE);
                    }
                }
                if (requestCode == ACCESS_MEDIA_LOCATION_CODE) {
                    if (grantResults.length > 0 && grantResults[0] == PERMISSION_GRANTED) {
                        permissionsGranted.add(ACCESS_MEDIA_LOCATION_CODE);
                    }
                }
                if (permissionsGranted.size() > 1) { // TODO: should be == 2 if android.os.Build.VERSION_CODES.Q
                    permissionsGrantedCallback.onPermissionsGranted();
                }
            }
        };

        int readExternalStorage = ContextCompat.checkSelfPermission(applicationContext, READ_EXTERNAL_STORAGE);
        Log.e("READ_EXTERNAL_STORAGE", String.valueOf(readExternalStorage));
        if (readExternalStorage == PERMISSION_DENIED) {
            ActivityCompat.requestPermissions(applicationActivity, new String[] { READ_EXTERNAL_STORAGE }, READ_EXTERNAL_STORAGE_CODE);
        } else {
            permissionsGrantedCallback.onPermissionsGranted();
        }

//        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
//
//            int accessMediaLocation = ContextCompat.checkSelfPermission(applicationContext, ACCESS_MEDIA_LOCATION);
//            Log.e("ACCESS_MEDIA_LOCATION", String.valueOf(accessMediaLocation));
//            if (accessMediaLocation == PERMISSION_DENIED) {
//
//                ActivityCompat.requestPermissions(applicationActivity, new String[] { ACCESS_MEDIA_LOCATION }, ACCESS_MEDIA_LOCATION_CODE);
//            }
//        }
    }

    public void fetchGalleryImages(final int limit, final int cursor) {
        checkForPermissions(new PermissionsGrantedCallback() {
            @Override
            public void onPermissionsGranted() {
                getImages(limit, cursor);
            }
        });
    }

    private void getImages(int limit, int cursor) {
        Log.e("get images", "limit " + String.valueOf(limit) + ", cursor " + String.valueOf(cursor));
        ArrayList<String> dataImagesArray = new ArrayList<>();

        final String[] columns = {MediaStore.Images.Media.DATA,
                                  MediaStore.Images.Media._ID};
        final String orderBy = MediaStore.Images.Media.DATE_ADDED;

        Cursor imageCursor = applicationContext.getContentResolver().query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                columns,
                null,
                null,
                orderBy + " DESC");

        Log.e("fetched", imageCursor.getCount() + " images");
        for (int i = cursor; i < (limit + cursor) - 1; i++) {
            if (i == imageCursor.getCount()) {
                break;
            }
            imageCursor.moveToPosition(i);
            int dataColumnIndex = imageCursor.getColumnIndex(MediaStore.Images.Media.DATA);
            dataImagesArray.add(imageCursor.getString(dataColumnIndex));
        }

        imageCursor.close();
        result.success(dataImagesArray);
    }

    public void selectPhoto(final int index) {
        Log.e("index", String.valueOf(index));

        final String[] columns = {MediaStore.Images.Media.DATA, MediaStore.Images.Media._ID};
        final String orderBy = MediaStore.Images.Media.DATE_ADDED;

        Cursor imageCursor = applicationContext.getContentResolver().query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                columns,
                null,
                null,
                orderBy + " DESC");

        imageCursor.moveToPosition(index);
        int dataColumnIndex = imageCursor.getColumnIndex(MediaStore.Images.Media.DATA);
        result.success(imageCursor.getString(dataColumnIndex));
        imageCursor.close();
    }
}
