import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:realtime_object_detection/constants/app_constants.dart';

class BoundingBox extends StatelessWidget {
  final List<dynamic>? recognitions;
  final int previewH;
  final int previewW;
  final double screenH;
  final double screenW;
  final DetectionModel model;

  BoundingBox(
    this.recognitions,
    this.previewH,
    this.previewW,
    this.screenH,
    this.screenW,
    this.model,
  );

  @override
  Widget build(BuildContext context) {
    List<Widget> _renderBoxes() {
      return recognitions != null
          ? recognitions!.map((re) {
              print("re ::: ${re.toString()}");

              var _x = 0.0, _w = 0.0, _y = 0.0, _h = 0.0;
              var scaleW, scaleH, x, y, w, h;

              if (re["rect"] != null) {
                _x = re["rect"]["x"];
                _w = re["rect"]["w"];
                _y = re["rect"]["y"];
                _h = re["rect"]["h"];
              }

              if (screenH / screenW > previewH / previewW) {
                scaleW = screenH / previewH * previewW;
                scaleH = screenH;
                var difW = (scaleW - screenW) / scaleW;
                x = (_x - difW / 2) * scaleW;
                w = _w * scaleW;
                if (_x < difW / 2) w -= (difW / 2 - _x) * scaleW;
                y = _y * scaleH;
                h = _h * scaleH;
              } else {
                scaleH = screenW / previewW * previewH;
                scaleW = screenW;
                var difH = (scaleH - screenH) / scaleH;
                x = _x * scaleW;
                w = _w * scaleW;
                y = (_y - difH / 2) * scaleH;
                h = _h * scaleH;
                if (_y < difH / 2) h -= (difH / 2 - _y) * scaleH;
              }

              return Positioned(
                left: math.max(0, x),
                top: math.max(0, y),
                width: w,
                height: h,
                child: Container(
                  padding: EdgeInsets.only(top: 5.0, left: 5.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color.fromRGBO(37, 213, 253, 1.0),
                      width: 3.0,
                    ),
                  ),
                  child: Text(
                    "${re["detectedClass"]} ${(re["confidenceInClass"] ?? 0 * 100).toStringAsFixed(0)}%",
                    style: TextStyle(
                      color: Color.fromRGBO(37, 213, 253, 1.0),
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList()
          : [Container()];
    }

    List<Widget> _renderStrings() {
      double offset = -10;
      return recognitions != null
          ? recognitions!.map((re) {
              offset = offset + 14;
              return Positioned(
                left: 10,
                top: offset,
                width: screenW,
                height: screenH,
                child: Text(
                  "${re["label"]} ${(re["confidence"] ?? 0 * 100).toStringAsFixed(0)}%",
                  style: TextStyle(
                    color: Color.fromRGBO(37, 213, 253, 1.0),
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }).toList()
          : [Container()];
    }

    List<Widget> _renderKeyPoints() {
      var lists = <Widget>[];
      if (recognitions != null) {
        recognitions!.forEach((re) {
          var list = <Widget>[];
          if (re["keypoints"] != null) {
            list = re["keypoints"].values.map<Widget>((k) {
              var _x = k["x"];
              var _y = k["y"];
              var scaleW, scaleH, x, y;

              if (screenH / screenW > previewH / previewW) {
                scaleW = screenH / previewH * previewW;
                scaleH = screenH;
                var difW = (scaleW - screenW) / scaleW;
                x = (_x - difW / 2) * scaleW;
                y = _y * scaleH;
              } else {
                scaleH = screenW / previewW * previewH;
                scaleW = screenW;
                var difH = (scaleH - screenH) / scaleH;
                x = _x * scaleW;
                y = (_y - difH / 2) * scaleH;
              }
              return Positioned(
                left: x - 6,
                top: y - 6,
                width: 100,
                height: 12,
                child: Container(
                  child: Text(
                    "● ${k["part"]}",
                    style: TextStyle(
                      color: Color.fromRGBO(37, 213, 253, 1.0),
                      fontSize: 12.0,
                    ),
                  ),
                ),
              );
            }).toList();
          }

          lists..addAll(list);
        });
      }

      return lists;
    }

    return Stack(
      children: model == DetectionModel.mobileNet
          ? _renderStrings()
          : model == DetectionModel.poseNet
              ? _renderKeyPoints()
              : _renderBoxes(),
    );
  }
}
