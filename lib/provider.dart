import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _preferencesProvider = Provider<SharedPreferencesAsync>((ref) {
  return SharedPreferencesAsync();
});

final selectedFileProvider = StateProvider<String?>((ref) {
  return null;
});

final fileNamesProvider =
    AsyncNotifierProvider<FileNamesNotifier, List<String>>(() {
  return FileNamesNotifier();
});

class FileNamesNotifier extends AsyncNotifier<List<String>> {
  static const _prefKey = "files";

  @override
  FutureOr<List<String>> build() async {
    final pref = ref.watch(_preferencesProvider);
    final res = await pref.getStringList(_prefKey);
    return res ?? [];
  }

  Future<void> add(String value) async {
    final list = state.value;
    if (list != null) {
      list.add(value);
      state = AsyncValue.data(list);
      final pref = ref.read(_preferencesProvider);
      await pref.setStringList(_prefKey, list);
    }
  }

  Future<void> addAll(Iterable<String> value) async {
    final list = state.value;
    if (list != null) {
      list.addAll(value);
      state = AsyncValue.data(list);
      final pref = ref.read(_preferencesProvider);
      await pref.setStringList(_prefKey, list);
    }
  }

  Future<void> remove(String value) async {
    final list = state.value;
    if (list != null) {
      list.remove(value);
      state = AsyncValue.data(list);
      final pref = ref.read(_preferencesProvider);
      await pref.setStringList(_prefKey, list);
    }
  }

  Future<void> clear() async {
    final list = <String>[];
    state = AsyncValue.data(list);
    final pref = ref.read(_preferencesProvider);
    await pref.setStringList(_prefKey, list);
  }
}
