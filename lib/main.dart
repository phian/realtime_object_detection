import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:realtime_object_detection/features/home_page.dart';

Future<Null> main() async {
  List<CameraDescription> cameras = [];

  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.message');
  }
  runApp(new MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription>? cameras;

  MyApp({required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TfLite real-time detection',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: HomePage(cameras),
    );
  }
}
