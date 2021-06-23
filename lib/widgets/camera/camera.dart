import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:realtime_object_detection/constants/app_constants.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;
import 'package:flutter_spinkit/flutter_spinkit.dart';

typedef void Callback(List<dynamic>? list, int h, int w);

class Camera extends StatefulWidget {
  final List<CameraDescription>? cameras;
  final Callback setRecognitions;
  final DetectionModel model;

  Camera(this.cameras, this.model, this.setRecognitions);

  @override
  _CameraState createState() => new _CameraState();
}

class _CameraState extends State<Camera> {
  late CameraController controller;
  bool isDetecting = false;
  List<Widget> _toggles = <Widget>[];

  @override
  void initState() {
    super.initState();

    if (widget.cameras == null) {
      print('No camera is found');
    } else {
      controller = new CameraController(
        widget.cameras![0],
        ResolutionPreset.high,
      );
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});

        _initToggleButtons();
        _startCameraImageStream();
      });
    }
  }

  void _startCameraImageStream() {
    controller.startImageStream((CameraImage img) {
      if (!isDetecting) {
        isDetecting = true;
        _startRunFrame(img);
      }
    });
  }

  void _startRunFrame(CameraImage img) {
    int startTime = new DateTime.now().millisecondsSinceEpoch;

    switch (widget.model) {
      case DetectionModel.mobileNet:
        Tflite.runModelOnFrame(
          bytesList: img.planes.map((plane) {
            return plane.bytes;
          }).toList(),
          imageHeight: img.height,
          imageWidth: img.width,
          numResults: 2,
        ).then((recognitions) {
          int endTime = new DateTime.now().millisecondsSinceEpoch;
          print("Detection took ${endTime - startTime}");

          widget.setRecognitions(recognitions, img.height, img.width);

          isDetecting = false;
        });
        break;
      case DetectionModel.yolo:
      case DetectionModel.ssd:
        Tflite.detectObjectOnFrame(
          bytesList: img.planes.map((plane) {
            return plane.bytes;
          }).toList(),
          model: widget.model == DetectionModel.yolo ? "YOLO" : "SSDMobileNet",
          imageHeight: img.height,
          imageWidth: img.width,
          imageMean: widget.model == DetectionModel.yolo ? 0 : 127.5,
          imageStd: widget.model == DetectionModel.yolo ? 255.0 : 127.5,
          numResultsPerClass: 1,
          threshold: widget.model == DetectionModel.yolo ? 0.2 : 0.4,
        ).then((recognitions) {
          int endTime = new DateTime.now().millisecondsSinceEpoch;
          print("Detection took ${endTime - startTime}");

          widget.setRecognitions(recognitions, img.height, img.width);

          isDetecting = false;
        });
        break;
      case DetectionModel.poseNet:
        Tflite.runPoseNetOnFrame(
          bytesList: img.planes.map((plane) {
            return plane.bytes;
          }).toList(),
          imageHeight: img.height,
          imageWidth: img.width,
          numResults: 2,
        ).then((recognitions) {
          int endTime = new DateTime.now().millisecondsSinceEpoch;
          print("Detection took ${endTime - startTime}");

          widget.setRecognitions(recognitions, img.height, img.width);

          isDetecting = false;
        });
        break;
      case DetectionModel.none:
        break;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return SpinKitFadingCube(
        color: Colors.white,
        size: 50.0,
      );
    }

    var tmp = MediaQuery.of(context).size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    tmp = controller.value.previewSize ?? tmp;
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    return Stack(
      children: [
        OverflowBox(
          maxHeight: screenRatio > previewRatio
              ? screenH
              : screenW / previewW * previewH,
          maxWidth: screenRatio > previewRatio
              ? screenH / previewH * previewW
              : screenW,
          child: CameraPreview(controller),
        ),
        _togglesRowWidget(),
      ],
    );
  }

  /// Toggle buttons
  void _initToggleButtons() {
    _toggles = [];

    final onChanged = (CameraDescription? description) {
      if (description == null) {
        return;
      }

      onNewCameraSelected(description);
    };

    if (widget.cameras == null) {
      return _toggles.add(Text('No camera found'));
    } else {
      for (CameraDescription cameraDescription in widget.cameras!) {
        _toggles.add(
          Container(
            alignment: Alignment.bottomLeft,
            child: SizedBox(
              width: 90.0,
              child: RadioListTile<CameraDescription>(
                title: Icon(
                  getCameraLensIcon(cameraDescription.lensDirection),
                  size: 40.0,
                ),
                groupValue: controller.description,
                value: cameraDescription,
                onChanged: onChanged,
              ),
            ),
          ),
        );
      }
    }
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _togglesRowWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _toggles,
    );
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    await controller.dispose();

    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.ultraHigh,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) setState(() {});
      if (cameraController.value.hasError) {
        print('Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
      await Future.wait([
        cameraController.getMinExposureOffset().then((value) {}),
        cameraController.getMaxExposureOffset().then((value) {}),
        cameraController.getMaxZoomLevel().then((value) {}),
        cameraController.getMinZoomLevel().then((value) {}),
      ]);
    } on CameraException catch (e, s) {
      print("$e, $s");
    }

    if (mounted) {
      setState(() {
        _initToggleButtons();
      });
    }
  }

  /// Returns a suitable camera icon for [direction].
  IconData getCameraLensIcon(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return Icons.camera_rear;
      case CameraLensDirection.front:
        return Icons.camera_front;
      case CameraLensDirection.external:
        return Icons.camera;
      default:
        throw ArgumentError('Unknown lens direction');
    }
  }
}
