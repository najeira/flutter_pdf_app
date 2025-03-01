import 'package:flutter/material.dart';
import 'package:flutter_pdf_app/pdf.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:pdfrx/pdfrx.dart';

import 'log.dart';
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
        return _DocumentPageView(
          document: document,
        );
      },
      error: (error, __) => MyError(error),
      loading: () => const MyLoading(),
    );
  }
}

class _DocumentPageView extends StatefulWidget {
  const _DocumentPageView({
    super.key,
    required this.document,
  });

  final PdfDocument document;

  @override
  _DocumentPageViewState createState() => _DocumentPageViewState();
}

class _DocumentPageViewState extends State<_DocumentPageView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void didUpdateWidget(_DocumentPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.document != widget.document) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageViewShortcut(
      pageController: _pageController,
      child: Focus(
        autofocus: true,
        child: MouseRegion(
          cursor: SystemMouseCursors.grab,
          child: PageView.builder(
            scrollBehavior: const MyScrollBehavior(),
            controller: _pageController,
            physics: const AlwaysScrollableScrollPhysics(),
            pageSnapping: true,
            itemCount: widget.document.pages.length,
            itemBuilder: (context, index) {
              log.fine("_DocumentPage: ${index}");
              return _DocumentPage(
                document: widget.document,
                index: index,
              );
            },
          ),
        ),
      ),
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
