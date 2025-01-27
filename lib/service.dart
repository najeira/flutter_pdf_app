import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'provider.dart';

const _kPdfTypeGroup = <XTypeGroup>[
  XTypeGroup(
    label: "PDF files",
    extensions: <String>["pdf"],
  ),
];

Future<void> pickFiles(BuildContext context) async {
  final files = await openFiles(acceptedTypeGroups: _kPdfTypeGroup);
  if (files.isEmpty) {
    return;
  }

  if (!context.mounted) {
    return;
  }

  final fileNames = files.map((e) => e.path);
  final ps = ProviderScope.containerOf(context, listen: false);
  ps.read(fileListProvider.notifier).addAll(fileNames);
}
