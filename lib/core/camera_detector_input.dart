import 'package:camera/camera.dart';

class CameraDetectorInput {
  final CameraImage cameraImage;
  final CameraDescription cameraDescription;

  CameraDetectorInput(
      {required this.cameraImage, required this.cameraDescription});
}
