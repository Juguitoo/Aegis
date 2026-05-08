import 'dart:convert';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:path_provider/path_provider.dart';
import 'package:aegis/data/local/database/app_database.dart';

class BackupRepository {
  final AppDatabase _db;

  BackupRepository(this._db);

  Future<void> exportDatabase() async {
    final data = {
      'version': 1,
      'areas':
          (await _db.select(_db.areas).get()).map((e) => e.toJson()).toList(),
      'tasks':
          (await _db.select(_db.tasks).get()).map((e) => e.toJson()).toList(),
      'tags':
          (await _db.select(_db.tags).get()).map((e) => e.toJson()).toList(),
      'taskTags': (await _db.select(_db.taskTags).get())
          .map((e) => e.toJson())
          .toList(),
      'subtasks': (await _db.select(_db.subtasks).get())
          .map((e) => e.toJson())
          .toList(),
      'settings': (await _db.select(_db.settings).get())
          .map((e) => e.toJson())
          .toList(),
      'blacklistedApps': (await _db.select(_db.blacklistedApps).get())
          .map((e) => e.toJson())
          .toList(),
      'focusSessions': (await _db.select(_db.focusSessions).get())
          .map((e) => e.toJson())
          .toList(),
      'diaryNote': (await _db.select(_db.diaryNote).get())
          .map((e) => e.toJson())
          .toList(),
      'habits':
          (await _db.select(_db.habits).get()).map((e) => e.toJson()).toList(),
      'habitEntries': (await _db.select(_db.habitEntries).get())
          .map((e) => e.toJson())
          .toList(),
    };

    final jsonString = jsonEncode(data);

    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      final outputFile = await fp.FilePicker.saveFile(
        dialogTitle: 'Guardar copia de seguridad',
        fileName: 'aegis_backup.json',
        type: fp.FileType.custom,
        allowedExtensions: ['json'],
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(jsonString);
      } else {
        throw Exception('Operación cancelada por el usuario');
      }
    } else {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/aegis_backup.json');
      await file.writeAsString(jsonString);

      final params = ShareParams(
        files: [
          XFile(
            file.path,
            mimeType: 'application/json',
          )
        ],
      );

      final result = await SharePlus.instance.share(params);

      if (result.status == ShareResultStatus.dismissed) {
        throw Exception('Operación cancelada por el usuario');
      }
    }
  }

  Future<void> importDatabase() async {
    final result = await fp.FilePicker.pickFiles(
      type: fp.FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.single.path == null) {
      throw Exception('Operación cancelada por el usuario');
    }

    final file = File(result.files.single.path!);
    Map<String, dynamic> data;

    try {
      final jsonString = await file.readAsString();
      data = jsonDecode(jsonString) as Map<String, dynamic>;

      if (data['version'] == null) {
        throw const FormatException();
      }
    } catch (e) {
      throw Exception(
          'El archivo seleccionado no tiene un formato válido o está corrupto. Por favor, asegúrate de elegir un backup de Aegis correcto.');
    }

    await _db.transaction(() async {
      await _db.customStatement('PRAGMA foreign_keys = OFF');

      await _db.delete(_db.taskTags).go();
      await _db.delete(_db.subtasks).go();
      await _db.delete(_db.tasks).go();
      await _db.delete(_db.areas).go();
      await _db.delete(_db.tags).go();
      await _db.delete(_db.settings).go();
      await _db.delete(_db.blacklistedApps).go();
      await _db.delete(_db.focusSessions).go();
      await _db.delete(_db.diaryNote).go();
      await _db.delete(_db.habitEntries).go();
      await _db.delete(_db.habits).go();

      if (data['areas'] != null) {
        for (var item in data['areas']) {
          await _db
              .into(_db.areas)
              .insert(Area.fromJson(item as Map<String, dynamic>));
        }
      }
      if (data['tags'] != null) {
        for (var item in data['tags']) {
          await _db
              .into(_db.tags)
              .insert(Tag.fromJson(item as Map<String, dynamic>));
        }
      }
      if (data['tasks'] != null) {
        for (var item in data['tasks']) {
          await _db
              .into(_db.tasks)
              .insert(Task.fromJson(item as Map<String, dynamic>));
        }
      }
      if (data['taskTags'] != null) {
        for (var item in data['taskTags']) {
          await _db
              .into(_db.taskTags)
              .insert(TaskTag.fromJson(item as Map<String, dynamic>));
        }
      }
      if (data['subtasks'] != null) {
        for (var item in data['subtasks']) {
          await _db
              .into(_db.subtasks)
              .insert(Subtask.fromJson(item as Map<String, dynamic>));
        }
      }
      if (data['settings'] != null) {
        for (var item in data['settings']) {
          await _db
              .into(_db.settings)
              .insert(Setting.fromJson(item as Map<String, dynamic>));
        }
      }
      if (data['blacklistedApps'] != null) {
        for (var item in data['blacklistedApps']) {
          await _db
              .into(_db.blacklistedApps)
              .insert(BlacklistedApp.fromJson(item as Map<String, dynamic>));
        }
      }
      if (data['focusSessions'] != null) {
        for (var item in data['focusSessions']) {
          await _db
              .into(_db.focusSessions)
              .insert(FocusSession.fromJson(item as Map<String, dynamic>));
        }
      }
      if (data['diaryNote'] != null) {
        for (var item in data['diaryNote']) {
          await _db
              .into(_db.diaryNote)
              .insert(DiaryNoteData.fromJson(item as Map<String, dynamic>));
        }
      }
      if (data['habits'] != null) {
        for (var item in data['habits']) {
          await _db
              .into(_db.habits)
              .insert(Habit.fromJson(item as Map<String, dynamic>));
        }
      }
      if (data['habitEntries'] != null) {
        for (var item in data['habitEntries']) {
          await _db
              .into(_db.habitEntries)
              .insert(HabitEntry.fromJson(item as Map<String, dynamic>));
        }
      }

      await _db.customStatement('PRAGMA foreign_keys = ON');
    });
  }
}
