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
  PdfController? _controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(selectedFileProvider, _onFileChanged);

    final controller = _controller;
    if (controller == null) {
      return const Center(
        child: Text("No file selected"),
      );
    }

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.arrowRight): () {
          _page(controller.nextPage);
        },
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
          _page(controller.previousPage);
        },
      },
      child: PdfView(
        controller: controller,
        onPageChanged: (page) {
          debugPrint("PdfView.onPageChanged: ${page}");
        },
        onDocumentLoaded: (document) {
          debugPrint("PdfView.onDocumentLoaded: ${document}");
        },
        onDocumentError: (error) {
          debugPrint("PdfView.onDocumentError: ${error}");
        },
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
    );
  }

  void _onFileChanged(String? prev, String? next) {
    debugPrint("selectedFileProvider: ${prev} -> ${next}");
    if (prev != next && next != null) {
      final file = PdfDocument.openFile(next);
      setState(() {
        if (_controller != null) {
          _controller?.loadDocument(file);
        } else {
          _controller = PdfController(
            document: file,
          );
        }
      });
    }
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
  const _MyError(
    this.error, {
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
