import 'package:flutter/material.dart';
import 'package:flutter_invoice_scan/flutter_invoice_scan.dart';
import 'package:flutter_invoice_scan_example/home.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Provider<TextDetector>(
        create: (context) => GoogleMlTextDetector(),
        child: const Home(),
      ),
    );
  }
}
