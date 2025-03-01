import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdfrx/pdfrx.dart';

import 'cache.dart';
import 'log.dart';
import 'service.dart';

final _preferencesProvider = Provider<SharedPreferencesAsync>((ref) {
  return SharedPreferencesAsync();
});

final _cacheStoreProvider = Provider<CacheStore>((ref) {
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

final documentNotifierProvider =
    AutoDisposeAsyncNotifierProvider<DocumentNotifier, PdfDocument?>(
  () => DocumentNotifier(),
);

class DocumentNotifier extends AutoDisposeAsyncNotifier<PdfDocument?> {
  @override
  FutureOr<PdfDocument?> build() async {
    final cache = ref.watch(_cacheStoreProvider);
    final filePath = ref.watch(selectedFileProvider);

    if (filePath == null || filePath.isEmpty) {
      log.fine("DocumentNotifier: no file selected");
      return null;
    }

    if (!filePath.endsWith(".pdf")) {
      log.warning("DocumentNotifier: not a pdf ${filePath}");
      return null;
    }

    final cachedEntry = cache.pop(filePath);
    if (cachedEntry != null) {
      log.fine("DocumentNotifier: reuse ${filePath}");
      ref.onDispose(() {
        _pushCache(cache, filePath, cachedEntry.data, _onDispose);
      });
      final listenable = cachedEntry.data as PdfDocumentListenable;
      return listenable.document;
    }

    final documentRef = PdfDocumentRefFile(filePath);
    final listenable = documentRef.resolveListenable();

    // to keep the document alive
    listenable.addListener(_onDocumentChanged);

    ref.onDispose(() {
      _pushCache(cache, filePath, listenable, _onDispose);
    });

    await listenable.load();
    log.fine("DocumentNotifier: loaded ${filePath}");
    return listenable.document;
  }

  void _onDocumentChanged() {
    log.fine("DocumentNotifier: on event");
  }

  void _onDispose(Object data) {
    // the document will be disposed when all listeners are removed.
    if (data is PdfDocumentListenable) {
      data.removeListener(_onDocumentChanged);
    }
  }
}

void _pushCache(
  CacheStore cache,
  String filePath,
  Object data,
  CacheDisposeCallback onDispose,
) {
  log.fine("CacheStore: cache ${filePath}");
  cache.push(
    filePath,
    CacheEntry(
      data,
      (data) {
        log.fine("CacheStore: dispose ${filePath}");
        onDispose(data);
      },
    ),
  );
}
