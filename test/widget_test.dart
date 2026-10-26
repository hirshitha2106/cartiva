import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cartiva/main.dart';

void main() {
  testWidgets('CartivaApp smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const CartivaApp());
    expect(find.byType(CartivaApp), findsOneWidget);
    // Allow initial delayed Future in product provider to finish
    await tester.pump(const Duration(milliseconds: 200));
    // Unmount CartivaApp and allow periodic timers to cancel cleanly
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 50));
  });
}
