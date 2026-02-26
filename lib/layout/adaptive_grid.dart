import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../responsive/breakpoints.dart';

class AdaptiveGrid extends StatefulWidget {
  const AdaptiveGrid({super.key});

  @override
  State<AdaptiveGrid> createState() => _AdaptiveGridState();
}

class _AdaptiveGridState extends State<AdaptiveGrid> {
  double _aspectRatio = 1.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _aspectRatio = prefs.getDouble('grid_aspect_ratio') ?? 1.0;
    });
  }

  Future<void> _saveSettings(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('grid_aspect_ratio', value);
    setState(() {
      _aspectRatio = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final breakpoint = Breakpoint.fromWidth(width);
    
    int columns = 1;
    if (breakpoint.type == BreakpointType.medium) {
      columns = 2;
    } else if (breakpoint.type == BreakpointType.expanded) {
      columns = 3;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Text('Aspect Ratio: '),
              Expanded(
                child: Slider(
                  value: _aspectRatio,
                  min: 0.5,
                  max: 2.0,
                  onChanged: _saveSettings,
                ),
              ),
              Text(_aspectRatio.toStringAsFixed(1)),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              childAspectRatio: _aspectRatio,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: 20,
            itemBuilder: (context, index) {
              return Card(
                key: Key('grid-item-$index'),
                color: Colors.blue.withValues(alpha: 0.1),
                child: Center(child: Text('Item $index')),
              );
            },
          ),
        ),
      ],
    );
  }
}
