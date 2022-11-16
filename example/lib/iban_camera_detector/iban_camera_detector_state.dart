import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_invoice_scan/flutter_invoice_scan.dart';

class IbanCameraDetectorState extends ChangeNotifier {
  final TextDetector _textDetector;
  final Rect? searchRect;
  final void Function(String iban) onIbanDetected;

  IbanCameraDetectorState({
    required TextDetector textDetector,
    required this.onIbanDetected,
    this.searchRect,
  }) : _textDetector = textDetector;

  IbanDetector? _ibanDetector;
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  int _selectedCamera = 0;

  bool get initialized =>
      _cameraController != null && _cameraController!.value.isInitialized;

  CameraDescription? get currentCamera =>
      initialized ? cameras![_selectedCamera] : null;

  CameraController? get cameraController => _cameraController;

  Future<void> init() async {
    cameras = await availableCameras();

    await _startCameraStream();

    notifyListeners();
  }

  void selectCamera(CameraDescription cameraDescription) {
    _selectedCamera = cameras?.indexOf(cameraDescription) ?? 0;
    notifyListeners();
  }

  Future<void> _startCameraStream() async {
    _disposeController();

    _cameraController = CameraController(
      cameras![_selectedCamera],
      ResolutionPreset.high,
      imageFormatGroup:
          Platform.isIOS ? ImageFormatGroup.bgra8888 : ImageFormatGroup.jpeg,
    );

    await _cameraController!.initialize();

    _ibanDetector = IbanDetector(
      textDetector: _textDetector,
      searchRect: searchRect,
    );
    var detectorSink =
        _ibanDetector!.initializeCameraDetection(onIbanFound: onIbanDetected);

    await _cameraController!.startImageStream((image) {
      detectorSink.cameraImageSink.add(
        CameraDetectorInput(
          cameraImage: image,
          cameraDescription: currentCamera!,
        ),
      );
    });
  }

  Future<void> _disposeController() async {
    if (_cameraController != null) {
      await _cameraController!.stopImageStream();
      await _cameraController!.dispose();
    }

    _ibanDetector?.dispose();
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }
}
