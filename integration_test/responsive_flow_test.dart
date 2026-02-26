import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:adaptive_ui_system/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Responsive Flow Tests', () {
    testWidgets('Verify breakpoint indicator and navigation switching', (WidgetTester tester) async {
      await app.main();
      await tester.pumpAndSettle();

      // Test Compact View
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byKey(const Key('breakpoint-indicator')), findsOneWidget);
      expect(find.text('Compact'), findsOneWidget);
      final compactIndicator = tester.widget<FloatingActionButton>(find.byKey(const Key('breakpoint-indicator')));
      expect(compactIndicator.backgroundColor, equals(Colors.blue));
      expect(find.byKey(const Key('adaptive-nav-bottom-bar')), findsOneWidget);
      expect(find.byKey(const Key('adaptive-nav-rail')), findsNothing);
      expect(find.byKey(const Key('adaptive-nav-drawer')), findsNothing);

      // Test Medium View
      await tester.binding.setSurfaceSize(const Size(700, 800));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Medium'), findsOneWidget);
      final mediumIndicator = tester.widget<FloatingActionButton>(find.byKey(const Key('breakpoint-indicator')));
      expect(mediumIndicator.backgroundColor, equals(Colors.green));
      expect(find.byKey(const Key('adaptive-nav-rail')), findsOneWidget);
      expect(find.byKey(const Key('adaptive-nav-bottom-bar')), findsNothing);
      expect(find.byKey(const Key('adaptive-nav-drawer')), findsNothing);

      // Test Expanded View
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Expanded'), findsOneWidget);
      final expandedIndicator = tester.widget<FloatingActionButton>(find.byKey(const Key('breakpoint-indicator')));
      expect(expandedIndicator.backgroundColor, equals(Colors.purple));
      expect(find.byKey(const Key('adaptive-nav-drawer')), findsOneWidget);
      expect(find.byKey(const Key('adaptive-nav-rail')), findsNothing);
      expect(find.byKey(const Key('adaptive-nav-bottom-bar')), findsNothing);
    });

    testWidgets('Grid column count adapts', (WidgetTester tester) async {
      await app.main();
      await tester.pumpAndSettle();

      // Navigate to Grid
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      
      // Select Grid (index 1)
      await tester.tap(find.byIcon(Icons.grid_view));
      await tester.pumpAndSettle();

      // Compact: 1 column
      final compactItem0 = tester.getTopLeft(find.byKey(const Key('grid-item-0')));
      final compactItem1 = tester.getTopLeft(find.byKey(const Key('grid-item-1')));
      expect(compactItem1.dy > compactItem0.dy, isTrue);
      
      // Medium: 2 columns
      await tester.binding.setSurfaceSize(const Size(700, 800));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      final mediumItem0 = tester.getTopLeft(find.byKey(const Key('grid-item-0')));
      final mediumItem1 = tester.getTopLeft(find.byKey(const Key('grid-item-1')));
      final mediumItem2 = tester.getTopLeft(find.byKey(const Key('grid-item-2')));
      expect((mediumItem0.dy - mediumItem1.dy).abs() < 1.0, isTrue);
      expect(mediumItem2.dy > mediumItem0.dy, isTrue);

      // Expanded: 3 columns
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      final expandedItem0 = tester.getTopLeft(find.byKey(const Key('grid-item-0')));
      final expandedItem1 = tester.getTopLeft(find.byKey(const Key('grid-item-1')));
      final expandedItem2 = tester.getTopLeft(find.byKey(const Key('grid-item-2')));
      expect((expandedItem0.dy - expandedItem1.dy).abs() < 1.0, isTrue);
      expect((expandedItem1.dy - expandedItem2.dy).abs() < 1.0, isTrue);
    });
  });
}
