import 'package:aegis/core/providers/repository_providers.dart';
import 'package:aegis/data/local/database/app_database.dart';
import 'package:aegis/data/repositories/tag_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TagListViewmodel extends StreamNotifier<List<Tag>> {
  TagRepository get _repository => ref.read(tagRepositoryProvider);

  @override
  Stream<List<Tag>> build() {
    return ref.watch(tagRepositoryProvider).watchAllTags();
  }

  Future<int> addTag(TagsCompanion tag) {
    return _repository.insertTag(tag);
  }

  Future<bool> updateTag(Tag tag) {
    return _repository.updateTag(tag);
  }

  Future<int> deleteTag(Tag tag) {
    return _repository.deleteTag(tag);
  }
}

final tagListViewModelProvider =
    StreamNotifierProvider<TagListViewmodel, List<Tag>>(() {
  return TagListViewmodel();
});
