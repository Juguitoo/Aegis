import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/data/repositories/area_repository.dart';

void main() {
  late AppDatabase db;
  late AreaRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = AreaRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('AreaRepository', () {
    test('insertArea y getAllAreas funcionan correctamente', () async {
      final companion = AreasCompanion.insert(
        name: 'Test Area',
        colorHex: Value('#FFFFFF'),
        description: Value('Descripción'),
      );
      await repository.insertArea(companion);

      final areas = await repository.getAllAreas();
      expect(areas.length, 1);
      expect(areas.first.name, 'Test Area');
    });

    test('getAreaById devuelve el área correcta', () async {
      final id = await repository.insertArea(AreasCompanion.insert(
        name: 'Area Específica',
        colorHex: Value('#000000'),
        description: Value(''),
      ));

      final area = await repository.getAreaById(id);
      expect(area, isNotNull);
      expect(area!.id, id);
      expect(area.name, 'Area Específica');
    });

    test('updateArea modifica los datos en la base de datos', () async {
      final id = await repository.insertArea(AreasCompanion.insert(
        name: 'Viejo Nombre',
        colorHex: Value('#000000'),
        description: Value(''),
      ));
      final area = await repository.getAreaById(id);

      final updatedArea = area!.copyWith(name: 'Nuevo Nombre');
      await repository.updateArea(updatedArea);

      final checkArea = await repository.getAreaById(id);
      expect(checkArea!.name, 'Nuevo Nombre');
    });

    test('deleteArea elimina el área y pone el areaId de las tareas a null',
        () async {
      final areaId = await repository.insertArea(AreasCompanion.insert(
        name: 'Área a Borrar',
        colorHex: Value('#123456'),
        description: Value(''),
      ));

      final taskId = await db.into(db.tasks).insert(TasksCompanion.insert(
            title: 'Tarea del área',
            priority: Value(0),
            areaId: drift.Value(areaId),
          ));

      final area = await repository.getAreaById(areaId);
      await repository.deleteArea(area!);

      final areas = await repository.getAllAreas();
      expect(areas.isEmpty, isTrue);

      final task = await (db.select(db.tasks)
            ..where((t) => t.id.equals(taskId)))
          .getSingle();
      expect(task.areaId, isNull);
    });

    test('watchAllAreas devuelve el stream correctamente', () async {
      await repository.insertArea(AreasCompanion.insert(
        name: 'Área Reactiva',
        colorHex: Value('#111111'),
        description: Value(''),
      ));

      final areas = await repository.watchAllAreas().first;

      expect(areas.length, 1);
      expect(areas.first.name, 'Área Reactiva');
    });

    test('deleteAreaById funciona correctamente', () async {
      await repository.insertArea(AreasCompanion.insert(
        name: 'Área Reactiva',
        colorHex: Value('#111111'),
        description: Value(''),
      ));

      var areas = await repository.getAllAreas();
      expect(areas, isNotEmpty);

      await repository.deleteAreaById(areas.first.id);
      areas = await repository.getAllAreas();
      expect(areas, isEmpty);
    });
  });
}
