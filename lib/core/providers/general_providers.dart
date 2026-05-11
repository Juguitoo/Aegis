import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 2);
final taskToOpenProvider = StateProvider<int?>((ref) => null);
final devModeProvider = StateProvider<bool>((ref) => false);
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);
final textScaleProvider = StateProvider<double>((ref) {
  return 1.0;
});
