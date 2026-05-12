import 'package:aegis/core/providers/repository_providers.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/data/repositories/sessions_repository.dart';
import 'package:aegis/data/repositories/settings_repository.dart';
import 'package:aegis/presentation/viewmodels/settings_viewmodel.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'settings_viewmodel_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SettingsRepository>(),
  MockSpec<SessionRepository>(),
])
void main() {
  group('SettingsViewModel', () {
    late MockSettingsRepository mockSettingsRepository;
    late MockSessionRepository mockSessionRepository;
    late ProviderContainer container;

    setUp(() {
      mockSettingsRepository = MockSettingsRepository();
      mockSessionRepository = MockSessionRepository();
      container = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(mockSettingsRepository),
          sessionRepositoryProvider.overrideWithValue(mockSessionRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('settings are fetched from repository', () {
      final settings = Setting(
        id: 1,
        pomodoroDuration: 25,
        shortBreakDuration: 5,
        longBreakDuration: 15,
      );

      when(mockSettingsRepository.watchSettings())
          .thenAnswer((_) => Stream.value(settings));

      final listener = container.listen(settingsViewModelProvider, (_, __) {});

      expect(
        listener.read(),
        const AsyncValue<Setting?>.loading(),
      );
    });

    test('upsertSettings with all values', () async {
      when(mockSettingsRepository.upsertSettings(any))
          .thenAnswer((_) => Future.value(1));

      await container.read(settingsViewModelProvider.notifier).upsertSettings(
            pomodoroDuration: 30,
            shortBreakDuration: 6,
            longBreakDuration: 20,
          );

      final captured = verify(mockSettingsRepository.upsertSettings(captureAny))
          .captured
          .single;
      expect(captured.pomodoroDuration.value, 30);
      expect(captured.shortBreakDuration.value, 6);
      expect(captured.longBreakDuration.value, 20);
    });

    test('upsertSettings with partial values', () async {
      when(mockSettingsRepository.upsertSettings(any))
          .thenAnswer((_) => Future.value(1));

      await container.read(settingsViewModelProvider.notifier).upsertSettings(
            pomodoroDuration: 35,
          );

      final captured = verify(mockSettingsRepository.upsertSettings(captureAny))
          .captured
          .single;
      expect(captured.pomodoroDuration.value, 35);
      expect(captured.shortBreakDuration, const Value.absent());
      expect(captured.longBreakDuration, const Value.absent());
    });

    test('deleteSettings calls repository', () async {
      when(mockSettingsRepository.deleteSettings())
          .thenAnswer((_) => Future.value(1));

      await container.read(settingsViewModelProvider.notifier).deleteSettings();

      verify(mockSettingsRepository.deleteSettings()).called(1);
    });

    test('deleteSessionData calls repository', () async {
      when(mockSessionRepository.deleteAllSessions())
          .thenAnswer((_) => Future.value());

      await container
          .read(settingsViewModelProvider.notifier)
          .deleteSessionData();

      verify(mockSessionRepository.deleteAllSessions()).called(1);
    });

    test('deleteAllData calls repository', () async {
      when(mockSettingsRepository.deleteAllData())
          .thenAnswer((_) => Future.value());

      await container.read(settingsViewModelProvider.notifier).deleteAllData();

      verify(mockSettingsRepository.deleteAllData()).called(1);
    });
  });
}
