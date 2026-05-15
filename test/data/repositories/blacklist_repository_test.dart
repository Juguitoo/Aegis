import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/data/repositories/blacklist_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late BlacklistRepository blacklistRepository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory(
      setup: (db) {
        db.execute('PRAGMA foreign_keys = ON;');
      },
    ));
    blacklistRepository = BlacklistRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('BlacklistRepository Persistencia CRUD', () {
    test(
        'Debe insertar una aplicación en la lista negra y leerla de la base de datos',
        () async {
      const packageName = 'com.example.app';
      const appName = 'Example App';
      await blacklistRepository.addAppToBlacklist(packageName, appName);

      final entries = await blacklistRepository.getBlacklistedPackages();
      expect(entries.length, 1);
      expect(entries.first, 'com.example.app');
    });

    test('Debe eliminar una aplicación de la lista negra', () async {
      const packageName = 'com.example.app';
      const appName = 'Example App';
      await blacklistRepository.addAppToBlacklist(packageName, appName);
      var entries = await blacklistRepository.getBlacklistedPackages();
      expect(entries, isNotEmpty);

      await blacklistRepository.removeAppFromBlacklist(packageName);
      entries = await blacklistRepository.getBlacklistedPackages();
      expect(entries.isEmpty, true);
    });

    test(
        'watchBlacklistedPackages devuelve un stream y detecta los cambios correctamente',
        () async {
      const packageName = 'com.example.app';
      const appName = 'Example App';
      await blacklistRepository.addAppToBlacklist(packageName, appName);
      final entriesStream = blacklistRepository.watchBlacklistedPackages();
      var entries = await entriesStream.first;
      expect(entries, isNotEmpty);

      await blacklistRepository.removeAppFromBlacklist(packageName);
      entries = await entriesStream.first;
      expect(entries.isEmpty, true);
    });
  });
}
