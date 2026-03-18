import 'package:aegis/data/local/database/app_database.dart';

class BlacklistRepository {
  final AppDatabase _db;

  BlacklistRepository(this._db);

  Future<List<BlacklistedApp>> getAllBlacklistedApps() {
    return _db.select(_db.blacklistedApps).get();
  }

  Stream<List<BlacklistedApp>> watchAllBlacklistedApps() {
    return _db.select(_db.blacklistedApps).watch();
  }

  Future<int> insertBlacklistedApp(BlacklistedAppsCompanion app) {
    return _db.into(_db.blacklistedApps).insert(app);
  }

  Future<int> deleteBlacklistedApp(String packageName) {
    return (_db.delete(_db.blacklistedApps)
          ..where((b) => b.packageName.equals(packageName)))
        .go();
  }
}
