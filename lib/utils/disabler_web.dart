import 'dart:html' as html;
import 'disabler.dart';

// Web-specific utilities for handling mouse events
void customGameInput() {
  // Disable right-click context menu on the entire page
  _disableContextMenu();
}

void _disableContextMenu() {
  // Prevent the default context menu from appearing on right-click
  html.document.onContextMenu.listen((event) {
    event.preventDefault();
  });
}

void _afterRightClick() {
  // This method can be called when right-click actions are needed
  rightClick.update();
}
