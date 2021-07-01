import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class CameraRollUploader extends StatefulWidget {
  CameraRollUploader({
    this.limit = 21,
    this.selectedImageCallback,
    this.isDownloadingImage,
  });
  final int limit;
  final Function(String)? selectedImageCallback;
  final Function(bool)? isDownloadingImage;

  @override
  _CameraRollUploaderState createState() => _CameraRollUploaderState();
}

class _CameraRollUploaderState extends State<CameraRollUploader> {
  static const MethodChannel _channel =
      const MethodChannel('camera_roll_uploader');

  List<Uint8List> _bytesImages = [];
  List<String> _pathImages = [];
  bool _animating = false;

  var _gridViewScrollController = ScrollController();
  var _headerScrollController = ScrollController();
  var _currentCursor = 0;
  String? _selectedImagePath;
  Uint8List? _selectedBytes;

  var _isLoading = false;
  late Function(bool) _isDownloadingImage;
  late Function(String) _selectedImageCallback;

  @override
  void initState() {
    super.initState();
    _isDownloadingImage = widget.isDownloadingImage ??
        (value) {
          print("downloading $value");
        };
    _selectedImageCallback = widget.selectedImageCallback ??
        (imagePath) {
          print("imagePath $imagePath");
        };
    _fetchImages(_currentCursor);
    _gridViewScrollController.addListener(_gridViewScrollControllerListener);
    _headerScrollController.addListener(_headerScrollControllerListener);
  }

  void _animateTo({bool half = false}) {
    if (_animating) return;
    _animating = true;
    _headerScrollController
        .animateTo(half ? (MediaQuery.of(context).size.width / 2) : 0,
            duration: Duration(milliseconds: 200), curve: Curves.linear)
        .then((value) => _animating = false);
  }

  void _gridViewScrollControllerListener() {
    if (_gridViewScrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      _animateTo(half: true);
    }
    if (_gridViewScrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      _animateTo(half: false);
    }
    if (_gridViewScrollController.position.atEdge) {
      if (_gridViewScrollController.position.pixels != 0) {
        _fetchImages(_currentCursor);
      } else {
        _animateTo(half: false);
      }
    }
  }

  void _headerScrollControllerListener() {
    if (_headerScrollController.offset >=
        (MediaQuery.of(context).size.width / 2)) {
      _headerScrollController.jumpTo((MediaQuery.of(context).size.width / 2));
    }
  }

  Future<void> _fetchImages(int cursor) async {
    print(widget.limit);
    if (widget.limit < 21) {
      throw Exception("`limit` parameter should be greater than 21 or deleted");
    }
    try {
      List<dynamic> dataImagesList = await _channel.invokeMethod(
        'fetch_photos_camera_roll',
        {
          'limit': widget.limit,
          'cursor': cursor,
        },
      );
      print("${dataImagesList.length} images");
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
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _selectImage(int index) async {
    _animateTo(half: false);
    setState(() {
      _selectedImagePath = null;
      _isLoading = true;
      if (Platform.isIOS) {
        _selectedBytes = _bytesImages[index];
      }
    });
    _isDownloadingImage(_isLoading);
    _selectedImagePath = await _channel.invokeMethod(
      'select_photo_camera_roll',
      {
        'index': index,
      },
    );
    setState(() {
      _isLoading = false;
    });
    _isDownloadingImage(_isLoading);
    _selectedImageCallback(_selectedImagePath ?? "");
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
