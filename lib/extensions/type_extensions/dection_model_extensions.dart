import 'package:realtime_object_detection/constants/app_constants.dart';
import 'package:tflite/tflite.dart';

extension DetectionModelExtensiona on DetectionModel {
  Future<String?> getModel() async {
    switch (this) {
      case DetectionModel.mobileNet:
        return await Tflite.loadModel(
          model: AppConstants.mobileNetModel,
          labels: AppConstants.mobileNetLabel,
        );
      case DetectionModel.yolo:
        return await Tflite.loadModel(
          model: AppConstants.yoloModel,
          labels: AppConstants.yoloLabel,
        );
      case DetectionModel.poseNet:
        return await Tflite.loadModel(
          model: AppConstants.poseNetModel,
        );
      case DetectionModel.ssd:
        return await Tflite.loadModel(
          model: AppConstants.ssdModel,
          labels: AppConstants.ssdLabel,
        );
      case DetectionModel.none:
        break;
    }
  }

  String getStringDataFromDetectionType() {
    switch(this) {
      case DetectionModel.mobileNet:
        return "MobileNet";
      case DetectionModel.ssd:
        return "SSD MobileNet";
      case DetectionModel.yolo:
        return "Tiny YOLOv2";
      case DetectionModel.poseNet:
        return "PoseNet";
      case DetectionModel.none:
        return "";
    }
  }
}
