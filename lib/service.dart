import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'provider.dart';

Future<void> pickFile(BuildContext context) async {
  final file = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ["pdf"],
    allowMultiple: false,
  );
  if (file == null || file.count <= 0) {
    return;
  }
  if (!context.mounted) {
    return;
  }

  final fileName = file.files.first.path;
  if (fileName != null) {
    final ps = ProviderScope.containerOf(context, listen: false);
    ps.read(selectedFileProvider.notifier).state = fileName;
    ps.read(fileNamesProvider.notifier).add(fileName);
  }
}
