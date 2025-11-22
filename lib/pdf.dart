import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

import 'log.dart';
import 'provider.dart';

final pdfDocumentNotifierProvider =
    AutoDisposeAsyncNotifierProvider<PdfDocumentNotifier, PdfDocumentRef?>(
  () => PdfDocumentNotifier(),
);

class PdfDocumentNotifier extends AutoDisposeAsyncNotifier<PdfDocumentRef?> {
  @override
  FutureOr<PdfDocumentRef?> build() async {
    final filePath = ref.watch(selectedFileProvider);

    if (filePath == null || filePath.isEmpty) {
      log.fine("PdfDocumentNotifier: no file selected");
      return null;
    }

    if (!filePath.endsWith(".pdf")) {
      log.fine("PdfDocumentNotifier: not a pdf ${filePath}");
      return null;
    }

    final documentRef = PdfDocumentRefFile(filePath);
    log.fine("PdfDocumentNotifier: loaded ${filePath}");
    return documentRef;
  }
}
