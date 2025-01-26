import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'provider.dart';

Future<void> pickFile(BuildContext context) async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ["pdf"],
    allowCompression: false,
    allowMultiple: true,
    withData: false,
    withReadStream: false,
    lockParentWindow: false,
    readSequential: false,
  );
  if (result == null || result.count <= 0) {
    return;
  }
  if (!context.mounted) {
    return;
  }

  final ps = ProviderScope.containerOf(context, listen: false);
  ps.read(fileNamesProvider.notifier).addAll(
        result.files.map((e) => e.path).whereType<String>(),
      );
}
