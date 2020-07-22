import 'dart:async';
import 'dart:io';
import 'dart:ui' show lerpDouble;

import 'package:campus_mobile_experimental/core/constants/app_constants.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'colors.dart';
import 'scanner_utils.dart';
import 'package:campus_mobile_experimental/ui/theme/app_theme.dart';
import 'package:campus_mobile_experimental/core/data_providers/user_data_provider.dart';
import 'package:campus_mobile_experimental/core/services/barcode_service.dart';
import 'package:campus_mobile_experimental/core/models/authentication_model.dart';


enum AnimationState { search, barcodeNear, barcodeFound, endSearch }

class MaterialBarcodeScanner extends StatefulWidget {
  const MaterialBarcodeScanner({
    this.validRectangle = const Rectangle(width: 320, height: 144),
    this.frameColor = kShrineScrim,
    this.traceMultiplier = 1.2,
  });

  final Rectangle validRectangle;
  final Color frameColor;
  final double traceMultiplier;

  @override
  _MaterialBarcodeScannerState createState() => _MaterialBarcodeScannerState();
}

class _MaterialBarcodeScannerState extends State<MaterialBarcodeScanner>
    with TickerProviderStateMixin {
  CameraController _cameraController;
  AnimationController _animationController;
  String _scannerHint;
  bool _closeWindow = false;
  String _barcodePictureFilePath;
  Size _previewSize;
  AnimationState _currentState = AnimationState.search;
  CustomPainter _animationPainter;
  int _animationStart = DateTime.now().millisecondsSinceEpoch;
  final BarcodeDetector _barcodeDetector = FirebaseVision.instance.barcodeDetector();
  bool _hasScanned = false;
  String _barcode = "";
  UserDataProvider _userDataProvider;
  AuthenticationModel _authenticationModel = AuthenticationModel();
  BarcodeService _barcodeService;
  bool _submitted = false;
  String _result = "";

  @override
  void initState() {
    super.initState();
    print("now in barcode scanner");
    _hasScanned;
    _barcode;
    _userDataProvider = UserDataProvider();
    print(_userDataProvider.authenticationModel.ucsdaffiliation);
    print(_authenticationModel.ucsdaffiliation);
    _barcodeService = BarcodeService();
    print("auth model");
    print(_userDataProvider.authenticationModel.ucsdaffiliation);
    SystemChrome.setEnabledSystemUIOverlays(<SystemUiOverlay>[]);
    SystemChrome.setPreferredOrientations(
      <DeviceOrientation>[DeviceOrientation.portraitUp],
    );
    _initCameraAndScanner();
    _switchAnimationState(AnimationState.search);
  }

  void _initCameraAndScanner() {
    ScannerUtils.getCamera(CameraLensDirection.back).then(
          (CameraDescription camera) async {
        await _openCamera(camera);
        await _startStreamingImagesToScanner(camera.sensorOrientation);
      },
    );
  }

  void _initAnimation(Duration duration) {
    setState(() {
      _animationPainter = null;
    });

    //_animationController?.dispose();
    _animationController = AnimationController(duration: duration, vsync: this);
  }

  void _switchAnimationState(AnimationState newState) {
    if (newState == AnimationState.search) {
      _initAnimation(const Duration(milliseconds: 750));

      _animationPainter = RectangleOutlinePainter(
        animation: RectangleTween(
          Rectangle(
            width: widget.validRectangle.width,
            height: widget.validRectangle.height,
            color: Colors.white,
          ),
          Rectangle(
            width: widget.validRectangle.width * widget.traceMultiplier,
            height: widget.validRectangle.height * widget.traceMultiplier,
            color: Colors.transparent,
          ),
        ).animate(_animationController),
      );

      _animationController.addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          Future<void>.delayed(const Duration(milliseconds: 1600), () {
            if (_currentState == AnimationState.search) {
              _animationController.forward(from: 0);
            }
          });
        }
      });
    } else if (newState == AnimationState.barcodeNear ||
        newState == AnimationState.barcodeFound ||
        newState == AnimationState.endSearch) {
      double begin;
      if (_currentState == AnimationState.barcodeNear) {
        begin = lerpDouble(0.0, 0.5, _animationController.value);
      } else if (_currentState == AnimationState.search) {
        _initAnimation(const Duration(milliseconds: 500));
        begin = 0.0;
      }

      _animationPainter = RectangleTracePainter(
        rectangle: Rectangle(
          width: widget.validRectangle.width,
          height: widget.validRectangle.height,
          color: newState == AnimationState.endSearch
              ? Colors.transparent
              : Colors.white,
        ),
        animation: Tween<double>(
          begin: begin,
          end: newState == AnimationState.barcodeNear ? 0.5 : 1.0,
        ).animate(_animationController),
      );

      if (newState == AnimationState.barcodeFound) {
        _animationController.addStatusListener((AnimationStatus status) {
          if (status == AnimationStatus.completed) {
            Future<void>.delayed(const Duration(milliseconds: 300), () {
              if (_currentState != AnimationState.endSearch) {
                _switchAnimationState(AnimationState.endSearch);
                setState(() {

                });
              }
            });
          }
        });
      }
    }

    _currentState = newState;
    if (newState != AnimationState.endSearch) {
      _animationController.forward(from: 0);
      _animationStart = DateTime.now().millisecondsSinceEpoch;
    }
  }

  Future<void> _openCamera(CameraDescription camera) async {
    final ResolutionPreset preset =
    defaultTargetPlatform == TargetPlatform.android
        ? ResolutionPreset.medium
        : ResolutionPreset.medium;
    _cameraController = CameraController(camera, preset,enableAudio: false);
    await _cameraController.initialize();
    _previewSize = _cameraController.value.previewSize;
    setState(() {});
  }

  Future<void> _startStreamingImagesToScanner(int sensorOrientation) async {
    bool isDetecting = false;
    final MediaQueryData data = MediaQuery.of(context);
    _cameraController.startImageStream((CameraImage availableImage) async {
      isDetecting = true;
      var bytes = availableImage.planes[0].bytesPerRow;
      var height = availableImage.height;
        Future.delayed(const Duration(milliseconds: 50),() async {
          final FirebaseVisionImageMetadata metadata = FirebaseVisionImageMetadata(
              rawFormat: availableImage.format.raw,
              size: Size(availableImage.width.toDouble(),availableImage.height.toDouble()),
              planeData: availableImage.planes.map((currentPlane) => FirebaseVisionImagePlaneMetadata(
                  bytesPerRow: bytes,
                  height: availableImage.height,
                  width: bytes,
              )).toList(),
              rotation: ImageRotation.rotation90
          );
          //print(metadata.planeData);
          final FirebaseVisionImage visionImage = FirebaseVisionImage.fromBytes(availableImage.planes[0].bytes, metadata);
          //print(visionImage.toString());
          //print(visionImage.toString());
          final List<Barcode> barcodes = await _barcodeDetector.detectInImage(visionImage);
          if(barcodes.isNotEmpty && _cameraController != null) {
            //_cameraController.stopImageStream();
            print(barcodes.toString());
            for(int i = 0 ; i < barcodes.length ; i++) {
              if(barcodes[i].rawValue is String && !barcodes[i].rawValue.contains("typeNumber")) {
                //_handleResult(barcodes:barcodes, data: data, imageSize: new Size(availableImage.height.toDouble(),availableImage.width.toDouble()));
                print("BARCODE VAL: " + barcodes[i].rawValue);
                print("BARCODE TYPE: " + barcodes[i].valueType.toString());
                _barcodeDetector.close();
                _cameraController.stopImageStream();
                setState(() {
                  _hasScanned = true;
                  _barcode = barcodes[i].rawValue;
                });
                _cameraController.dispose();
                try{
                  print("stopping image stream");
                  _cameraController.stopImageStream();
                  return;
                }
                on CameraException catch(e) {
                  return;
                }
                break;
              }
            }

            return;
          }
        });

        //print("HERE");
        //print(barcodes.toString());
        //print("successful scan");
        return;
      });
  }



  bool get _barcodeNearAnimationInProgress {
    return _currentState == AnimationState.barcodeNear &&
        DateTime.now().millisecondsSinceEpoch - _animationStart < 2500;
  }

  void _handleResult({
    @required List<Barcode> barcodes,
    @required MediaQueryData data,
    @required Size imageSize,
  }) {
    print(barcodes[0].rawValue);
    if (_cameraController != null && !_cameraController.value.isStreamingImages) {
      return;
    }
    final EdgeInsets padding = data.padding;
    final double maxLogicalHeight =
        data.size.height - padding.top - padding.bottom;

    // Width & height are flipped from CameraController.previewSize on iOS
    final double imageHeight = defaultTargetPlatform == TargetPlatform.iOS
        ? imageSize.height
        : imageSize.width;

    final double imageScale = imageHeight / maxLogicalHeight;
    final double halfWidth = imageScale * widget.validRectangle.width / 2;
    final double halfHeight = imageScale * widget.validRectangle.height / 2;

    final Offset center = imageSize.center(Offset.zero);
    final Rect validRect = Rect.fromLTRB(
      center.dx - halfWidth,
      center.dy - halfHeight,
      center.dx + halfWidth,
      center.dy + halfHeight,
    );

//    for (Barcode barcode in barcodes) {
//      print(barcode.rawValue);
//      final Rect intersection = validRect.intersect(barcode.boundingBox);
//
//      final bool doesContain = intersection == barcode.boundingBox;
//
//      if (doesContain) {
//        try{
//          _cameraController.stopImageStream().then((_) => _takePicture());
//        }
//        on CameraException{
//          print("here");
//        }
//
//        if (_currentState != AnimationState.barcodeFound) {
////          _closeWindow = true;
////          _scannerHint = 'Submit Barcode';
////          _switchAnimationState(AnimationState.barcodeFound);
//          setState(() {
//            _hasScanned = true;
//          });
//        }
//        return;
//      } else if (barcode.boundingBox.overlaps(validRect)) {
//        if (_currentState != AnimationState.barcodeNear) {
//          //_scannerHint = 'Move closer to the barcode';
//          //_switchAnimationState(AnimationState.barcodeNear);
//          setState(() {});
//        }
//        //return;
//      }
//    }

    if (_barcodeNearAnimationInProgress) {
      return;
    }

    if (_currentState != AnimationState.search) {
      _scannerHint = null;
      _switchAnimationState(AnimationState.search);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _currentState = AnimationState.endSearch;
    try{
      _cameraController.stopImageStream();
    }
    on CameraException {

    }
    _cameraController?.dispose();
    _animationController?.dispose();
    _barcodeDetector.close();

    SystemChrome.setPreferredOrientations(<DeviceOrientation>[]);
    SystemChrome.setEnabledSystemUIOverlays(<SystemUiOverlay>[
      SystemUiOverlay.top,
      SystemUiOverlay.bottom,
    ]);

    super.dispose();
  }

  Future<void> _takePicture() async {
    final Directory extDir = await getApplicationDocumentsDirectory();

    final String dirPath = '${extDir.path}/Pictures/barcodePics';
    await Directory(dirPath).create(recursive: true);

    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    final String filePath = '$dirPath/$timestamp.jpg';

    try {
      await _cameraController.takePicture(filePath);
    } on CameraException catch (e) {
      print(e);
    }

    //_cameraController.dispose();
    _cameraController = null;

    setState(() {
      _barcodePictureFilePath = filePath;
    });
  }

  Widget _buildCameraPreview() {
    return Container(
      color: Colors.black,
      child: Transform.scale(
        scale: _getImageZoom(MediaQuery.of(context)),
        child: Center(
          child: AspectRatio(
            aspectRatio: _cameraController.value.aspectRatio,
            child: CameraPreview(_cameraController),
          ),
        ),
      ),
    );
  }

  double _getImageZoom(MediaQueryData data) {
    final double logicalWidth = data.size.width;
    final double logicalHeight = _previewSize.aspectRatio * logicalWidth;

    final EdgeInsets padding = data.padding;
    final double maxLogicalHeight =
        data.size.height - padding.top - padding.bottom;

    return maxLogicalHeight / logicalHeight;
  }

  Future<Map<String, dynamic>> createUserData() async {
    print("affiliation: " + _userDataProvider.authenticationModel.ucsdaffiliation.toString());
    return {
      'barcode': _barcode,
      'ucsdaffiliation': _userDataProvider.authenticationModel.ucsdaffiliation
    };
  }

  void submitBarcode() async {
      print("in submit");
      var userData = await createUserData();
      print("here");
      print(userData.toString());
//      var headers = {
//        "Content-Type": "application/json",
//        'Authorization':
//        'Bearer ${_userDataProvider.authenticationModel.accessToken}'
//      };
//      var results = await _barcodeService.uploadResults(headers, userData);
//      if (results) {
//        _result = ButtonText.SubmitButtonReceived;
//        _submitted = true;
//      } else {
//        if (_barcodeService.error.contains(ErrorConstants.invalidBearerToken)) {
//          await _userDataProvider.refreshToken();
//        } else {
//          _result = _barcodeService.error;
//        }
//        _result = ButtonText.SubmitButtonTryAgain;
//        _submitted = true;
//      }
     setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    Widget background;
    if (_barcodePictureFilePath != null) {
      background = Container(
        color: Colors.black,
        child: Transform.scale(
          scale: _getImageZoom(MediaQuery.of(context)),
          child: Center(
            child: Image.file(
              File(_barcodePictureFilePath),
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
      );
    } else if (_cameraController != null &&
        _cameraController.value.isInitialized) {
      background = _buildCameraPreview();
    } else {
      background = Container(
        color: Colors.black,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title:Text("Test Kit Scanner"),
        backgroundColor: Color(0xFF182B49),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            _barcodeDetector.close();
            _cameraController.stopImageStream();
            _barcode = "";
            Navigator.of(context).pop();
          },
        ),
        elevation: 0.0,
      ),
      body: Stack(
        children: <Widget>[
          background,
          Container(
            constraints: const BoxConstraints.expand(),
            child: CustomPaint(
              painter: WindowPainter(
                windowSize: Size(widget.validRectangle.width,
                    widget.validRectangle.height),
                outerFrameColor: widget.frameColor,
                closeWindow: _closeWindow,
                innerFrameColor: _currentState == AnimationState.endSearch
                    ? Colors.transparent
                    : kShrineFrameBrown,
              ),
            ),
          ),
            Container(
            constraints: const BoxConstraints.expand(),
            child: CustomPaint(
              painter: _animationPainter,
            ),
          ),
          Align(
            alignment:FractionalOffset.bottomCenter,
            child: ConstrainedBox(
                constraints: BoxConstraints.loose(Size(MediaQuery.of(context).size.width, 0.2 * MediaQuery.of(context).size.height)),
                child: Container(
                  color: Colors.white,
                  child: SingleChildScrollView(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          _hasScanned
                              ? Padding(
                            padding: const EdgeInsets.only(top: 20.0, bottom: 4.0),
                            child: Text(
                              _barcode,
                              style: TextStyle( color: Colors.black, fontSize: 18.0 ),
                              textAlign: TextAlign.center,
                            ),
                          )
                              : Padding(
                            padding: const EdgeInsets.only(top:20.0, bottom: 4.0),
                            child: Text(
                              "Scan a test kit.",
                              style: TextStyle( color: Colors.black, fontSize: 18.0 ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.all(16.0),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom:16.0),
                                  child: FlatButton(
                                    disabledTextColor: Colors.black,
                                    disabledColor: Color.fromRGBO(218, 218, 218, 1.0),
                                    onPressed: (){
                                      print("PRESSED");
                                      submitBarcode();
                                    },
                                    child: Text("Submit"),
                                    color: ColorPrimary,
                                    textColor: lightTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ]),
                  ),
                ),
              ),
          ),
        ],

    ),
    );
  }
}

class WindowPainter extends CustomPainter {
  WindowPainter({
    @required this.windowSize,
    this.outerFrameColor = Colors.white54,
    this.innerFrameColor = const Color(0xFF442C2E),
    this.innerFrameStrokeWidth = 3,
    this.closeWindow = false,
  });

  final Size windowSize;
  final Color outerFrameColor;
  final Color innerFrameColor;
  final double innerFrameStrokeWidth;
  final bool closeWindow;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double windowHalfWidth = windowSize.width / 2;
    final double windowHalfHeight = windowSize.height / 2;

    final Rect windowRect = Rect.fromLTRB(
      center.dx - windowHalfWidth,
      center.dy - windowHalfHeight/0.5,
      center.dx + windowHalfWidth,
      center.dy + windowHalfHeight/1.5,
    );

    final Rect left =
    Rect.fromLTRB(0, windowRect.top, windowRect.left, windowRect.bottom);
    final Rect top = Rect.fromLTRB(0, 0, size.width, windowRect.top);
    final Rect right = Rect.fromLTRB(
      windowRect.right,
      windowRect.top,
      size.width,
      windowRect.bottom,
    );
    final Rect bottom = Rect.fromLTRB(
      0,
      windowRect.bottom,
      size.width,
      size.height,
    );

    canvas.drawRect(
        windowRect,
        Paint()
          ..color = innerFrameColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = innerFrameStrokeWidth);

    final Paint paint = Paint()..color = outerFrameColor;
    canvas.drawRect(left, paint);
    canvas.drawRect(top, paint);
    canvas.drawRect(right, paint);
    canvas.drawRect(bottom, paint);

    if (closeWindow) {
      canvas.drawRect(windowRect, paint);
    }
  }

  @override
  bool shouldRepaint(WindowPainter oldDelegate) =>
      oldDelegate.closeWindow != closeWindow;
}

class Rectangle {
  const Rectangle({this.width, this.height, this.color});

  final double width;
  final double height;
  final Color color;

  static Rectangle lerp(Rectangle begin, Rectangle end, double t) {
    Color color;
    if (t > .5) {
      color = Color.lerp(begin.color, end.color, (t - .5) / .25);
    } else {
      color = begin.color;
    }

    return Rectangle(
      width: lerpDouble(begin.width, end.width, t),
      height: lerpDouble(begin.height, end.height, t),
      color: color,
    );
  }
}

class RectangleTween extends Tween<Rectangle> {
  RectangleTween(Rectangle begin, Rectangle end)
      : super(begin: begin, end: end);

  @override
  Rectangle lerp(double t) => Rectangle.lerp(begin, end, t);
}

class RectangleOutlinePainter extends CustomPainter {
  RectangleOutlinePainter({
    @required this.animation,
    this.strokeWidth = 3,
  }) : super(repaint: animation);

  final Animation<Rectangle> animation;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Rectangle rectangle = animation.value;

    final Paint paint = Paint()
      ..strokeWidth = strokeWidth
      ..color = rectangle.color
      ..style = PaintingStyle.stroke;

    final Offset center = size.center(Offset.zero);
    final double halfWidth = rectangle.width / 2;
    final double halfHeight = rectangle.height / 2;

    final Rect rect = Rect.fromLTRB(
      center.dx - halfWidth,
      center.dy - halfHeight/0.5,
      center.dx + halfWidth,
      center.dy + halfHeight/1.5,
    );

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(RectangleOutlinePainter oldDelegate) => false;
}

class RectangleTracePainter extends CustomPainter {
  RectangleTracePainter({
    @required this.animation,
    @required this.rectangle,
    this.strokeWidth = 3,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Rectangle rectangle;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final double value = animation.value;

    final Offset center = size.center(Offset.zero);
    final double halfWidth = rectangle.width / 2;
    final double halfHeight = rectangle.height / 2;

    final Rect rect = Rect.fromLTRB(
      center.dx - halfWidth,
      center.dy - halfHeight,
      center.dx + halfWidth,
      center.dy + halfHeight,
    );

    final Paint paint = Paint()
      ..strokeWidth = strokeWidth
      ..color = rectangle.color;

    final double halfStrokeWidth = strokeWidth / 2;

    final double heightProportion = (halfStrokeWidth + rect.height) * value;
    final double widthProportion = (halfStrokeWidth + rect.width) * value;

    canvas.drawLine(
      Offset(rect.right, rect.bottom + halfStrokeWidth),
      Offset(rect.right, rect.bottom - heightProportion),
      paint,
    );

    canvas.drawLine(
      Offset(rect.right + halfStrokeWidth, rect.bottom),
      Offset(rect.right - widthProportion, rect.bottom),
      paint,
    );

    canvas.drawLine(
      Offset(rect.left, rect.top - halfStrokeWidth),
      Offset(rect.left, rect.top + heightProportion),
      paint,
    );

    canvas.drawLine(
      Offset(rect.left - halfStrokeWidth, rect.top),
      Offset(rect.left + widthProportion, rect.top),
      paint,
    );
  }

  @override
  bool shouldRepaint(RectangleTracePainter oldDelegate) => false;
}