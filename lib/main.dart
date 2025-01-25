import 'package:flutter/material.dart';
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
      themeMode: ThemeMode.system,
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
    return MacosWindow(
      // sidebar: Sidebar(
      //   minWidth: 200,
      //   builder: (context, scrollController) {
      //     return SidebarItems(
      //       currentIndex: 0,
      //       onChanged: (index) {},
      //       items: [
      //         SidebarItem(
      //           leading: const MacosIcon(Icons.picture_as_pdf_outlined),
      //           label: Text("Viewer"),
      //         ),
      //       ],
      //     );
      //   },
      // ),
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
              color: MacosColors.black,
              border: Border(
                right: BorderSide(
                  color: MacosColors.systemBlueColor,
                ),
              ),
            ),
            resizableSide: ResizableSide.right,
            builder: (context, scrollController) {
              return const FileListView();
            },
          ),
          ContentArea(
            builder: (context, scrollController) {
              return const MyViewer();
            },
          ),
        ],
      ),
    );
  }
}
