import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:praktikum_4_abdullah/main.dart';

void main() {
  testWidgets('Aplikasi dapat dibuka', (WidgetTester tester) async {
    await tester.pumpWidget(const PencatatPengeluaranApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}