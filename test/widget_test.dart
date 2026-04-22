import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finny/main.dart';

void main() {
  testWidgets('App launches correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const FannyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
