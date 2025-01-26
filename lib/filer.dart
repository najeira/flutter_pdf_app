import 'package:path/path.dart' as pt;
import 'package:flutter/material.dart';
import 'package:flutter_pdf_app/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FileListView extends ConsumerStatefulWidget {
  const FileListView({
    super.key,
    required this.controller,
  });

  final ScrollController controller;

  @override
  ConsumerState<FileListView> createState() => _FileListViewState();
}

class _FileListViewState extends ConsumerState<FileListView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(fileNamesProvider);
    return data.when(
      skipLoadingOnRefresh: true,
      skipLoadingOnReload: true,
      data: (data) {
        return ListView.builder(
          controller: widget.controller,
          itemCount: data.length,
          itemBuilder: (context, index) {
            final path = data[index];
            return _ListTile(
              path: path,
            );
          },
        );
      },
      error: (error, _) => Text(error.toString()),
      loading: () => const CircularProgressIndicator(),
    );
  }
}

class _ListTile extends ConsumerWidget {
  const _ListTile({
    super.key,
    required this.path,
  });

  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedFileProvider);
    final isSelected = selected == path;
    final name = pt.basename(path);
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        debugPrint("${event.kind} ${event.device} ${event.buttons}");
        ref.read(selectedFileProvider.notifier).state = path;
      },
      // onPointerUp: (PointerUpEvent event) {
      //   debugPrint("${event.kind} ${event.device} ${event.buttons}");
      // },
      child: Container(
        color: isSelected ? Colors.blue : Colors.transparent,
        child: Text(name),
      ),
    );
  }
}
