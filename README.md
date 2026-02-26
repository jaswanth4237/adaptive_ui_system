# Adaptive UI System

A sophisticated Flutter application featuring a dynamic, adaptive UI that responds to various screen properties.

## Features

- **Breakpoint System**: Supports Compact (<600dp), Medium (600-839dp), and Expanded (840dp+) layouts.
- **Adaptive Navigation**: Switches between Bottom Navigation Bar, Navigation Rail, and Permanent Navigation Drawer.
- **Simplified Constraint Layout**: Custom parser and resolver for relative widget positioning.
- **Adaptive Typography**: Font sizes scale based on screen width using external JSON configuration.
- **Custom Gesture Recognition**: Logs swipes, pinch-to-zoom, and simulated multi-finger taps.
- **Responsive Grid**: Adapts column counts and persists user-defined aspect ratios.
- **Monitoring & Logging**:
  - Layout transitions logged to `layout_transitions.log`.
  - Screen metrics exported to `screen_metrics.json`.
  - Rebuild performance tracked in `layout_performance.json`.
  - Gestures recorded in `gesture_log.json`.
  - Navigation state persisted in `navigation_state.json`.

## Project Structure

- `lib/layout/`: Constraint system and adaptive grid.
- `lib/navigation/`: Adaptive navigation scaffold.
- `lib/responsive/`: Breakpoint logic.
- `lib/theme/`: Adaptive typography system.
- `lib/gestures/`: Gesture logging and demo.
- `lib/performance/`: Rebuild monitoring.
- `lib/utils/`: Screen metrics tracking.
- `assets/`: Configuration files for constraints and typography.
- `integration_test/`: Automated responsive flow tests.

## Build Instructions

### Local Build
```bash
flutter pub get
flutter build apk --release
```

### Docker Build
```bash
docker build . -t adaptive-ui-builder
```

## Testing
```bash
flutter test integration_test/responsive_flow_test.dart
```
