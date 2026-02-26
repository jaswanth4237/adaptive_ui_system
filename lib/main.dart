import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'responsive/breakpoints.dart';
import 'navigation/adaptive_navigation.dart';
import 'theme/adaptive_typography.dart';
import 'layout/transition_manager.dart';
import 'layout/constraint_system.dart';
import 'layout/adaptive_grid.dart';
import 'gestures/custom_gestures.dart';
import 'utils/screen_metrics.dart';
import 'performance/layout_performance.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final typography = AdaptiveTypography();
  await typography.loadConfig();
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => typography,
      child: const AdaptiveApp(),
    ),
  );
}

class AdaptiveApp extends StatelessWidget {
  const AdaptiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adaptive UI System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MainScaffold(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const AdaptiveGridScreen(),
    const ConstraintLayoutScreen(),
    const GestureDemoScreen(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ScreenMetricsTracker.logMetrics(context);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final breakpoint = Breakpoint.fromWidth(width);

    return LayoutTransitionManager(
      child: PerformanceMonitor(
        widgetName: 'MainScaffold',
        currentBreakpoint: breakpoint.label,
        child: AdaptiveNavigationScaffold(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          body: _screens[_selectedIndex],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Welcome to Adaptive UI',
            style: TextStyle(
              fontSize: context.read<AdaptiveTypography>().getFontSize(context, 2.0),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Text('Resize the window to see changes!'),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => ScreenMetricsTracker.logMetrics(context),
            child: const Text('Refresh Metrics'),
          ),
        ],
      ),
    );
  }
}

class AdaptiveGridScreen extends StatelessWidget {
  const AdaptiveGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdaptiveGrid();
  }
}

class ConstraintLayoutScreen extends StatelessWidget {
  const ConstraintLayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstraintLayoutBuilder(
      children: {
        'box1': Container(color: Colors.red, child: const Center(child: Text('Box 1'))),
        'box2': Container(color: Colors.green, child: const Center(child: Text('Box 2'))),
      },
    );
  }
}

class GestureDemoScreen extends StatelessWidget {
  const GestureDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomGestureDemo();
  }
}
