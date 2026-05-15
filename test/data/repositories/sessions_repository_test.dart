import 'package:aegis/data/repositories/sessions_repository.dart';
import 'package:aegis/presentation/viewmodels/timer_state.dart';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:aegis/data/local/database/app_database.dart';

void main() {
  late AppDatabase db;
  late SessionRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = SessionRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('SessionRepository', () {
    test('insertSession y getLast30FocusSessions funcionan correctamente',
        () async {
      final sessionCompanion = FocusSessionsCompanion.insert(
          mode: TimerMode.focus.toString(),
          actualSeconds: 30,
          pauseCount: 0,
          pauseDuration: 0,
          extraTimeAdded: 0,
          blocklistAttempts: 0);

      await repository.insertSession(sessionCompanion);

      final sessions30 = await repository.getLast30FocusSessions();
      expect(sessions30, isNotEmpty);
    });

    test('deleteAllSessions elimina las sesiones de la base de datos',
        () async {
      final random = Random();
      for (int i = 0; i < 30; i++) {
        final sessionCompanion = FocusSessionsCompanion.insert(
            mode: TimerMode.focus.toString(),
            actualSeconds: random.nextInt(3600) + 1,
            pauseCount: random.nextInt(10),
            pauseDuration: random.nextInt(300),
            extraTimeAdded: random.nextInt(120),
            blocklistAttempts: random.nextInt(5));

        await repository.insertSession(sessionCompanion);
      }

      var sessions = await repository.getLast30FocusSessions();
      expect(sessions, isNotEmpty);

      await repository.deleteAllSessions();
      sessions = await repository.getLast30FocusSessions();
      expect(sessions, isEmpty);
    });
  });
}
