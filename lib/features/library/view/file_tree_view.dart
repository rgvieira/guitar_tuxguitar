import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/file_node.dart';
import '../view_model/tree_notifier.dart';

class FileTreeView extends ConsumerWidget {
  final FileNode node;
  final int depth;

  const FileTreeView({
    super.key,
    required this.node,
    this.depth = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!node.isDirectory) {
      return _buildFileTile(context, ref);
    }
    return _buildFolder(context, ref);
  }

  Widget _buildFileTile(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        _getFileIcon(node.name),
        color: theme.colorScheme.primary,
        size: 24,
      ),
      title: Text(
        node.name,
        style: theme.textTheme.bodyMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        node.path,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        if (node.isSupportedFile) {
          ref.read(treeNotifierProvider.notifier).openFile(node.path);
        }
      },
    );
  }

  Widget _buildFolder(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hasFiles = node.fileCount > 0;

    return Column(
      children: [
        InkWell(
          onTap: () {
            ref.read(treeNotifierProvider.notifier).toggleExpand(node.path);
          },
          child: Padding(
            padding: EdgeInsets.only(left: depth * 16.0),
            child: ListTile(
              leading: Icon(
                node.isExpanded ? Icons.folder_open : Icons.folder,
                color: hasFiles ? Colors.amber[700] : theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              title: Text(
                node.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Text(
                '${node.fileCount} arquivos',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ),
        if (node.isExpanded)
          ...node.children.map((child) => FileTreeView(node: child, depth: depth + 1)),
      ],
    );
  }

  IconData _getFileIcon(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    return switch (ext) {
      'gp3' || 'gp4' || 'gp5' => Icons.music_note,
      'gpx' || 'gp' => Icons.score,
      'xml' => Icons.code,
      'midi' || 'mid' => Icons.audio_file,
      'tg' => Icons.audio_file,
      _ => Icons.insert_drive_file,
    };
  }
}
