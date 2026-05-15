import 'package:aegis/data/repositories/tag_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:aegis/data/local/database/app_database.dart';

void main() {
  late AppDatabase db;
  late TagRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = TagRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('TagRepository', () {
    test('insertTag y getAllTags funcionan correctamente', () async {
      await repository.insertTag(TagsCompanion.insert(name: 'Tag 1'));
      await repository.insertTag(TagsCompanion.insert(name: 'Tag 2'));

      final tags = await repository.getAllTags();
      expect(tags, isNotEmpty);
      expect(tags.length, 2);
    });

    test('updateTag funciona correctamente', () async {
      await repository.insertTag(TagsCompanion.insert(name: 'Tag 1'));
      var tags = await repository.getAllTags();

      final updatedTag = tags.first.copyWith(name: 'Tag 1 Actualizada');

      await repository.updateTag(updatedTag);

      tags = await repository.getAllTags();
      expect(tags.first.name, 'Tag 1 Actualizada');
    });

    test('deleteTag elimina los datos de la base de datos', () async {
      await repository.insertTag(TagsCompanion.insert(name: 'Tag 1'));
      var tags = await repository.getAllTags();

      expect(tags.length, 1);

      await repository.deleteTag(tags.first);
      tags = await repository.getAllTags();
      expect(tags, isEmpty);
    });

    test('watchAllTags devuelve un stream y detecta los cambios', () async {
      await repository.insertTag(TagsCompanion.insert(name: 'Tag 1'));
      final tagsStream = repository.watchAllTags();
      var tags = await tagsStream.first;

      final updatedTag = tags.first.copyWith(name: 'Tag 1 Actualizada');

      await repository.updateTag(updatedTag);

      tags = await tagsStream.first;
      expect(tags.first.name, 'Tag 1 Actualizada');
    });
  });
}
