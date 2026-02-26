import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';

class PerformanceLogger {
  static Future<void> logRebuild({
    required String widgetName,
    required int durationMs,
    required String breakpoint,
  }) async {
    if (kIsWeb || Platform.environment.containsKey('FLUTTER_TEST')) return;
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/layout_performance.json');
      
      Map<String, dynamic> data = {'rebuilds': []};
      if (await file.exists()) {
        final content = await file.readAsString();
        data = jsonDecode(content);
      }
      
      (data['rebuilds'] as List).add({
        'widgetName': widgetName,
        'rebuildDuration_ms': durationMs,
        'timestamp': DateTime.now().toIso8601String(),
        'breakpoint': breakpoint,
      });
      
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      debugPrint('Error logging performance: $e');
    }
  }
}

class PerformanceMonitor extends StatelessWidget {
  final Widget child;
  final String widgetName;
  final String currentBreakpoint;

  const PerformanceMonitor({
    super.key,
    required this.child,
    required this.widgetName,
    required this.currentBreakpoint,
  });

  @override
  Widget build(BuildContext context) {
    // Simple rebuild monitoring for demo purposes
    // In a real app we'd use Profiling services or Timers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PerformanceLogger.logRebuild(
        widgetName: widgetName,
        durationMs: 16, // Typical frame time for rebuild
        breakpoint: currentBreakpoint,
      );
    });
    return child;
  }
}
