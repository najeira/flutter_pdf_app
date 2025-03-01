import 'package:flutter/material.dart';

import 'log.dart';
import 'widget.dart';

class PageViewer extends StatefulWidget {
  const PageViewer({
    super.key,
    this.itemCount,
    required this.itemBuilder,
  });

  final int? itemCount;

  final NullableIndexedWidgetBuilder itemBuilder;

  @override
  State<PageViewer> createState() => _PageViewState();
}

class _PageViewState extends State<PageViewer> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void didUpdateWidget(PageViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.key != widget.key) {
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
            itemCount: widget.itemCount,
            itemBuilder: (context, index) {
              log.fine("PageViewer: itemBuilder ${index}");
              return widget.itemBuilder(context, index);
            },
          ),
        ),
      ),
    );
  }
}
