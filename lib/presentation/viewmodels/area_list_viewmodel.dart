import 'package:aegis/core/providers/repository_providers.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/data/repositories/area_repository.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AreaListViewmodel extends StreamNotifier<List<Area>> {
  AreaRepository get _repository => ref.read(areaRepositoryProvider);

  @override
  Stream<List<Area>> build() {
    return ref.watch(areaRepositoryProvider).watchAllAreas();
  }

  Future<int> addArea(String name, String? colorHex, String? description) {
    return _repository.insertArea(AreasCompanion(
      name: Value(name),
      colorHex: Value(colorHex),
      description: Value(description),
    ));
  }

  Future<bool> updateArea(Area area) {
    return _repository.updateArea(area);
  }

  Future<int> deleteArea(Area area) {
    return _repository.deleteArea(area);
  }
}

final areaListViewModelProvider =
    StreamNotifierProvider<AreaListViewmodel, List<Area>>(() {
  return AreaListViewmodel();
});
