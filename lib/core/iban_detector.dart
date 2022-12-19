import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_invoice_scan/core/camera_detector_input.dart';
import 'package:flutter_invoice_scan/core/camera_iban_detector_sink.dart';
import 'package:flutter_invoice_scan/core/text_detector.dart';
import 'package:iban/iban.dart' as iban;
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';

class IbanDetector {
  final TextDetector _textDetector;
  final Rect? _searchRect;
  static final RegExp regExp = RegExp(
    r"(([A-Z]{2}[ \-]?[0-9]{2})(?=(?:[ \-]?[A-Z0-9]){9,30})((?:[ \-]?[A-Z0-9]{3,5}){2,7})([ \-]?[A-Z0-9]{1,3})?)",
    caseSensitive: false,
    multiLine: false,
  );

  StreamController<CameraDetectorInput>? _cameraImageStreamController;
  StreamSubscription<CameraDetectorInput>? _cameraImageStreamSubscription;

  IbanDetector(
      {required TextDetector textDetector,
      Rect? searchRect,
      StreamController<CameraDetectorInput>? cameraImageStreamController})
      : _textDetector = textDetector,
        _searchRect = searchRect,
        _cameraImageStreamController = cameraImageStreamController;

  CameraIbanDetectorSink initializeCameraDetection(
      {required void Function(String iban) onIbanFound}) {
    _cameraImageStreamController ??= StreamController<CameraDetectorInput>();

    var resultStream = StreamController<String>();

    resultStream.stream.first.then((value) {
      resultStream.close();
      onIbanFound(value);
    });

    _cameraImageStreamSubscription ??= _cameraImageStreamController!.stream
        .throttleTime(const Duration(milliseconds: 200))
        .listen((cameraDetectorInput) {
      _textDetector
          .detectLinesFromCameraImage(
        cameraDetectorInput.cameraImage,
        cameraDetectorInput.cameraDescription,
        searchBox: _searchRect,
      )
          .then((lines) {
        var result = _findIbansInLines(lines).firstOrNull;

        if (result != null && resultStream.isClosed == false) {
          resultStream.sink.add(result);
        }
      });
    });

    return CameraIbanDetectorSink(
      cameraImageSink: _cameraImageStreamController!.sink,
    );
  }

  Future<String?> detectIbanOnFile(File file) async {
    var lines = await _textDetector.detectLinesFromImage(file);

    return _findIbansInLines(lines).firstOrNull;
  }

  Future<List<String>> detectMultipleIbanOnFile(File file) async {
    var lines = await _textDetector.detectLinesFromImage(file);

    return _findIbansInLines(lines);
  }

  List<String> _findIbansInLines(List<String> lines) {
    var foundIbans = lines.map((line) {
      if (regExp.hasMatch(line)) {
        var possibleIBAN = regExp.firstMatch(line)!.group(2).toString();

        if (iban.isValid(possibleIBAN)) {
          return iban.toPrintFormat(possibleIBAN);
        }
      }

      return null;
    });

    return foundIbans.whereNotNull().toList();
  }

  @mustCallSuper
  void dispose() {
    _cameraImageStreamSubscription?.cancel();
    _cameraImageStreamController?.close();
  }
}
