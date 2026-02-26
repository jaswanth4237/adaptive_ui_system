import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_ui_system/responsive/breakpoints.dart';

void main() {
  group('Breakpoint Logic Tests', () {
    test('Should return Compact for width < 600', () {
      final breakpoint = Breakpoint.fromWidth(500);
      expect(breakpoint.type, BreakpointType.compact);
      expect(breakpoint.label, 'Compact');
    });

    test('Should return Medium for 600 <= width < 840', () {
      final breakpoint = Breakpoint.fromWidth(700);
      expect(breakpoint.type, BreakpointType.medium);
      expect(breakpoint.label, 'Medium');
    });

    test('Should return Expanded for width >= 840', () {
      final breakpoint = Breakpoint.fromWidth(1000);
      expect(breakpoint.type, BreakpointType.expanded);
      expect(breakpoint.label, 'Expanded');
    });
  });
}
