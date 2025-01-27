import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdf_app/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import 'file.dart';
import 'log.dart';
import 'viewer.dart';

void main() {
  initLogger();
  runApp(ProviderScope(
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MacosApp(
      title: "PDF Viewer",
      theme: MacosThemeData.light(),
      darkTheme: MacosThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: const _MyScaffold(),
    );
  }
}

class _MyScaffold extends StatelessWidget {
  const _MyScaffold({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    return _ShortcutHandler(
      child: Focus(
        child: MacosWindow(
          child: MacosScaffold(
            children: [
              ResizablePane(
                isResizable: true,
                resizableSide: ResizableSide.right,
                minSize: 100.0,
                maxSize: 500.0,
                startSize: 200.0,
                decoration: BoxDecoration(
                  color: theme.canvasColor,
                  // border: Border(
                  //   right: BorderSide(
                  //     color: theme.dividerColor,
                  //   ),
                  // ),
                ),
                builder: (context, scrollController) {
                  return FileListView(controller: scrollController);
                },
              ),
              ContentArea(
                minWidth: 300.0,
                builder: (context, scrollController) {
                  return const MyViewer();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShortcutHandler extends StatelessWidget {
  const _ShortcutHandler({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.arrowUp): () {
          _changeFile(context, -1);
        },
        const SingleActivator(LogicalKeyboardKey.arrowDown): () {
          _changeFile(context, 1);
        },
      },
      child: child,
    );
  }

  void _changeFile(BuildContext context, int direction) {
    final ps = ProviderScope.containerOf(context, listen: false);
    final files = ps.read(fileListProvider).valueOrNull;
    final selected = ps.read(selectedFileProvider);
    final next = _nextFile(files, selected, direction);
    if (next != null) {
      ps.read(selectedFileProvider.notifier).state = next;
    }
  }

  String? _nextFile(Set<String>? files, String? current, int direction) {
    if (current == null) {
      return files?.firstOrNull;
    } else if (files != null) {
      final index = files.indexOf(current);
      final nextIndex = index + direction;
      if (nextIndex >= 0 && nextIndex < files.length) {
        return files.elementAt(nextIndex);
      }
    }
    return null;
  }
}
