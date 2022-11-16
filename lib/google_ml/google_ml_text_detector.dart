import 'dart:io';

import 'package:camera/camera.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_invoice_scan/core/text_detector.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class GoogleMlTextDetector implements TextDetector {
  @override
  Future<List<String>> detectLinesFromCameraImage(
      CameraImage cameraImage, CameraDescription cameraDescription,
      {Rect? searchBox}) async {
    return await _processImage(
        _convertCameraImage(cameraImage, cameraDescription.sensorOrientation),
        searchBox: searchBox);
  }

  @override
  Future<List<String>> detectLinesFromImage(File image) async {
    return await _processImage(InputImage.fromFile(image));
  }

  InputImage _convertCameraImage(
    CameraImage cameraImage,
    int cameraOrientation,
  ) {
    final writeBuffer = WriteBuffer();

    for (var plane in cameraImage.planes) {
      writeBuffer.putUint8List(plane.bytes);
    }

    final Size imageSize =
        Size(cameraImage.width.toDouble(), cameraImage.height.toDouble());

    final imageRotation =
        InputImageRotationValue.fromRawValue(cameraOrientation) ??
            InputImageRotation.rotation0deg;

    final inputImageFormat =
        InputImageFormatValue.fromRawValue(cameraImage.format.raw) ??
            InputImageFormat.nv21;

    final planeData = cameraImage.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    return InputImage.fromBytes(
        bytes: writeBuffer.done().buffer.asUint8List(),
        inputImageData: inputImageData);
  }

  Future<List<String>> _processImage(InputImage inputImage,
      {Rect? searchBox}) async {
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    var blocks = (await textRecognizer.processImage(inputImage)).blocks;

    if (searchBox != null) {
      blocks = blocks
          .where((block) => searchBox.overlaps(block.boundingBox))
          .toList();
    }

    var results = blocks
        .map((block) => block.lines.map((line) => line.text))
        .flattened
        .toList();

    await textRecognizer.close();

    return results;
  }
}
