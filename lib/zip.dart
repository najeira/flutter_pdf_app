import 'dart:async';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cache.dart';
import 'log.dart';
import 'provider.dart';

class ZipDocument {
  const ZipDocument({
    required this.contents,
  });

  final List<Uint8List> contents;

  static Future<ZipDocument> fromFile(String filePath) async {
    final future = compute(_loadZipEntries, filePath);
    return ZipDocument(
      contents: await future,
    );
  }

  void dispose() {
    log.fine("ZipDocument: dispose");
  }
}

List<Uint8List> _loadZipEntries(String filePath) {
  final inputStream = InputFileStream(filePath);
  final archive = ZipDecoder().decodeStream(inputStream);
  final contents = archive
      .map((entry) {
        if (entry.isFile && _isImageFileName(entry.name)) {
          return entry.readBytes();
        }
        return null;
      })
      .nonNulls
      .toList();
  return contents;
}

bool _isImageFileName(String name) {
  return name.endsWith(".png") ||
      name.endsWith(".jpg") ||
      name.endsWith(".jpeg");
}

final zipDocumentNotifierProvider =
    AutoDisposeAsyncNotifierProvider<ZipDocumentNotifier, ZipDocument?>(
  () => ZipDocumentNotifier(),
);

class ZipDocumentNotifier extends AutoDisposeAsyncNotifier<ZipDocument?> {
  @override
  FutureOr<ZipDocument?> build() async {
    final cacheStore = ref.watch(cacheStoreProvider);
    final filePath = ref.watch(selectedFileProvider);

    if (filePath == null || filePath.isEmpty) {
      log.fine("ZipDocumentNotifier: no file selected");
      return null;
    }

    if (!filePath.endsWith(".zip")) {
      log.warning("ZipDocumentNotifier: not a zip ${filePath}");
      return null;
    }

    void setOnDispose(ZipDocument data) {
      ref.onDispose(() {
        cacheStore.push(filePath, CacheEntry(data, _onDispose));
      });
    }

    final cachedEntry = cacheStore.pop(filePath);
    if (cachedEntry != null) {
      log.fine("ZipDocumentNotifier: reuse ${filePath}");
      final document = cachedEntry.data as ZipDocument;
      setOnDispose(document);
      return document;
    }

    // load the document
    final document = await ZipDocument.fromFile(filePath);
    setOnDispose(document);
    log.fine("ZipDocumentNotifier: loaded ${filePath}");
    return document;
  }

  void _onDispose(Object data) {
    // the document will be disposed when all listeners are removed.
    if (data is ZipDocument) {
      data.dispose();
    }
  }
}
