
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_trip_planner/src/app.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    
    expect(find.byType(Scaffold), findsOneWidget);
  });
}