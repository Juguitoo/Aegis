import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:aegis/data/local/database/app_database.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

class SessionRepository {
  final AppDatabase _db;

  SessionRepository(this._db);

  Future<int> insertSession(FocusSessionsCompanion session) async {
    return await _db.into(_db.focusSessions).insert(session);
  }

  Future<List<FocusSession>> getLast30FocusSessions() async {
    return await (_db.select(_db.focusSessions)
          ..where((t) => t.mode.equals('TimerMode.focus'))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
          ])
          ..limit(30))
        .get();
  }
}

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  final db = ref.read(appDatabaseProvider);
  return SessionRepository(db);
});
