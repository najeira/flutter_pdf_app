import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdf_app/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:pdfx/pdfx.dart';
import 'package:pdfrx/pdfrx.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

typedef PagingFunction = Future<void> Function(
    {required Curve curve, required Duration duration});

class MyViewer extends ConsumerStatefulWidget {
  const MyViewer({
    super.key,
  });

  @override
  ConsumerState<MyViewer> createState() => _MyViewerState();
}

// class _MyViewerState extends ConsumerState<MyViewer> {
//   late final PdfViewerController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = PdfViewerController();
//   }
//
//   @override
//   void dispose() {
//     // _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final filePath = ref.watch(selectedFileProvider);
//     if (filePath == null || filePath.isEmpty) {
//       return const Center(
//         child: Text("No file selected"),
//       );
//     }
//
//     return CallbackShortcuts(
//       bindings: <ShortcutActivator, VoidCallback>{
//         const SingleActivator(LogicalKeyboardKey.arrowRight): () {
//         },
//         const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
//         },
//       },
//       child: SfPdfViewer.file(
//         File(filePath),
//         canShowScrollHead: false,
//         canShowPageLoadingIndicator: false,
//         canShowScrollStatus: false,
//         canShowPasswordDialog: true,
//         canShowHyperlinkDialog: false,
//         enableHyperlinkNavigation: false,
//         canShowTextSelectionMenu: false,
//         enableDoubleTapZooming: false,
//         enableTextSelection: false,
//         pageLayoutMode: PdfPageLayoutMode.single,
//       ),
//     );
//   }
// }

class _MyViewerState extends ConsumerState<MyViewer> {
  late final PageController _pageController;

  late final PdfViewerController _pdfController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pdfController = PdfViewerController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    // _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    final filePath = ref.watch(selectedFileProvider);
    if (filePath == null || filePath.isEmpty) {
      return const Center(
        child: Text("No file selected"),
      );
    }

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.arrowRight): () {
          _page(1);
        },
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
          _page(-1);
        },
      },
      child: Focus(
        autofocus: true,
        child: PdfDocumentViewBuilder.file(
          filePath,
          builder: (context, document) => PageView.builder(
            scrollBehavior: AppScrollBehavior(),
            controller: _pageController,
            pageSnapping: true,
            itemCount: document?.pages.length ?? 0,
            itemBuilder: (context, index) {
              debugPrint("PdfDocumentViewBuilder.builder: ${index}");
              return ColoredBox(
                color: Colors.blue,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      // child: Text("Page ${index + 1}"),
                      child: PdfPageView(
                        document: document,
                        pageNumber: index + 1,
                        alignment: Alignment.center,
                      ),
                    ),
                    Text(
                      '${index + 1}',
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _page(int add) async {
    final page = _pageController.page?.round() ?? 0;
    final nextPage = math.max(page + add, 0);
    debugPrint("_page: ${nextPage}");
    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
    // final page = _pdfController.pageNumber ?? 0;
    // await _pdfController.goToPage(
    //   pageNumber: math.max(page + add, 1),
    // );
  }
}

// class _MyViewerState extends ConsumerState<MyViewer> {
//   PdfController? _controller;
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     ref.listen<String?>(selectedFileProvider, _onFileChanged);
//
//     final controller = _controller;
//     if (controller == null) {
//       return const Center(
//         child: Text("No file selected"),
//       );
//     }
//
//     return CallbackShortcuts(
//       bindings: <ShortcutActivator, VoidCallback>{
//         const SingleActivator(LogicalKeyboardKey.arrowRight): () {
//           _page(controller.nextPage);
//         },
//         const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
//           _page(controller.previousPage);
//         },
//       },
//       child: PdfView(
//         controller: controller,
//         onPageChanged: (page) {
//           debugPrint("PdfView.onPageChanged: ${page}");
//         },
//         onDocumentLoaded: (document) {
//           debugPrint("PdfView.onDocumentLoaded: ${document}");
//         },
//         onDocumentError: (error) {
//           debugPrint("PdfView.onDocumentError: ${error}");
//         },
//         builders: PdfViewBuilders<DefaultBuilderOptions>(
//           options: const DefaultBuilderOptions(
//               // loaderSwitchDuration: const Duration(seconds: 1),
//               // transitionBuilder: SomeWidget.transitionBuilder,
//               ),
//           documentLoaderBuilder: (_) => const _MyLoading(),
//           pageLoaderBuilder: (_) => const _MyLoading(),
//           errorBuilder: (_, error) => _MyError(error),
//           // builder: SomeWidget.builder,
//         ),
//       ),
//     );
//   }
//
//   void _onFileChanged(String? prev, String? next) {
//     debugPrint("selectedFileProvider: ${prev} -> ${next}");
//     if (prev != next && next != null) {
//       final file = PdfDocument.openFile(next);
//       setState(() {
//         if (_controller != null) {
//           _controller?.loadDocument(file);
//         } else {
//           _controller = PdfController(
//             document: file,
//           );
//         }
//       });
//     }
//   }
//
//   Future<void> _page(PagingFunction pager) async {
//     await pager(
//       duration: const Duration(milliseconds: 100),
//       curve: Curves.easeInOut,
//     );
//   }
// }

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

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
