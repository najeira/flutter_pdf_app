import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdf_app/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pdfrx/pdfrx.dart';

final documentNotifierProvider =
    AutoDisposeAsyncNotifierProvider<DocumentNotifier, PdfDocument?>(
  () => DocumentNotifier(),
);

class DocumentNotifier extends AutoDisposeAsyncNotifier<PdfDocument?> {
  @override
  FutureOr<PdfDocument?> build() async {
    final filePath = ref.watch(selectedFileProvider);
    if (filePath == null || filePath.isEmpty) {
      return null;
    }

    final documentRef = PdfDocumentRefFile(filePath);
    final listenable = documentRef.resolveListenable();

    // to keep the document alive
    listenable.addListener(_onDocumentChanged);

    ref.onDispose(() {
      // to dispose the document
      listenable.removeListener(_onDocumentChanged);
    });

    await listenable.load();
    return listenable.document;
  }

  void _onDocumentChanged() {
    debugPrint("onDocumentChanged");
  }
}

class MyViewer extends ConsumerStatefulWidget {
  const MyViewer({
    super.key,
  });

  @override
  ConsumerState<MyViewer> createState() => _MyViewerState();
}

class _MyViewerState extends ConsumerState<MyViewer> {
  @override
  Widget build(BuildContext context) {
    final data = ref.watch(documentNotifierProvider);
    return data.when(
      data: (document) {
        if (document == null) {
          return const _MyEmpty();
        }
        return _DocumentPageView(
          document: document,
        );
      },
      error: (error, __) => _MyError(error),
      loading: () => const _MyLoading(),
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
        child: PageView.builder(
          scrollBehavior: const _MyScrollBehavior(),
          controller: _pageController,
          physics: const AlwaysScrollableScrollPhysics(),
          pageSnapping: true,
          itemCount: widget.document.pages.length,
          itemBuilder: (context, index) {
            debugPrint("_DocumentPage: ${index}");
            return _DocumentPage(
              document: widget.document,
              index: index,
            );
          },
        ),
      ),
    );
  }

  Future<void> _page(int add) async {
    if (_pageController.positions.length != 1) {
      debugPrint("_DocumentPageView: invalid positions");
      return;
    }

    final page = _pageController.page?.round() ?? 0;
    final nextPage = math.max(page + add, 0);
    debugPrint("_DocumentPageView: animateToPage ${nextPage}");
    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
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
    return ColoredBox(
      color: Colors.blue,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: PdfPageView(
              document: document,
              pageNumber: index + 1,
              alignment: Alignment.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _MyEmpty extends StatelessWidget {
  const _MyEmpty({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("No file selected"),
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

class _MyScrollBehavior extends MaterialScrollBehavior {
  const _MyScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
