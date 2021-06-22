import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class CameraRollUploader extends StatefulWidget {
  CameraRollUploader({this.limit = 21, this.selectedImageCallback});
  final int limit;
  final Function(String)? selectedImageCallback;

  @override
  _CameraRollUploaderState createState() => _CameraRollUploaderState();
}

class _CameraRollUploaderState extends State<CameraRollUploader>
    with WidgetsBindingObserver {
  static const MethodChannel _channel =
      const MethodChannel('camera_roll_uploader');

  List<Uint8List> _bytesImages = [];
  List<String> _pathImages = [];

  var _gridViewScrollController = ScrollController();
  var _headerScrollController = ScrollController();
  var _currentCursor = 0;
  String? _selectedImagePath;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _fetchImages(_currentCursor);
    _gridViewScrollController.addListener(_gridViewScrollControllerListener);
    _headerScrollController.addListener(_headerScrollControllerListener);
  }

  void _gridViewScrollControllerListener() {
    if (_gridViewScrollController.position.atEdge) {
      if (_gridViewScrollController.position.pixels != 0) {
        _fetchImages(_currentCursor);
      } else {
        _headerScrollController.animateTo(
          0,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeIn,
        );
      }
    }
  }

  void _headerScrollControllerListener() {
    if (_headerScrollController.offset >=
        (MediaQuery.of(context).size.width / 1.5)) {
      _headerScrollController.jumpTo((MediaQuery.of(context).size.width / 1.5));
    }
  }

  Future<void> _fetchImages(int cursor) async {
    List<dynamic> dataImagesList = await _channel.invokeMethod(
      'fetch_photos_camera_roll',
      {
        'limit': widget.limit,
        'cursor': cursor,
      },
    );
    if (Platform.isIOS) {
      for (var data in dataImagesList) {
        _bytesImages.add(Uint8List.fromList(data));
      }
    } else {
      for (var path in dataImagesList) {
        _pathImages.add(path);
      }
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
          "there's no image path because selectedImageCallback(String imagePath) is null at index $index");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("resumed");
      var _currentCursor = 0;
      _fetchImages(_currentCursor);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      physics: NeverScrollableScrollPhysics(),
      controller: _headerScrollController,
      headerSliverBuilder: (BuildContext context, bool boxIsScrolled) {
        // print(boxIsScrolled);
        return <Widget>[
          SliverToBoxAdapter(
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: _selectedImagePath != null
                        ? Image.file(
                            File(_selectedImagePath!),
                            fit: BoxFit.cover,
                          )
                        : _null,
                  ),
                  _isLoading ? LoadingBar() : _null,
                ],
              ),
            ),
          ),
        ];
      },
      body: Container(
        child: GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          controller: _gridViewScrollController,
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
              child: Platform.isIOS
                  ? Image.memory(
                      _bytesImages[index],
                      fit: BoxFit.cover,
                    )
                  : Image.file(
                      File(_pathImages[index]),
                      fit: BoxFit.cover,
                    ),
            );
          },
          itemCount: Platform.isIOS ? _bytesImages.length : _pathImages.length,
        ),
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
