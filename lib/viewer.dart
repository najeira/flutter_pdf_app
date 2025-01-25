import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdf_app/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';

typedef PagingFunction = Future<void> Function(
    {required Curve curve, required Duration duration});

class MyViewer extends ConsumerStatefulWidget {
  const MyViewer({
    super.key,
  });

  @override
  ConsumerState<MyViewer> createState() => _MyViewerState();
}

class _MyViewerState extends ConsumerState<MyViewer> {
  late final PdfController _controller;

  @override
  void initState() {
    super.initState();
    final name =
        "/Users/najeira/Downloads/Verifying_your_Play_Console_developer_account_for_organizations.pdf";
    _controller = PdfController(
      document: PdfDocument.openFile(name),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(selectedFileProvider, (prev, next) {
      if (prev != next && next != null) {
        _controller.loadDocument(PdfDocument.openFile(next));
      }
    });

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.arrowRight): () {
          _page(_controller.nextPage);
        },
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
          _page(_controller.previousPage);
        },
      },
      child: Focus(
        autofocus: true,
        child: PdfView(
          controller: _controller,
          builders: PdfViewBuilders<DefaultBuilderOptions>(
            options: const DefaultBuilderOptions(
              // loaderSwitchDuration: const Duration(seconds: 1),
              // transitionBuilder: SomeWidget.transitionBuilder,
            ),
            documentLoaderBuilder: (_) => const _MyLoading(),
            pageLoaderBuilder: (_) => const _MyLoading(),
            errorBuilder: (_, error) => _MyError(error),
            // builder: SomeWidget.builder,
          ),
        ),
      ),
    );
  }

  Future<void> _page(PagingFunction pager) async {
    await pager(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
  }
}

class _MyLoading extends StatelessWidget {
  const _MyLoading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _MyError extends StatelessWidget {
  const _MyError(this.error, {
    super.key,
  });

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(error.toString()),
    );
  }
}
