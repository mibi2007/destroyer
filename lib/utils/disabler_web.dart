// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html';

import 'disabler.dart';

MutationObserver? observer;

void startObserving() {
  observer = MutationObserver((mutations, observer) {
    final canvas = querySelector('flutter-view');
    if (canvas != null) {
      window.console.log('Canvas is now available');
      // Do something with the canvas
      observer.disconnect(); // Stop observing once the canvas is available
    }
  });

  observer!.observe(
    document.querySelector('flutter-view')!,
    childList: true,
    subtree: true,
  );
}

void disableRightClick() {
  print('disableRightClick');
  document.onContextMenu.listen((event) => event.preventDefault());
  _afterRightClick();
  document.addEventListener('keydown', (e) {
    if (e is KeyboardEvent && (e.keyCode == 9 || e.keyCode == 27)) {
      e.preventDefault();
    }
  });
}

_afterRightClick() {
  // startObserving();
  final canvas = querySelector('flutter-view');

  // Prevent the default right-click context menu
  canvas?.addEventListener('contextmenu', (Event e) {
    e.preventDefault();
  });

  // Add your custom right-click logic
  canvas?.addEventListener('mousedown', (Event e) {
    // Check if the right mouse button was clicked
    if (e is MouseEvent && e.button == 2) {
      // Implement your custom right-click logic here
      rightClick.update();
    } else {
      leftClick.update();
    }
  });
}