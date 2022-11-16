import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_invoice_scan/core/text_detector.dart';
import 'package:flutter_invoice_scan_example/iban_camera_detector/iban_camera_detector_state.dart';
import 'package:provider/provider.dart';

class IbanCameraDetector extends StatelessWidget {
  final TextDetector _textDetector;
  const IbanCameraDetector._({
    required TextDetector textDetector,
  }) : _textDetector = textDetector;

  static Future<String?> show(
      {required BuildContext context,
      required TextDetector textDetector}) async {
    return await showDialog<String?>(
      context: context,
      builder: (context) {
        return IbanCameraDetector._(
          textDetector: textDetector,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      var center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
      var rect = Rect.fromCenter(center: center, width: 500, height: 100);

      return ChangeNotifierProvider(
          create: (context) => IbanCameraDetectorState(
              textDetector: _textDetector,
              searchRect: rect,
              onIbanDetected: (iban) {
                Navigator.pop(context, iban);
              })
            ..init(),
          child: Consumer<IbanCameraDetectorState>(
            builder: (context, state, _) {
              if (state.initialized == false) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return Stack(
                fit: StackFit.expand,
                children: [
                  CameraPreview(state.cameraController!),
                  ColorFiltered(
                    colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.8), BlendMode.srcOut),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            backgroundBlendMode: BlendMode.dstOut,
                          ),
                        ),
                        Positioned.fromRect(
                          rect: rect,
                          child: Container(
                            width: rect.width,
                            height: rect.height,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ));
    });
  }
}
