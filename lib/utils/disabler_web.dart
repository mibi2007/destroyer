import 'disabler.dart';

// Simplified web utilities to avoid complex JS interop issues
// This is a placeholder implementation that can be expanded as needed

void customGameInput() {
  // Debug: print('customGameInput');

  // Note: Web-specific input handling is disabled for now
  // to avoid JS interop complexity. This can be re-implemented
  // using dart:js_interop when needed.

  _afterRightClick();
}

void _afterRightClick() {
  // Placeholder for right-click handling
  // This would normally set up mouse event listeners
  // but is simplified to avoid JS interop issues

  // For now, we'll just trigger the default behaviors
  // These can be called from other parts of the app as needed
  rightClick.update();
  leftClick.update();
}
