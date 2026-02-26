import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LayoutConstraint {
  final String widgetId;
  final String constraint;
  final String targetId;
  final double margin;

  LayoutConstraint({
    required this.widgetId,
    required this.constraint,
    required this.targetId,
    required this.margin,
  });

  factory LayoutConstraint.fromJson(Map<String, dynamic> json) {
    return LayoutConstraint(
      widgetId: json['widgetId'],
      constraint: json['constraint'],
      targetId: json['targetId'],
      margin: (json['margin'] as num).toDouble(),
    );
  }
}

class ConstraintLayoutBuilder extends StatefulWidget {
  final Map<String, Widget> children;

  const ConstraintLayoutBuilder({super.key, required this.children});

  @override
  State<ConstraintLayoutBuilder> createState() => _ConstraintLayoutBuilderState();
}

class _ConstraintLayoutBuilderState extends State<ConstraintLayoutBuilder> {
  List<LayoutConstraint> _constraints = [];
  final Map<String, Size> _childSizes = {};

  @override
  void initState() {
    super.initState();
    _loadConstraints();
  }

  Future<void> _loadConstraints() async {
    final String response = await rootBundle.loadString('assets/layout_constraints.json');
    final data = await json.decode(response);
    setState(() {
      _constraints = (data['constraints'] as List)
          .map((c) => LayoutConstraint.fromJson(c))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final parentSize = Size(constraints.maxWidth, constraints.maxHeight);
        
        // Simplified resolver: assumes children have fixed sizes or we measure them
        // For this demo, let's assume children are 100x100 if not specified
        final Map<String, Offset> positions = {};
        
        // Initial pass: put everything at 0,0
        for (var id in widget.children.keys) {
          positions[id] = Offset.zero;
          _childSizes[id] = const Size(100, 100); 
        }

        // Apply constraints (single pass for simplicity as per requirements)
        for (var c in _constraints) {
          if (!widget.children.containsKey(c.widgetId)) continue;
          
          Offset currentPos = positions[c.widgetId]!;
          Size currentSize = _childSizes[c.widgetId]!;
          
          Offset targetPos = Offset.zero;
          Size targetSize = parentSize;
          
          if (c.targetId != 'parent' && widget.children.containsKey(c.targetId)) {
             targetPos = positions[c.targetId]!;
             targetSize = _childSizes[c.targetId]!;
          }

          switch (c.constraint) {
            case 'centerX':
              positions[c.widgetId] = Offset(
                targetPos.dx + (targetSize.width - currentSize.width) / 2 + c.margin,
                currentPos.dy,
              );
              break;
            case 'centerY':
              positions[c.widgetId] = Offset(
                currentPos.dx,
                targetPos.dy + (targetSize.height - currentSize.height) / 2 + c.margin,
              );
              break;
            case 'topToTopOf':
              positions[c.widgetId] = Offset(currentPos.dx, targetPos.dy + c.margin);
              break;
            case 'bottomToBottomOf':
              positions[c.widgetId] = Offset(
                currentPos.dx,
                targetPos.dy + targetSize.height - currentSize.height - c.margin,
              );
              break;
            case 'leftToRightOf':
              positions[c.widgetId] = Offset(targetPos.dx + targetSize.width + c.margin, currentPos.dy);
              break;
            case 'rightToLeftOf':
              positions[c.widgetId] = Offset(targetPos.dx - currentSize.width - c.margin, currentPos.dy);
              break;
          }
        }

        return Stack(
          children: widget.children.entries.map((entry) {
            final id = entry.key;
            final child = entry.value;
            final pos = positions[id] ?? Offset.zero;
            return Positioned(
              left: pos.dx,
              top: pos.dy,
              width: 100,
              height: 100,
              child: child,
            );
          }).toList(),
        );
      },
    );
  }
}
