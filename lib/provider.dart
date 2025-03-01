import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cache.dart';
import 'log.dart';
import 'service.dart';

final _preferencesProvider = Provider<SharedPreferencesAsync>((ref) {
  return SharedPreferencesAsync();
});

final cacheStoreProvider = Provider<CacheStore>((ref) {
  return CacheStore();
});

final selectedFileProvider = StateProvider<String?>((ref) {
  return null;
});

final fileListProvider =
    AsyncNotifierProvider<FileListNotifier, List<MyFile>>(() {
  return FileListNotifier();
});

class FileListNotifier extends AsyncNotifier<List<MyFile>> {
  static const _prefKey = "files";

  @override
  FutureOr<List<MyFile>> build() async {
    final pref = ref.watch(_preferencesProvider);
    final res = await pref.getStringList(_prefKey);
    log.fine("FileListNotifier: loaded ${res?.length}");

    if (res == null || res.isEmpty) {
      return [];
    }

    final futures = res.map((e) async {
      try {
        return await MyFile.fromBookmark(e);
      } catch (ex) {
        log.warning(ex);
        return null;
      }
    });

    final files = await Future.wait(futures);
    return files.nonNulls.toList();
  }

  Future<void> addFiles(Iterable<MyFile> value) async {
    // new list
    var list = state.value;
    if (list == null) {
      return;
    }
    list = List.of(list);

    // add or update
    for (final item in value) {
      final index = list.indexWhere(
        (e) => e.path == item.path,
      );
      if (index >= 0) {
        list[index] = item;
      } else {
        list.add(item);
      }
    }

    await _setStateAndSave(list);
  }

  Future<void> removeByPath(String path) async {
    var list = state.value;
    if (list != null) {
      list = List.of(list);
      final index = list.indexWhere(
        (e) => e.path == path,
      );
      if (index >= 0) {
        list.removeAt(index);
        await _setStateAndSave(list);
      }
    }
  }

  Future<void> clear() async {
    await _setStateAndSave([]);
  }

  Future<void> _setStateAndSave(List<MyFile> value) async {
    state = AsyncValue.data(value);

    // save bookmarks only
    final pref = ref.read(_preferencesProvider);
    final bookmarks = value.map((e) => e.bookmark).toList();
    await pref.setStringList(_prefKey, bookmarks);
    log.fine("FileListNotifier: saved ${bookmarks.length}");
  }
}
