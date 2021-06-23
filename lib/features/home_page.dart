import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:realtime_object_detection/constants/app_constants.dart';
import 'package:realtime_object_detection/widgets/bounding_box.dart';
import 'package:realtime_object_detection/widgets/camera/camera.dart';
import 'dart:math' as math;
import 'package:realtime_object_detection/extensions/extensions.dart';

class HomePage extends StatefulWidget {
  final List<CameraDescription>? cameras;

  HomePage(this.cameras);

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _recognitions = [];
  int _imageHeight = 0;
  int _imageWidth = 0;
  DetectionModel _model = DetectionModel.none;

  @override
  void initState() {
    super.initState();
  }

  void loadModel() async {
    String? res;
    res = await _model.getModel();

    print(res);
  }

  void onSelect(DetectionModel model) {
    setState(() {
      _model = model;
    });
    loadModel();
  }

  void setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        setState(() {
          _model = DetectionModel.none;
        });

        return Future.value(false);
      },
      child: Scaffold(
        body: _model == DetectionModel.none
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ...List.generate(
                      DetectionModel.values.length - 1,
                      (index) => ElevatedButton(
                        child: Text(
                          DetectionModel.values[index]
                              .getStringDataFromDetectionType(),
                        ),
                        onPressed: () => onSelect(DetectionModel.values[index]),
                      ),
                    ),
                  ],
                ),
              )
            : Stack(
                children: [
                  Camera(
                    widget.cameras,
                    _model,
                    setRecognitions,
                  ),
                  BoundingBox(
                    _recognitions,
                    math.max(_imageHeight, _imageWidth),
                    math.min(_imageHeight, _imageWidth),
                    screen.height,
                    screen.width,
                    _model,
                  ),
                ],
              ),
      ),
    );
  }
}
