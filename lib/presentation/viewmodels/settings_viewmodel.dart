import 'package:aegis/core/providers/repository_providers.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/data/repositories/settings_repository.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsViewmodel extends StreamNotifier<Setting?> {
  SettingsRepository get _repository => ref.read(settingsRepositoryProvider);

  @override
  Stream<Setting?> build() {
    return _repository.watchSettings();
  }

  Future<void> upsertSettings(
      int? pomodoroDuration, int? shortBreakDuration, int? longBreakDuration) {
    final settings = SettingsCompanion(
      pomodoroDuration: pomodoroDuration != null
          ? Value(pomodoroDuration)
          : const Value.absent(),
      shortBreakDuration: shortBreakDuration != null
          ? Value(shortBreakDuration)
          : const Value.absent(),
      longBreakDuration: longBreakDuration != null
          ? Value(longBreakDuration)
          : const Value.absent(),
    );
    return _repository.upsertSettings(settings);
  }

  Future<void> deleteSettings() {
    return _repository.deleteSettings();
  }
}

final settingsViewModelProvider =
    StreamNotifierProvider<SettingsViewmodel, Setting?>(
        () => SettingsViewmodel());
