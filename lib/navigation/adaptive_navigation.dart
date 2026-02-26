import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import '../responsive/breakpoints.dart';

class NavDestination {
  final String label;
  final IconData icon;
  final String route;

  const NavDestination({
    required this.label,
    required this.icon,
    required this.route,
  });
}

const List<NavDestination> destinations = [
  NavDestination(label: 'Home', icon: Icons.home, route: '/'),
  NavDestination(label: 'Grid', icon: Icons.grid_view, route: '/grid'),
  NavDestination(label: 'Constraint', icon: Icons.layers, route: '/constraint'),
  NavDestination(label: 'Gestures', icon: Icons.gesture, route: '/gestures'),
];

class AdaptiveNavigationScaffold extends StatefulWidget {
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const AdaptiveNavigationScaffold({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  State<AdaptiveNavigationScaffold> createState() => _AdaptiveNavigationScaffoldState();
}

class _AdaptiveNavigationScaffoldState extends State<AdaptiveNavigationScaffold> {
  @override
  void initState() {
    super.initState();
    _saveNavigationState();
  }

  @override
  void didUpdateWidget(AdaptiveNavigationScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _saveNavigationState();
    }
  }

  Future<void> _saveNavigationState() async {
    if (kIsWeb || Platform.environment.containsKey('FLUTTER_TEST')) return;
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/navigation_state.json');

      final currentRoute = destinations[widget.selectedIndex].route;
      List<String> navigationHistory = [];

      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.trim().isNotEmpty) {
          final decoded = jsonDecode(content);
          final existingHistory = decoded['navigationHistory'];
          if (existingHistory is List) {
            navigationHistory = existingHistory.map((item) => item.toString()).toList();
          }
        }
      }

      if (navigationHistory.isEmpty || navigationHistory.last != currentRoute) {
        navigationHistory.add(currentRoute);
      }

      if (navigationHistory.length > 100) {
        navigationHistory = navigationHistory.sublist(navigationHistory.length - 100);
      }

      final state = {
        'currentRoute': currentRoute,
        'navigationHistory': navigationHistory,
        'lastNavigationTimestamp': DateTime.now().toIso8601String(),
      };
      
      await file.writeAsString(jsonEncode(state));
    } catch (e) {
      debugPrint('Error saving navigation state: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final breakpoint = Breakpoint.fromWidth(width);

    if (breakpoint.type == BreakpointType.compact) {
      return Scaffold(
        body: widget.body,
        bottomNavigationBar: BottomNavigationBar(
          key: const Key('adaptive-nav-bottom-bar'),
          currentIndex: widget.selectedIndex,
          onTap: widget.onDestinationSelected,
          type: BottomNavigationBarType.fixed,
          items: destinations.map((d) => BottomNavigationBarItem(
            icon: Icon(d.icon),
            label: d.label,
          )).toList(),
        ),
        floatingActionButton: const BreakpointIndicator(),
      );
    }

    if (breakpoint.type == BreakpointType.medium) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              key: const Key('adaptive-nav-rail'),
              selectedIndex: widget.selectedIndex,
              onDestinationSelected: widget.onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              destinations: destinations.map((d) => NavigationRailDestination(
                icon: Icon(d.icon),
                label: Text(d.label),
              )).toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: widget.body),
          ],
        ),
        floatingActionButton: const BreakpointIndicator(),
      );
    }

    // Expanded
    return Scaffold(
      body: Row(
        children: [
          Drawer(
            key: const Key('adaptive-nav-drawer'),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(color: Colors.blue),
                  child: Center(child: Text('Adaptive UI', style: TextStyle(color: Colors.white, fontSize: 24))),
                ),
                ...destinations.asMap().entries.map((entry) {
                  final index = entry.key;
                  final d = entry.value;
                  return ListTile(
                    leading: Icon(d.icon),
                    title: Text(d.label),
                    selected: widget.selectedIndex == index,
                    onTap: () => widget.onDestinationSelected(index),
                  );
                }),
              ],
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: widget.body),
        ],
      ),
      floatingActionButton: const BreakpointIndicator(),
    );
  }
}
