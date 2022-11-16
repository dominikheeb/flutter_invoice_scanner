import 'dart:async';

import 'package:flutter_invoice_scan/core/camera_detector_input.dart';

class CameraIbanDetectorSink {
  final StreamSink<CameraDetectorInput> cameraImageSink;

  CameraIbanDetectorSink({required this.cameraImageSink});

  void inputCameraImage(CameraDetectorInput cameraImage) {
    cameraImageSink.add(cameraImage);
  }
}
