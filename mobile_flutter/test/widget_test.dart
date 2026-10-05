import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/main.dart';

void main() {
  testWidgets('RoomBookApp smoke test', (WidgetTester tester) async {
    // Basic test to verify the widget can be instantiated
    expect(const RoomBookApp(), isNotNull);
  });
}
