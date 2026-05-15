import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/data/repositories/backup_repository.dart';

class MockBackupPlatformProvider extends Mock
    implements BackupPlatformProvider {}

void main() {
  late AppDatabase db;
  late MockBackupPlatformProvider mockProvider;
  late BackupRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory(
      setup: (db) {
        db.execute('PRAGMA foreign_keys = ON;');
      },
    ));
    mockProvider = MockBackupPlatformProvider();
    repository = BackupRepository(db, platformProvider: mockProvider);
  });

  tearDown(() async {
    await db.close();
  });

  group('BackupRepository - Export', () {
    test('exportDatabase throws cancel exception on desktop if no file picked',
        () async {
      when(() => mockProvider.isDesktop).thenReturn(true);
      when(() => mockProvider.pickSaveFile()).thenAnswer((_) async => null);

      expect(
        () => repository.exportDatabase(),
        throwsA(isA<Exception>()
            .having((e) => e.toString(), 'message', contains('cancelada'))),
      );
    });

    test('exportDatabase writes JSON string to selected file on desktop',
        () async {
      when(() => mockProvider.isDesktop).thenReturn(true);
      when(() => mockProvider.pickSaveFile())
          .thenAnswer((_) async => 'backup.json');
      when(() => mockProvider.writeStringToFile(any(), any()))
          .thenAnswer((_) async {});

      await repository.exportDatabase();

      verify(() => mockProvider.writeStringToFile('backup.json', any()))
          .called(1);
    });

    test('exportDatabase shares file on mobile if not canceled', () async {
      when(() => mockProvider.isDesktop).thenReturn(false);
      when(() => mockProvider.getTemporaryFilePath(any()))
          .thenAnswer((_) async => 'temp/backup.json');
      when(() => mockProvider.writeStringToFile(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockProvider.shareFile(any(), any()))
          .thenAnswer((_) async => true);

      await repository.exportDatabase();

      verify(() => mockProvider.getTemporaryFilePath('aegis_backup.json'))
          .called(1);
      verify(() => mockProvider.writeStringToFile('temp/backup.json', any()))
          .called(1);
      verify(() =>
              mockProvider.shareFile('temp/backup.json', 'application/json'))
          .called(1);
    });

    test('exportDatabase throws cancel exception on mobile if share dismissed',
        () async {
      when(() => mockProvider.isDesktop).thenReturn(false);
      when(() => mockProvider.getTemporaryFilePath(any()))
          .thenAnswer((_) async => 'temp/backup.json');
      when(() => mockProvider.writeStringToFile(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockProvider.shareFile(any(), any()))
          .thenAnswer((_) async => false);

      expect(
        () => repository.exportDatabase(),
        throwsA(isA<Exception>()
            .having((e) => e.toString(), 'message', contains('cancelada'))),
      );
    });
  });

  group('BackupRepository - Import', () {
    test('importDatabase throws cancel exception if no file is picked',
        () async {
      when(() => mockProvider.pickImportFile()).thenAnswer((_) async => null);

      expect(
        () => repository.importDatabase(),
        throwsA(isA<Exception>()
            .having((e) => e.toString(), 'message', contains('cancelada'))),
      );
    });

    test('importDatabase throws exception if file content is not valid JSON',
        () async {
      when(() => mockProvider.pickImportFile())
          .thenAnswer((_) async => 'path.json');
      when(() => mockProvider.readStringFromFile(any()))
          .thenAnswer((_) async => 'invalid-json');

      expect(
        () => repository.importDatabase(),
        throwsA(isA<Exception>()
            .having((e) => e.toString(), 'message', contains('corrupto'))),
      );
    });

    test('importDatabase throws exception if JSON lacks version', () async {
      final invalidData = jsonEncode({'areas': []});
      when(() => mockProvider.pickImportFile())
          .thenAnswer((_) async => 'path.json');
      when(() => mockProvider.readStringFromFile(any()))
          .thenAnswer((_) async => invalidData);

      expect(
        () => repository.importDatabase(),
        throwsA(isA<Exception>()
            .having((e) => e.toString(), 'message', contains('corrupto'))),
      );
    });

    test('importDatabase successfully imports correct json data', () async {
      final validData = {
        'version': 1,
        'areas': [
          {'id': 1, 'name': 'Work', 'colorHex': '#FFF'}
        ],
        'tags': [
          {'id': 1, 'name': 'Urgent', 'colorHex': '#F00'}
        ],
        'tasks': [
          {
            'id': 1,
            'title': 'Task1',
            'priority': 0,
            'completedAt': null,
            'areaId': null
          }
        ],
        'taskTags': [],
        'subtasks': [],
        'settings': [],
        'blacklistedApps': [],
        'focusSessions': [],
        'diaryNote': [],
        'habits': [],
        'habitEntries': [],
      };

      when(() => mockProvider.pickImportFile())
          .thenAnswer((_) async => 'path.json');
      when(() => mockProvider.readStringFromFile(any()))
          .thenAnswer((_) async => jsonEncode(validData));

      await repository.importDatabase();

      final dbAreas = await db.select(db.areas).get();
      expect(dbAreas.length, 1);
      expect(dbAreas.first.name, 'Work');

      final dbTags = await db.select(db.tags).get();
      expect(dbTags.length, 1);
      expect(dbTags.first.name, 'Urgent');

      final dbTasks = await db.select(db.tasks).get();
      expect(dbTasks.length, 1);
      expect(dbTasks.first.title, 'Task1');
    });
  });
}
