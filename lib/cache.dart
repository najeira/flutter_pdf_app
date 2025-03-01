const _kCacheSize = 10;

typedef CacheDisposeCallback = void Function(Object);

class CacheEntry {
  const CacheEntry(
    this.data,
    this.onDispose,
  );

  final Object data;

  final CacheDisposeCallback onDispose;
}

class CacheStore {
  final Map<String, CacheEntry> _cache = {};

  CacheEntry? pop(String key) {
    return _cache.remove(key);
  }

  void push(String key, CacheEntry entry) {
    // remove the entry if it already exists.
    _cache.remove(key);

    // remove the oldest entry if the cache is full.
    if (_cache.length > _kCacheSize) {
      final oldest = _cache.keys.first;
      final oldestEntry = _cache.remove(oldest);
      if (oldestEntry != null) {
        // dispose the oldest entry when removing.
        oldestEntry.onDispose(oldestEntry.data);
      }
    }

    // add the new entry.
    _cache[key] = entry;
  }
}
