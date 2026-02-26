import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import '../responsive/breakpoints.dart';

class TransitionLogger {
  static Future<void> logTransition(BreakpointType from, BreakpointType to) async {
    if (kIsWeb || Platform.environment.containsKey('FLUTTER_TEST')) return;
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/layout_transitions.log');
      
      final timestamp = DateTime.now().toIso8601String();
      final fromStr = from.toString().split('.').last;
      final toStr = to.toString().split('.').last;
      const duration = 300; // Expected duration
      
      final logEntry = '[$timestamp] $fromStr $toStr $duration\n';
      
      await file.writeAsString(logEntry, mode: FileMode.append);
      debugPrint('Logged transition: $fromStr -> $toStr');
    } catch (e) {
      debugPrint('Error logging transition: $e');
    }
  }
}

class LayoutTransitionManager extends StatefulWidget {
  final Widget child;

  const LayoutTransitionManager({super.key, required this.child});

  @override
  State<LayoutTransitionManager> createState() => _LayoutTransitionManagerState();
}

class _LayoutTransitionManagerState extends State<LayoutTransitionManager> {
  BreakpointType? _lastBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final currentBreakpoint = Breakpoint.fromWidth(constraints.maxWidth).type;
        
        if (_lastBreakpoint != null && _lastBreakpoint != currentBreakpoint) {
          TransitionLogger.logTransition(_lastBreakpoint!, currentBreakpoint);
        }
        
        _lastBreakpoint = currentBreakpoint;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: KeyedSubtree(
            key: ValueKey(currentBreakpoint),
            child: widget.child,
          ),
        );
      },
    );
  }
}
