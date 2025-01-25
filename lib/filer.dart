import 'package:flutter/material.dart';
import 'package:flutter_pdf_app/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

class FileListView extends ConsumerStatefulWidget {
  const FileListView({
    super.key,
  });

  @override
  ConsumerState<FileListView> createState() => _FileListViewState();
}

class _FileListViewState extends ConsumerState<FileListView> {
  @override
  Widget build(BuildContext context) {
    final data = ref.watch(fileNamesProvider);
    return data.when(
      data: (data) {
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            return MacosListTile(
              title: Text(item),
              onClick: () {
                ref.read(selectedFileProvider.notifier).state = item;
              },
              // trailing: IconButton(
              //   icon: const Icon(Icons.delete),
              //   onPressed: () {
              //     ref.read(fileNamesProvider.notifier).remove(item);
              //   },
              // ),
            );
          },
        );
      },
      error: (error, _) => Text(error.toString()),
      loading: () => const CircularProgressIndicator(),
    );
  }
}
