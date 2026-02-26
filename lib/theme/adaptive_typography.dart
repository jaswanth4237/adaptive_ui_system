import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../responsive/breakpoints.dart';

class TypographyConfig {
  final double baselineFontSize;
  final Map<String, double> scaleFactors;
  final double minimumFontSize;
  final double maximumFontSize;

  TypographyConfig({
    required this.baselineFontSize,
    required this.scaleFactors,
    required this.minimumFontSize,
    required this.maximumFontSize,
  });

  factory TypographyConfig.fromJson(Map<String, dynamic> json) {
    return TypographyConfig(
      baselineFontSize: (json['baselineFontSize'] as num).toDouble(),
      scaleFactors: Map<String, double>.from(
        (json['scaleFactors'] as Map).map((k, v) => MapEntry(k, (v as num).toDouble())),
      ),
      minimumFontSize: (json['minimumFontSize'] as num).toDouble(),
      maximumFontSize: (json['maximumFontSize'] as num).toDouble(),
    );
  }
}

class AdaptiveTypography extends ChangeNotifier {
  TypographyConfig? _config;

  TypographyConfig? get config => _config;

  Future<void> loadConfig() async {
    final String response = await rootBundle.loadString('assets/typography_config.json');
    final data = await json.decode(response);
    _config = TypographyConfig.fromJson(data);
    notifyListeners();
  }

  double getFontSize(BuildContext context, double multiplier) {
    if (_config == null) return 16.0;

    final width = MediaQuery.of(context).size.width;
    final breakpoint = Breakpoint.fromWidth(width);
    final scale = _config!.scaleFactors[breakpoint.label.toLowerCase()] ?? 1.0;
    
    double size = _config!.baselineFontSize * scale * multiplier;
    
    if (size < _config!.minimumFontSize) size = _config!.minimumFontSize;
    if (size > _config!.maximumFontSize) size = _config!.maximumFontSize;
    
    return size;
  }
}

extension AdaptiveTypographyExtension on BuildContext {
  double responsiveFontSize(double multiplier) {
    return 16.0 * multiplier;
  }
}
