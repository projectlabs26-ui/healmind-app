import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:healmind/app.dart';

void main() {
  testWidgets('App loads with bottom navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const HealMindApp());
    await tester.pump();

    // Verify bottom navigation exists
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}