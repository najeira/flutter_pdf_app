import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdf_app/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import 'filer.dart';
import 'service.dart';
import 'viewer.dart';

void main() {
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
      themeMode: ThemeMode.light,
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
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.arrowUp): () {
          _changeSelection(context, -1);
        },
        const SingleActivator(LogicalKeyboardKey.arrowDown): () {
          _changeSelection(context, 1);
        },
      },
      child: Focus(
        child: MacosWindow(
          child: MacosScaffold(
            // child: const MyViewer(),
            toolBar: ToolBar(
              // alignment: Alignment.centerLeft,
              leading: MacosIcon(Icons.list_alt),
              title: Text("PDF Viewer"),
              automaticallyImplyLeading: true,
              centerTitle: false,
              actions: [
                ToolBarIconButton(
                  icon: const Icon(Icons.add),
                  label: "Add",
                  showLabel: true,
                  onPressed: () => pickFile(context),
                ),
              ],
            ),
            children: [
              ResizablePane(
                isResizable: true,
                minSize: 100.0,
                maxSize: 500.0,
                startSize: 200.0,
                decoration: BoxDecoration(
                  color: MacosColors.white,
                  border: Border(
                    right: BorderSide(
                      color: MacosColors.systemBlueColor,
                    ),
                  ),
                ),
                resizableSide: ResizableSide.right,
                builder: (context, scrollController) {
                  return FileListView(
                    controller: scrollController
                  );
                },
              ),
              ContentArea(
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

  void _changeSelection(BuildContext context, int add) {
    final ps = ProviderScope.containerOf(context, listen: false);
    final fileNames = ps.read(fileNamesProvider).valueOrNull;
    final selectedFile = ps.read(selectedFileProvider);
    if (selectedFile == null) {
      final firstFileName = fileNames?.firstOrNull;
      if (firstFileName != null) {
        ps.read(selectedFileProvider.notifier).state = firstFileName;
      }
    } else if (fileNames != null) {
      final index = fileNames.indexOf(selectedFile);
      final nextIndex = index + add;
      if (nextIndex >= 0 && nextIndex < fileNames.length) {
        ps.read(selectedFileProvider.notifier).state = fileNames[nextIndex];
      }
    }
  }
}
