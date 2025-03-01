import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'log.dart';
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

class _PageView extends StatefulWidget {
  const _PageView({
    super.key,
    required this.document,
  });

  final ZipDocument document;

  @override
  _PageViewState createState() => _PageViewState();
}

class _PageViewState extends State<_PageView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void didUpdateWidget(_PageView oldWidget) {
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
            itemCount: widget.document.contents.length,
            itemBuilder: (context, index) {
              log.fine("_DocumentPage: ${index}");
              final content = widget.document.contents[index];
              return Image.memory(
                content,
              );
            },
          ),
        ),
      ),
    );
  }
}
