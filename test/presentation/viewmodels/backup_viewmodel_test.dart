import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/data/repositories/backup_repository.dart';
import 'package:aegis/presentation/viewmodels/backup_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'backup_viewmodel_test.mocks.dart';

@GenerateMocks([AppDatabase, BackupRepository])
void main() {
  group('BackupViewModel', () {
    late MockBackupRepository mockBackupRepository;
    late ProviderContainer container;

    setUp(() {
      mockBackupRepository = MockBackupRepository();
      container = ProviderContainer(
        overrides: [
          backupRepositoryProvider.overrideWithValue(mockBackupRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('exportData success', () async {
      when(mockBackupRepository.exportDatabase())
          .thenAnswer((_) => Future<void>.value());

      final listener = container.listen(
        backupViewModelProvider,
        (_, __) {},
      );

      await container.read(backupViewModelProvider.notifier).exportData();

      expect(
        listener.read(),
        const AsyncValue<void>.data(null),
      );
    });

    test('exportData failure', () async {
      final exception = Exception('Export failed');

      when(mockBackupRepository.exportDatabase()).thenThrow(exception);

      final listener = container.listen(
        backupViewModelProvider,
        (_, __) {},
      );

      await container.read(backupViewModelProvider.notifier).exportData();

      expect(
        listener.read(),
        isA<AsyncError>(),
      );
    });

    test('importData success', () async {
      when(mockBackupRepository.importDatabase())
          .thenAnswer((_) => Future<void>.value());

      final listener = container.listen(
        backupViewModelProvider,
        (_, __) {},
      );

      await container.read(backupViewModelProvider.notifier).importData();

      expect(
        listener.read(),
        const AsyncValue<void>.data(null),
      );
    });

    test('importData failure', () async {
      final exception = Exception('Import failed');

      when(mockBackupRepository.importDatabase()).thenThrow(exception);

      final listener = container.listen(
        backupViewModelProvider,
        (_, __) {},
      );

      await container.read(backupViewModelProvider.notifier).importData();

      expect(
        listener.read(),
        isA<AsyncError>(),
      );
    });
  });
}
