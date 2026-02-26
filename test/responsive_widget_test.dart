import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_ui_system/main.dart';
import 'package:adaptive_ui_system/theme/adaptive_typography.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Responsive Flow Widget Tests', () {
    testWidgets('Verify breakpoint indicator and navigation switching', (WidgetTester tester) async {
      final typography = AdaptiveTypography();
      await typography.loadConfig();
      
      // Set initial size to Compact
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => typography,
          child: const AdaptiveApp(),
        ),
      );
      
      // Pump multiple times to ensure LayoutBuilder and Transitions settle
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Verify Compact View elements by Key first
      expect(find.byKey(const Key('breakpoint-indicator')), findsOneWidget);
      expect(find.byKey(const Key('adaptive-nav-bottom-bar')), findsOneWidget);
      
      // If we find the indicator, let's see if the text is there
      // Sometimes it's nested or needs more pumps
      expect(find.text('Compact'), findsOneWidget);

      // Switch to Medium
      tester.view.physicalSize = const Size(700, 800);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      
      expect(find.text('Medium'), findsOneWidget);
      expect(find.byKey(const Key('adaptive-nav-rail')), findsOneWidget);

      // Switch to Expanded
      tester.view.physicalSize = const Size(1000, 800);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      
      expect(find.text('Expanded'), findsOneWidget);
      expect(find.byKey(const Key('adaptive-nav-drawer')), findsOneWidget);
    });
  });
}
