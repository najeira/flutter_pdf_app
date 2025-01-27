import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdfrx/pdfrx.dart';

import 'cache.dart';
import 'log.dart';

final _preferencesProvider = Provider<SharedPreferencesAsync>((ref) {
  return SharedPreferencesAsync();
});

final _cacheProvider = Provider<Cache>((ref) {
  return Cache();
});

final selectedFileProvider = StateProvider<String?>((ref) {
  return null;
});

final fileListProvider =
    AsyncNotifierProvider<FileListNotifier, Set<String>>(() {
  return FileListNotifier();
});

class FileListNotifier extends AsyncNotifier<Set<String>> {
  static const _prefKey = "files";

  @override
  FutureOr<Set<String>> build() async {
    final pref = ref.watch(_preferencesProvider);
    final res = await pref.getStringList(_prefKey);
    log.fine("FileListNotifier: loaded ${res?.length}");
    return res != null ? Set.of(res) : {};
  }

  Future<void> add(String value) async {
    final list = state.value;
    if (list != null) {
      list.add(value);
      _setStateAndSave(list);
    }
  }

  Future<void> addAll(Iterable<String> value) async {
    final list = state.value;
    if (list != null) {
      list.addAll(value);
      _setStateAndSave(list);
    }
  }

  Future<void> remove(String value) async {
    final list = state.value;
    if (list != null) {
      list.remove(value);
      _setStateAndSave(list);
    }
  }

  Future<void> clear() async {
    _setStateAndSave(<String>{});
  }

  Future<void> _setStateAndSave(Set<String> value) async {
    state = AsyncValue.data(value);
    final pref = ref.read(_preferencesProvider);
    await pref.setStringList(_prefKey, value.toList());
    log.fine("FileListNotifier: saved ${value.length}");
  }
}

final documentNotifierProvider =
    AutoDisposeAsyncNotifierProvider<DocumentNotifier, PdfDocument?>(
  () => DocumentNotifier(),
);

class DocumentNotifier extends AutoDisposeAsyncNotifier<PdfDocument?> {
  @override
  FutureOr<PdfDocument?> build() async {
    final cache = ref.watch(_cacheProvider);
    final filePath = ref.watch(selectedFileProvider);
    if (filePath == null || filePath.isEmpty) {
      log.fine("DocumentNotifier: no file selected");
      return null;
    }

    final cachedEntry = cache.pop(filePath);
    if (cachedEntry != null) {
      log.fine("DocumentNotifier: reuse ${filePath}");
      ref.onDispose(() {
        _pushCache(cache, filePath, cachedEntry.listenable);
      });
      return cachedEntry.listenable.document;
    }

    final documentRef = PdfDocumentRefFile(filePath);
    final listenable = documentRef.resolveListenable();

    // to keep the document alive
    listenable.addListener(_onDocumentChanged);

    ref.onDispose(() {
      _pushCache(cache, filePath, listenable);
    });

    await listenable.load();
    log.fine("DocumentNotifier: loaded ${filePath}");
    return listenable.document;
  }

  void _pushCache(
    Cache cache,
    String filePath,
    PdfDocumentListenable listenable,
  ) {
    log.fine("DocumentNotifier: cache ${filePath}");
    cache.push(
      filePath,
      CacheEntry(
        listenable,
        () {
          log.fine("DocumentNotifier: dispose ${filePath}");
          // to dispose the document
          listenable.removeListener(_onDocumentChanged);
        },
      ),
    );
  }

  void _onDocumentChanged() {
    log.fine("DocumentNotifier: on event");
  }
}

extension SetExtention<T> on Set<T> {
  int indexOf(T element) {
    int i = 0;
    for (final item in this) {
      if (item == element) {
        return i;
      }
      i++;
    }
    return -1; // 見つからない場合
  }
}
