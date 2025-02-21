import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdf_app/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:pdfrx/pdfrx.dart';

import 'log.dart';

class MyViewer extends ConsumerWidget {
  const MyViewer({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    return _ShortcutHandler(
      pageController: _pageController,
      child: Focus(
        autofocus: true,
        child: MouseRegion(
          cursor: SystemMouseCursors.grab,
          child: PageView.builder(
            scrollBehavior: const _MyScrollBehavior(),
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

class _ShortcutHandler extends StatelessWidget {
  const _ShortcutHandler({
    super.key,
    required this.pageController,
    required this.child,
  });

  final PageController pageController;

  final Widget child;

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
      child: child,
    );
  }

  Future<void> _page(int add) async {
    if (pageController.positions.length != 1) {
      log.warning("_DocumentPageView: invalid positions");
      return;
    }

    final page = pageController.page?.round() ?? 0;
    final nextPage = math.max(page + add, 0);
    log.fine("_DocumentPageView: animateToPage ${nextPage}");
    pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
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
