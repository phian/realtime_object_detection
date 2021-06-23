class AppConstants {
  // YOLO
  static const yoloModel = "assets/yolov2_tiny.tflite";
  static const yoloLabel = "assets/yolov2_tiny.txt";

  // Mobile Net
  static const mobileNetModel = "assets/mobilenet_v1_1.0_224.tflite";
  static const mobileNetLabel = "assets/mobilenet_v1_1.0_224.txt";

  // Pose Net
  static const poseNetModel = "assets/posenet_mv1_075_float_from_checkpoints.tflite";

  // SSD Mobile Net
  static const ssdModel = "assets/ssd_mobilenet.tflite";
  static const ssdLabel = "assets/ssd_mobilenet.txt";
}

enum DetectionModel {
  mobileNet,
  ssd,
  yolo,
  poseNet,
  none,
}
