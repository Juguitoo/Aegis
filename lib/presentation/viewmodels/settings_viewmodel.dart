import 'package:aegis/core/providers/repository_providers.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/data/repositories/sessions_repository.dart';
import 'package:aegis/data/repositories/settings_repository.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsViewmodel extends StreamNotifier<Setting?> {
  late final SettingsRepository _settingsRepository;
  late final SessionRepository _sessionRepository;

  @override
  Stream<Setting?> build() {
    _settingsRepository = ref.read(settingsRepositoryProvider);
    _sessionRepository = ref.read(sessionRepositoryProvider);
    return _settingsRepository.watchSettings();
  }

  Future<void> upsertSettings(
      {int? pomodoroDuration,
      int? shortBreakDuration,
      int? longBreakDuration}) {
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
    return _settingsRepository.upsertSettings(settings);
  }

  Future<void> deleteSettings() {
    return _settingsRepository.deleteSettings();
  }

  Future<void> deleteSessionData() {
    return _sessionRepository.deleteAllSessions();
  }

  Future<void> deleteAllData() {
    return _settingsRepository.deleteAllData();
  }
}

final settingsViewModelProvider =
    StreamNotifierProvider<SettingsViewmodel, Setting?>(
        () => SettingsViewmodel());
