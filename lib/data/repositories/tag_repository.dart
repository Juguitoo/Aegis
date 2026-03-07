import 'package:aegis/data/local/database/app_database.dart';

class TagRepository {
  final AppDatabase _db;

  TagRepository(this._db);

  Future<List<Tag>> getAllTags() {
    return _db.select(_db.tags).get();
  }

  Stream<List<Tag>> watchAllTags() {
    return _db.select(_db.tags).watch();
  }

  Future<int> insertTag(TagsCompanion tag) {
    return _db.into(_db.tags).insert(tag);
  }

  Future<bool> updateTag(Tag tag) {
    return _db.update(_db.tags).replace(tag);
  }

  Future<int> deleteTag(Tag tag) {
    return _db.transaction(() async {
      await (_db.delete(_db.taskTags)..where((t) => t.tagId.equals(tag.id)))
          .go();

      return await (_db.delete(_db.tags)..where((t) => t.id.equals(tag.id)))
          .go();
    });
  }
}
