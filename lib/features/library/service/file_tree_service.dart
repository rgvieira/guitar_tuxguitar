import 'dart:convert';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/hive/hive_boxes.dart';
import '../model/file_node.dart';

class FileTreeService {
  static const _treeKey = 'cached_file_tree';

  static Future<FileNode?> loadCachedTree() async {
    final box = Hive.box(HiveBoxes.fileTree);
    final jsonStr = box.get(_treeKey) as String?;
    if (jsonStr == null) return null;
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    return FileNode.fromJson(data);
  }

  static Future<void> saveTree(FileNode node) async {
    final box = Hive.box(HiveBoxes.fileTree);
    await box.put(_treeKey, json.encode(node.toJson()));
  }

  static Future<FileNode> scanDirectory(String rootPath) async {
    final dir = Directory(rootPath);
    if (!await dir.exists()) {
      throw FileSystemException('Directory not found: $rootPath');
    }

    final node = FileNode.fromDirectory(dir);
    await saveTree(node);
    return node;
  }

  static Future<FileNode> expandNode(FileNode node) async {
    if (!node.isDirectory || node.children.isNotEmpty) {
      return node;
    }

    final dir = Directory(node.path);
    final children = <FileNode>[];
    try {
      final entries = await dir.list(followLinks: false).toList();
      entries.sort((a, b) {
        if (a is Directory && b is! Directory) return -1;
        if (a is! Directory && b is Directory) return 1;
        return a.path.toLowerCase().compareTo(b.path.toLowerCase());
      });

      for (final entry in entries) {
        children.add(FileNode.buildFromEntity(entry, depth: 0));
      }
    } catch (e) {
      // Permission denied
    }

    final expanded = FileNode(
      name: node.name,
      path: node.path,
      isDirectory: node.isDirectory,
      children: children,
      isExpanded: true,
    );

    await saveTree(_updateNodeInTree(await loadCachedTree(), expanded));
    return expanded;
  }

  static FileNode _updateNodeInTree(FileNode? tree, FileNode updated) {
    if (tree == null) return updated;
    if (tree.path == updated.path) return updated;

    final updatedChildren = tree.children.map((child) {
      return _updateNodeInTree(child, updated);
    }).toList();

    return FileNode(
      name: tree.name,
      path: tree.path,
      isDirectory: tree.isDirectory,
      children: updatedChildren,
      isExpanded: tree.isExpanded,
    );
  }

  static Future<void> refreshTree(String rootPath) async {
    await scanDirectory(rootPath);
  }
}
