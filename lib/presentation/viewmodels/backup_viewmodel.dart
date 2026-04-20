import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aegis/data/repositories/backup_repository.dart';
import 'package:aegis/core/providers/database_provider.dart';
import 'package:flutter_riverpod/legacy.dart';

final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  return BackupRepository(ref.watch(databaseProvider));
});

final backupViewModelProvider =
    StateNotifierProvider<BackupViewModel, AsyncValue<void>>((ref) {
  return BackupViewModel(ref.watch(backupRepositoryProvider));
});

class BackupViewModel extends StateNotifier<AsyncValue<void>> {
  final BackupRepository _repository;

  BackupViewModel(this._repository) : super(const AsyncValue.data(null));

  Future<void> exportData() async {
    state = const AsyncValue.loading();
    try {
      await _repository.exportDatabase();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> importData() async {
    state = const AsyncValue.loading();
    try {
      await _repository.importDatabase();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
