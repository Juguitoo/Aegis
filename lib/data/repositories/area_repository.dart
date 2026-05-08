import 'package:aegis/data/local/database/app_database.dart';
import 'package:drift/drift.dart';

class AreaRepository {
  final AppDatabase _db;

  AreaRepository(this._db);

  Future<List<Area>> getAllAreas() {
    return _db.select(_db.areas).get();
  }

  Future<Area?> getAreaById(int id) {
    return (_db.select(_db.areas)..where((p) => p.id.equals(id)))
        .getSingleOrNull();
  }

  Stream<List<Area>> watchAllAreas() {
    return _db.select(_db.areas).watch();
  }

  Future<int> insertArea(AreasCompanion area) {
    return _db.into(_db.areas).insert(area);
  }

  Future<bool> updateArea(Area area) {
    return _db.update(_db.areas).replace(area);
  }

  Future<int> deleteArea(Area area) {
    return _db.transaction(() async {
      await (_db.update(_db.tasks)..where((t) => t.areaId.equals(area.id)))
          .write(const TasksCompanion(areaId: Value(null)));

      return await (_db.delete(_db.areas)..where((p) => p.id.equals(area.id)))
          .go();
    });
  }

  Future<int> deleteAreaById(int id) {
    return _db.transaction(() async {
      await (_db.update(_db.tasks)..where((t) => t.areaId.equals(id)))
          .write(const TasksCompanion(areaId: Value(null)));

      return await (_db.delete(_db.areas)..where((p) => p.id.equals(id))).go();
    });
  }
}
