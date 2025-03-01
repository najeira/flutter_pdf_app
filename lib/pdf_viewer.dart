import 'package:flutter/material.dart';
import 'package:flutter_pdf_app/pdf.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:pdfrx/pdfrx.dart';

import 'page_view.dart';
import 'widget.dart';

class MyPdfViewer extends ConsumerWidget {
  const MyPdfViewer({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(pdfDocumentNotifierProvider);
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

  final PdfDocument document;

  @override
  Widget build(BuildContext context) {
    return PageViewer(
      key: ValueKey("PageViewer-${identityHashCode(document)}"),
      itemCount: document.pages.length,
      itemBuilder: (context, index) {
        return _DocumentPage(
          document: document,
          index: index,
        );
      },
    );
  }
}

class _DocumentPage extends StatelessWidget {
  const _DocumentPage({
    super.key,
    required this.document,
    required this.index,
  });

  final PdfDocument document;

  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    return ColoredBox(
      color: theme.canvasColor,
      child: PdfPageView(
        document: document,
        pageNumber: index + 1,
        alignment: Alignment.center,
      ),
    );
  }
}
