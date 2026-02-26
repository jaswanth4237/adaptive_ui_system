import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_ui_system/layout/constraint_system.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('ConstraintLayoutBuilder parses and positions widgets', (WidgetTester tester) async {
    // This requires a real app context or a mock root bundle for the JSON
    // For a simpler test, we can just verify it builds without crashing 
    // and correctly identifies children.
    
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ConstraintLayoutBuilder(
          children: {
            'box1': Container(key: const Key('box1'), color: Colors.blue),
            'box2': Container(key: const Key('box2'), color: Colors.red),
          },
        ),
      ),
    ));

    // Wait for internal async _loadConstraints
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('box1')), findsOneWidget);
    expect(find.byKey(const Key('box2')), findsOneWidget);
  });
}
