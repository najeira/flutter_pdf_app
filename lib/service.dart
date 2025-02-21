import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_secure_bookmarks/macos_secure_bookmarks.dart';

import 'log.dart';
import 'provider.dart';

final _secureBookmarks = SecureBookmarks();

class MyFile {
  const MyFile({
    required this.path,
    required this.bookmark,
  });

  final String path;

  final String bookmark;

  static Future<MyFile> fromBookmark(String bookmark) async {
    final file = await _secureBookmarks.resolveBookmark(bookmark);
    final exists = await file.exists();
    if (!exists) {
      throw Exception("file ${file.path} does not exist");
    }
    return MyFile(
      path: file.path,
      bookmark: bookmark,
    );
  }
}

const _kPdfTypeGroup = <XTypeGroup>[
  XTypeGroup(
    label: "PDF files",
    extensions: <String>["pdf"],
  ),
];

Future<void> pickFiles(BuildContext context) async {
  final files = await openFiles(acceptedTypeGroups: _kPdfTypeGroup);
  if (files.isEmpty) {
    log.fine("no files selected");
    return;
  }

  if (!context.mounted) {
    log.warning("context is not mounted");
    return;
  }

  final myFiles = await Future.wait(files.map(
    (e) async {
      final bookmark = await _secureBookmarks.bookmark(File(e.path));
      return MyFile(
        path: e.path,
        bookmark: bookmark,
      );
    },
  ));

  if (!context.mounted) {
    log.warning("context is not mounted");
    return;
  }

  final ps = context.providerContainer();
  ps.read(fileListProvider.notifier).addFiles(myFiles);
}

extension BuildContextExtension on BuildContext {
  ProviderContainer providerContainer() {
    return ProviderScope.containerOf(this, listen: false);
  }
}
