import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guitar_tuxguitar/main.dart';

void main() {
  testWidgets('App renders without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const GuitarApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
