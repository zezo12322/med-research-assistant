// Basic Flutter widget test for Med Research Assistant

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:med_research_assistant/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MedResearchApp());

    // Verify that the app launches without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
