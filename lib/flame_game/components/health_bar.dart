import 'package:flame/components.dart';
import 'package:flutter/material.dart';

mixin HealthBar on PositionComponent {
  late double maxHealth;
  late double currentHealth;
  late final RectangleComponent healthBar;

  void initHealthBar(double maxHealthValue, double width) {
    maxHealth = maxHealthValue;
    currentHealth = maxHealth;
    healthBar = RectangleComponent(
      size: Vector2(width, 2), // Set the size of the health bar
      paint: Paint()..color = Colors.green,
      anchor: Anchor.topLeft,
    );
    add(healthBar);
  }

  void updateHealthBar(double value) {
    currentHealth = value.clamp(0, maxHealth);
    healthBar.size.x = (currentHealth / maxHealth) * width; // Update the width of the health bar
    healthBar.paint.color = currentHealth > maxHealth * 0.5 ? Colors.green : Colors.red; // Change color based on health
  }

  @override
  void onMount() {
    super.onMount();
    // Position the health bar relative to the component
    healthBar.position = Vector2(0, -10); // Position above the component
  }
}