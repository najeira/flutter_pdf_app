import 'dart:async';
import 'dart:math' as math;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'log.dart';

class MyEmpty extends StatelessWidget {
  const MyEmpty({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("No file selected"),
    );
  }
}

class MyLoading extends StatelessWidget {
  const MyLoading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}

class MyError extends StatelessWidget {
  const MyError(
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

class MyScrollBehavior extends MaterialScrollBehavior {
  const MyScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class PageViewShortcut extends StatelessWidget {
  const PageViewShortcut({
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
      log.warning("PageViewShortcut: invalid positions");
      return;
    }

    final page = pageController.page?.round() ?? 0;
    final nextPage = math.max(page + add, 0);
    log.fine("PageViewShortcut: animateToPage ${nextPage}");
    pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
  }
}
