import 'dart:io';

class FileNode {
  final String name;
  final String path;
  final bool isDirectory;
  final List<FileNode> children;
  bool isExpanded;

  FileNode({
    required this.name,
    required this.path,
    required this.isDirectory,
    List<FileNode>? children,
    this.isExpanded = false,
  }) : children = children ?? [];

  static const _supportedExtensions = {
    '.gp3', '.gp4', '.gp5', '.gpx', '.gp', '.xml', '.midi', '.mid', '.tg',
  };

  bool get isSupportedFile {
    if (isDirectory) return false;
    final ext = path.split('.').last.toLowerCase();
    return _supportedExtensions.contains('.$ext');
  }

  int get fileCount {
    if (!isDirectory) return isSupportedFile ? 1 : 0;
    int count = 0;
    for (final child in children) {
      count += child.fileCount;
    }
    return count;
  }

  List<FileNode> getAllFiles() {
    if (!isDirectory) {
      return isSupportedFile ? [this] : [];
    }
    final files = <FileNode>[];
    for (final child in children) {
      files.addAll(child.getAllFiles());
    }
    return files;
  }

  List<FileNode> search(String query) {
    final lowerQuery = query.toLowerCase();
    final results = <FileNode>[];

    if (!isDirectory && name.toLowerCase().contains(lowerQuery)) {
      results.add(this);
      return results;
    }

    for (final child in children) {
      results.addAll(child.search(query));
    }
    return results;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'isDirectory': isDirectory,
      'isExpanded': isExpanded,
      'children': children.map((c) => c.toJson()).toList(),
    };
  }

  factory FileNode.fromJson(Map<String, dynamic> json) {
    return FileNode(
      name: json['name'] as String,
      path: json['path'] as String,
      isDirectory: json['isDirectory'] as bool,
      isExpanded: json['isExpanded'] as bool? ?? false,
      children: (json['children'] as List<dynamic>?)
              ?.map((c) => FileNode.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  static FileNode fromDirectory(Directory dir, {int maxDepth = 10}) {
    return _buildNode(dir, maxDepth);
  }

  static FileNode buildFromEntity(FileSystemEntity entity, {int depth = 0}) {
    return _buildNode(entity, depth);
  }

  static FileNode _buildNode(FileSystemEntity entity, int depth) {
    final name = entity.path.split(Platform.pathSeparator).last;

    if (entity is Directory) {
      if (depth <= 0) {
        return FileNode(
          name: name,
          path: entity.path,
          isDirectory: true,
          isExpanded: false,
        );
      }

      final children = <FileNode>[];
      try {
        final entries = entity.listSync(followLinks: false);
        entries.sort((a, b) {
          if (a is Directory && b is! Directory) return -1;
          if (a is! Directory && b is Directory) return 1;
          return a.path.toLowerCase().compareTo(b.path.toLowerCase());
        });

        for (final entry in entries) {
          children.add(_buildNode(entry, depth - 1));
        }
      } catch (e) {
        // Permission denied or other error, skip
      }

      return FileNode(
        name: name,
        path: entity.path,
        isDirectory: true,
        children: children,
        isExpanded: false,
      );
    } else if (entity is File) {
      return FileNode(
        name: name,
        path: entity.path,
        isDirectory: false,
      );
    }

    return FileNode(
      name: name,
      path: entity.path,
      isDirectory: false,
    );
  }
}
