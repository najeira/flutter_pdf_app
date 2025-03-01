import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

import 'cache.dart';
import 'log.dart';
import 'provider.dart';

final pdfDocumentNotifierProvider =
    AutoDisposeAsyncNotifierProvider<PdfDocumentNotifier, PdfDocument?>(
  () => PdfDocumentNotifier(),
);

class PdfDocumentNotifier extends AutoDisposeAsyncNotifier<PdfDocument?> {
  @override
  FutureOr<PdfDocument?> build() async {
    final cacheStore = ref.watch(cacheStoreProvider);
    final filePath = ref.watch(selectedFileProvider);

    if (filePath == null || filePath.isEmpty) {
      log.fine("PdfDocumentNotifier: no file selected");
      return null;
    }

    if (!filePath.endsWith(".pdf")) {
      log.fine("PdfDocumentNotifier: not a pdf ${filePath}");
      return null;
    }

    void setOnDispose(PdfDocumentListenable data) {
      ref.onDispose(() {
        cacheStore.push(filePath, CacheEntry(data, _onDispose));
      });
    }

    final cachedEntry = cacheStore.pop(filePath);
    if (cachedEntry != null) {
      log.fine("PdfDocumentNotifier: reuse ${filePath}");
      final listenable = cachedEntry.data as PdfDocumentListenable;
      setOnDispose(listenable);
      return listenable.document;
    }

    // to keep the document alive
    final documentRef = PdfDocumentRefFile(filePath);
    final listenable = documentRef.resolveListenable();
    listenable.addListener(_onDocumentChanged);

    setOnDispose(listenable);

    // load the document
    await listenable.load();
    log.fine("PdfDocumentNotifier: loaded ${filePath}");
    return listenable.document;
  }

  void _onDocumentChanged() {
    log.fine("PdfDocumentNotifier: on event");
  }

  void _onDispose(Object data) {
    // the document will be disposed when all listeners are removed.
    if (data is PdfDocumentListenable) {
      data.removeListener(_onDocumentChanged);
    }
  }
}
