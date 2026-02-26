import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';

class GestureLogger {
  static Future<void> logGesture(String type, Map<String, dynamic> metadata) async {
    if (kIsWeb || Platform.environment.containsKey('FLUTTER_TEST')) return;
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/gesture_log.json');
      
      Map<String, dynamic> data = {'gestures': []};
      if (await file.exists()) {
        final content = await file.readAsString();
        data = jsonDecode(content);
      }
      
      (data['gestures'] as List).add({
        'type': type,
        'timestamp': DateTime.now().toIso8601String(),
        'metadata': metadata,
      });
      
      await file.writeAsString(jsonEncode(data));
      debugPrint('Logged gesture: $type');
    } catch (e) {
      debugPrint('Error logging gesture: $e');
    }
  }
}

class CustomGestureDemo extends StatefulWidget {
  const CustomGestureDemo({super.key});

  @override
  State<CustomGestureDemo> createState() => _CustomGestureDemoState();
}

class _CustomGestureDemoState extends State<CustomGestureDemo> {
  double _scale = 1.0;
  String _lastGesture = 'None';
  final Set<int> _activePointers = <int>{};
  final Map<int, Offset> _pointerStartPositions = <int, Offset>{};
  DateTime? _twoFingerStart;
  bool _twoFingerMoved = false;
  bool _pinchDetected = false;
  bool _twoFingerTapLogged = false;

  static const double _tapMoveThreshold = 18.0;
  static const int _tapDurationThresholdMs = 250;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        _activePointers.add(event.pointer);
        _pointerStartPositions[event.pointer] = event.position;

        if (_activePointers.length == 2) {
          _twoFingerStart = DateTime.now();
          _twoFingerMoved = false;
          _twoFingerTapLogged = false;
        }
      },
      onPointerMove: (event) {
        if (_activePointers.length >= 2) {
          final start = _pointerStartPositions[event.pointer];
          if (start != null && (event.position - start).distance > _tapMoveThreshold) {
            _twoFingerMoved = true;
          }
        }
      },
      onPointerUp: (event) {
        if (_activePointers.length >= 2 && !_twoFingerTapLogged) {
          final start = _twoFingerStart;
          if (start != null && !_twoFingerMoved) {
            final elapsedMs = DateTime.now().difference(start).inMilliseconds;
            if (elapsedMs <= _tapDurationThresholdMs) {
              setState(() => _lastGesture = 'Two-finger-tap');
              GestureLogger.logGesture('two-finger-tap', {'durationMs': elapsedMs});
              _twoFingerTapLogged = true;
            }
          }
        }

        _activePointers.remove(event.pointer);
        _pointerStartPositions.remove(event.pointer);

        if (_activePointers.length < 2) {
          _twoFingerStart = null;
          _twoFingerMoved = false;
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onScaleStart: (details) {
          _pinchDetected = false;
        },
        onScaleUpdate: (details) {
          if (details.pointerCount >= 2 && (details.scale - 1.0).abs() > 0.02) {
            _pinchDetected = true;
            setState(() {
              _scale = details.scale;
              _lastGesture = 'Pinch-to-zoom';
            });
          } else if (details.pointerCount == 1) {
            setState(() => _lastGesture = 'Swipe');
          }
        },
        onScaleEnd: (details) {
          if (_twoFingerTapLogged) {
            _twoFingerTapLogged = false;
            return;
          }

          if (_pinchDetected) {
            GestureLogger.logGesture('pinch-to-zoom', {'finalScale': _scale});
          } else {
            GestureLogger.logGesture('swipe', {'velocity': details.velocity.toString()});
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Perform gestures here', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 20),
              Container(
                width: 200,
                height: 200,
                color: Colors.blue.withValues(alpha: 0.3),
                child: Center(child: Text('Last: $_lastGesture')),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() => _lastGesture = 'Two-finger-tap');
                  GestureLogger.logGesture('two-finger-tap', {'source': 'button'});
                },
                child: const Text('Simulate Two-finger-tap'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
