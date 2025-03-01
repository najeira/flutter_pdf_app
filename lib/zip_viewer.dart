import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'page_view.dart';
import 'widget.dart';
import 'zip.dart';

class MyZipViewer extends ConsumerWidget {
  const MyZipViewer({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(zipDocumentNotifierProvider);
    return data.when(
      data: (document) {
        if (document == null) {
          return const MyEmpty();
        }
        return _PageView(
          document: document,
        );
      },
      error: (error, __) => MyError(error),
      loading: () => const MyLoading(),
    );
  }
}

class _PageView extends StatelessWidget {
  const _PageView({
    super.key,
    required this.document,
  });

  final ZipDocument document;

  @override
  Widget build(BuildContext context) {
    return PageViewer(
      key: ValueKey("PageViewer-${identityHashCode(document)}"),
      itemCount: document.contents.length,
      itemBuilder: (context, index) {
        final content = document.contents[index];
        return Image.memory(
          content,
          fit: BoxFit.contain,
        );
      },
    );
  }
}
