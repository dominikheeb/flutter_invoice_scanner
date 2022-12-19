import 'package:flutter_invoice_scan/core/iban_detector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('detector regex recognizes iban in print format', () async {
    // arrange
    var validIban = "CH15 0076 212C 1233 2223 4";

    var testLine = "Test $validIban why not?";

    // act
    var result = IbanDetector.regExp.hasMatch(testLine);
    var match = IbanDetector.regExp.firstMatch(testLine)!.group(1).toString();

    // assert
    expect(result, isTrue);
    expect(match, validIban);
  });

  test('detector regex recognizes iban in electronic format', () async {
    // arrange
    var validIban = "CH150076212C123322234";

    var testLine = "Test $validIban why not?";

    // act
    var result = IbanDetector.regExp.hasMatch(testLine);
    var match = IbanDetector.regExp.firstMatch(testLine)!.group(1).toString();

    // assert
    expect(result, isTrue);
    expect(match, validIban);
  });
}
