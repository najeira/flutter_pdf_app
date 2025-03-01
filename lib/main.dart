import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdf_app/provider.dart';
import 'package:flutter_pdf_app/service.dart';
import 'package:flutter_pdf_app/widget.dart';
import 'package:flutter_pdf_app/zip_viewer.dart';
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
                  return const _Viewer();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Viewer extends ConsumerWidget {
  const _Viewer({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filePath = ref.watch(selectedFileProvider);
    if (filePath != null) {
      if (filePath.endsWith(".zip")) {
        return MyZipViewer();
      } else if (filePath.endsWith(".pdf")) {
        return MyPdfViewer();
      }
    }
    return MyEmpty();
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
    final ps = context.providerContainer();
    final files = ps.read(fileListProvider).valueOrNull;
    final selected = ps.read(selectedFileProvider);
    final next = _nextFile(files, selected, direction);
    if (next != null) {
      ps.read(selectedFileProvider.notifier).state = next.path;
    }
  }

  MyFile? _nextFile(List<MyFile>? files, String? current, int direction) {
    if (current == null) {
      // if no file is selected, select the first one
      return files?.firstOrNull;
    } else if (files != null) {
      // if a file is selected, select the next or previous one
      // find the index of the current file by path.
      final index = files.indexWhere((e) => e.path == current);
      final nextIndex = index + direction;
      if (nextIndex >= 0 && nextIndex < files.length) {
        return files.elementAt(nextIndex);
      }
    }
    return null;
  }
}
