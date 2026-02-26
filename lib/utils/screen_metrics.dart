import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';

class ScreenMetricsTracker {
  static Future<void> logMetrics(BuildContext context) async {
    if (kIsWeb || Platform.environment.containsKey('FLUTTER_TEST')) return;
    try {
      final MediaQueryData mediaQuery = MediaQuery.of(context);
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/screen_metrics.json');
      
      final metrics = {
        'screenWidth': mediaQuery.size.width,
        'screenHeight': mediaQuery.size.height,
        'pixelDensity': mediaQuery.devicePixelRatio,
        'textScaleFactor': mediaQuery.textScaler.scale(1.0),
        'orientation': mediaQuery.orientation.toString().split('.').last,
        'platform': Platform.operatingSystem,
        'platformVersion': Platform.operatingSystemVersion,
      };
      
      await file.writeAsString(jsonEncode(metrics));
      debugPrint('Logged screen metrics');
    } catch (e) {
      debugPrint('Error logging screen metrics: $e');
    }
  }
}
