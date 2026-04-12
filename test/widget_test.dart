import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:library_management/main.dart';

void main() {
  testWidgets('Library Management App loads successfully', (WidgetTester tester) async {
    
    // Build the app
    await tester.pumpWidget(MyApp());

    // Verify that MyApp widget loads
    expect(find.byType(MyApp), findsOneWidget);

    // Verify MaterialApp exists
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}