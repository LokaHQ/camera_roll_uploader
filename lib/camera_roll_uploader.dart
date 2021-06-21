import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CameraRollUploader extends StatefulWidget {
  CameraRollUploader({this.limit = 21, this.selectedImageCallback});
  final int limit;
  final Function(String)? selectedImageCallback;

  @override
  _CameraRollUploaderState createState() => _CameraRollUploaderState();
}

class _CameraRollUploaderState extends State<CameraRollUploader> {
  static const MethodChannel _channel =
      const MethodChannel('camera_roll_uploader');

  List<Uint8List> _bytesImages = [];
  var _scrollController = ScrollController();
  var _currentCursor = 0;
  String? _selectedImagePath;
  Uint8List? _selectedBytes;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchImages(_currentCursor);
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        if (_scrollController.position.pixels != 0) {
          _fetchImages(_currentCursor);
        }
      }
    });
  }

  Future<void> _fetchImages(int cursor) async {
    print("current cursor $cursor");
    List<dynamic> dataImagesList = await _channel.invokeMethod(
      'fetch_photos_camera_roll',
      {
        'limit': widget.limit,
        'cursor': cursor,
      },
    );
    for (var data in dataImagesList) {
      _bytesImages.add(Uint8List.fromList(data));
    }
    _currentCursor += dataImagesList.length;
    if (cursor == 0) {
      _selectImage(0);
    }
    setState(() {});
  }

  Future<void> _selectImage(int index) async {
    setState(() {
      _selectedImagePath = null;
      _isLoading = true;
      _selectedBytes = _bytesImages[index];
    });
    _selectedImagePath = await _channel.invokeMethod(
      'select_photo_camera_roll',
      {
        'index': index,
      },
    );
    setState(() {
      _isLoading = false;
    });
    try {
      this.widget.selectedImageCallback!(_selectedImagePath!);
    } catch (e) {
      print(
          "there's no image path because selectedImageCallback(String imagePath) is null");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Stack(
                    alignment: Alignment.center,
                    fit: StackFit.expand,
                    children: [
                      _selectedBytes != null
                          ? Image.memory(
                              _selectedBytes!,
                              fit: BoxFit.cover,
                            )
                          : _null,
                      _selectedImagePath != null
                          ? Image.file(
                              File(_selectedImagePath!),
                              fit: BoxFit.cover,
                            )
                          : _null,
                    ],
                  ),
                ),
                _isLoading ? LoadingBar() : _null,
              ],
            ),
          ),
          Expanded(
            child: Container(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                controller: _scrollController,
                physics: ClampingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  mainAxisSpacing: 5.0,
                  crossAxisSpacing: 5.0,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () => _selectImage(index),
                    child: Image.memory(
                      _bytesImages[index],
                      fit: BoxFit.cover,
                    ),
                  );
                },
                itemCount: _bytesImages.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget get _null {
    return Container(
      width: 0.0,
      height: 0.0,
    );
  }
}

class LoadingBar extends StatelessWidget {
  const LoadingBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(
          minHeight: 5.0,
        ),
      ],
    );
  }
}
