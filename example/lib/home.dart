import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_invoice_scan/flutter_invoice_scan.dart';
import 'package:flutter_invoice_scan_example/iban_camera_detector/iban_camera_detector.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MaterialButton(
            child: const Text("IBAN Detector"),
            onPressed: () {
              IbanCameraDetector.show(
                context: context,
                textDetector: context.read(),
              ).then((value) {
                if (value != null) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Neue Iban gefunden"),
                      content: Text(value),
                    ),
                  );
                }
              });
            },
          ),
          const SizedBox(
            height: 100,
          ),
          MaterialButton(
            onPressed: () {
              ImagePicker()
                  .pickImage(source: ImageSource.gallery)
                  .then((value) {
                if (value != null) {
                  var detector =
                      IbanDetector(textDetector: GoogleMlTextDetector());
                  detector.detectIbanOnFile(File(value.path)).then(
                    (value) {
                      if (value != null) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Neue Iban gefunden"),
                            content: Text(value),
                          ),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => const AlertDialog(
                            title: Text("Keine IBAN gefunden"),
                          ),
                        );
                      }
                    },
                  );
                }
              });
            },
            child: const Text("Datei auswählen"),
          )
        ],
      )),
    );
  }
}
