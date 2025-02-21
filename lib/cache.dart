import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class CacheEntry {
  CacheEntry(
    this.listenable,
    this.onDispose,
  );

  final PdfDocumentListenable listenable;

  final VoidCallback onDispose;
}

class CacheStore {
  final Map<String, CacheEntry> _cache = {};

  CacheEntry? pop(String key) {
    return _cache.remove(key);
  }

  void push(String key, CacheEntry entry) {
    _cache.remove(key);
    if (_cache.length > 10) {
      final oldest = _cache.keys.first;
      final oldestEntry = _cache.remove(oldest);
      oldestEntry?.onDispose();
    }
    _cache[key] = entry;
  }
}
