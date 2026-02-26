import 'package:flutter/material.dart';

enum BreakpointType { compact, medium, expanded }

class Breakpoint {
  final BreakpointType type;
  final String label;
  final Color color;

  Breakpoint({required this.type, required this.label, required this.color});

  static Breakpoint fromWidth(double width) {
    if (width < 600) {
      return Breakpoint(
        type: BreakpointType.compact,
        label: 'Compact',
        color: Colors.blue,
      );
    } else if (width < 840) {
      return Breakpoint(
        type: BreakpointType.medium,
        label: 'Medium',
        color: Colors.green,
      );
    } else {
      return Breakpoint(
        type: BreakpointType.expanded,
        label: 'Expanded',
        color: Colors.purple,
      );
    }
  }
}

class BreakpointIndicator extends StatelessWidget {
  const BreakpointIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final breakpoint = Breakpoint.fromWidth(width);

    return FloatingActionButton.extended(
      key: const Key('breakpoint-indicator'),
      onPressed: () {},
      label: Text(
        breakpoint.label,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: breakpoint.color,
    );
  }
}
