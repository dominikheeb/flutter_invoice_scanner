import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/rendering.dart';

abstract class TextDetector {
  Future<List<String>> detectLinesFromImage(File image);

  Future<List<String>> detectLinesFromCameraImage(
      CameraImage cameraImage, CameraDescription cameraDescription,
      {Rect? searchBox});
}
