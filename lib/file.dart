import 'package:flutter/cupertino.dart';
import 'package:flutter_pdf_app/service.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:path/path.dart' as pt;
import 'package:flutter/material.dart';
import 'package:flutter_pdf_app/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'log.dart';

class FileListView extends ConsumerWidget {
  const FileListView({
    super.key,
    required this.controller,
  });

  final ScrollController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(fileListProvider);
    return data.when(
      skipLoadingOnRefresh: true,
      skipLoadingOnReload: true,
      data: (data) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _ListView(
                controller: controller,
                files: data,
              ),
            ),
            const _Footer(),
          ],
        );
      },
      error: (error, _) => Text(error.toString()),
      loading: () => const CircularProgressIndicator(),
    );
  }
}

class _ListView extends StatelessWidget {
  const _ListView({
    super.key,
    required this.controller,
    required this.files,
  });

  final ScrollController controller;

  final List<MyFile> files;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files.elementAt(index);
        return _FileListTile(
          path: file.path,
        );
      },
    );
  }
}

class _FileListTile extends ConsumerWidget {
  const _FileListTile({
    super.key,
    required this.path,
  });

  final String path;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = MacosTheme.of(context);

    final selected = ref.watch(selectedFileProvider);

    final isSelected = selected == path;
    final name = pt.basename(path);
    final color = isSelected ? CupertinoColors.activeBlue : theme.canvasColor;

    return GestureDetector(
      onTapUp: (TapUpDetails details) {
        log.fine("_FileListTile: onTapUp ${details.kind}");
        ref.read(selectedFileProvider.notifier).state = path;
      },
      onSecondaryTapUp: (TapUpDetails details) {
        log.fine("_FileListTile: onSecondaryTapUp ${details.kind}");
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
        decoration: BoxDecoration(
          color: color,
          border: Border(
            bottom: _borderSide(theme),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: theme.typography.body,
                strutStyle: StrutStyle(
                  fontSize: theme.typography.body.fontSize,
                  height: 1.4,
                ),
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      decoration: BoxDecoration(
        color: theme.canvasColor,
        border: Border(
          bottom: _borderSide(theme),
        ),
      ),
      child: Text(
        "Files",
        style: theme.typography.caption1,
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.canvasColor,
        border: Border(
          top: _borderSide(theme),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              pickFiles(context);
            },
            icon: Icon(Icons.add),
          ),
          const _RemoveButton(),
          const Spacer(),
          const _ClearButton(),
        ],
      ),
    );
  }
}

class _RemoveButton extends ConsumerWidget {
  const _RemoveButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedFileProvider);
    final isSelected = selected != null;
    return IconButton(
      onPressed: isSelected
          ? () {
              _onPressed(context, ref, selected);
            }
          : null,
      icon: Icon(Icons.remove),
    );
  }

  void _onPressed(
    BuildContext context,
    WidgetRef ref,
    String selected,
  ) {
    ref.read(selectedFileProvider.notifier).state = null;
    ref.read(fileListProvider.notifier).removeByPath(selected);
  }
}

class _ClearButton extends ConsumerWidget {
  const _ClearButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNotEmpty = ref.watch(fileListProvider.select(
      (value) => value.valueOrNull?.isNotEmpty ?? false,
    ));
    return IconButton(
      onPressed: isNotEmpty
          ? () {
              _onPressed(context, ref);
            }
          : null,
      icon: Icon(Icons.clear_all),
    );
  }

  void _onPressed(
    BuildContext context,
    WidgetRef ref,
  ) {
    ref.read(selectedFileProvider.notifier).state = null;
    ref.read(fileListProvider.notifier).clear();
  }
}

BorderSide _borderSide(MacosThemeData theme) {
  return BorderSide(
    color: theme.dividerColor,
    width: 1.0,
  );
}
