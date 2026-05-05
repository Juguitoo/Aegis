import 'package:flutter_riverpod/legacy.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 2);
final taskToOpenProvider = StateProvider<int?>((ref) => null);
final devModeProvider = StateProvider<bool>((ref) => false);
