import 'package:drift/drift.dart';
import 'package:aegis/data/local/database/app_database.dart';

class BlacklistRepository {
  final AppDatabase _db;

  BlacklistRepository(this._db);

  Stream<List<String>> watchBlacklistedPackages() {
    return _db.select(_db.blacklistedApps).watch().map((rows) {
      return rows.map((row) => row.packageName).toList();
    });
  }

  Future<int> addAppToBlacklist(String packageName, String appName) {
    return _db.into(_db.blacklistedApps).insert(
          BlacklistedAppsCompanion.insert(
            packageName: packageName,
            appName: appName,
          ),
          mode: InsertMode.insertOrIgnore,
        );
  }

  Future<int> removeAppFromBlacklist(String packageName) {
    return (_db.delete(_db.blacklistedApps)
          ..where((t) => t.packageName.equals(packageName)))
        .go();
  }
}
