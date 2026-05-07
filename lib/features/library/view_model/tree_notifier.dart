import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/hive/hive_boxes.dart';
import '../model/file_node.dart';
import '../service/file_tree_service.dart';

enum TreeState { noConfig, loading, loaded, error }

class TreeData {
  final TreeState state;
  final FileNode? root;
  final List<FileNode> searchResults;
  final String searchQuery;
  final String? error;
  final String? loadingFilePath;

  const TreeData({
    this.state = TreeState.noConfig,
    this.root,
    this.searchResults = const [],
    this.searchQuery = '',
    this.error,
    this.loadingFilePath,
  });

  bool get isSearching => searchQuery.isNotEmpty;

  TreeData copyWith({
    TreeState? state,
    FileNode? root,
    List<FileNode>? searchResults,
    String? searchQuery,
    String? error,
    String? loadingFilePath,
  }) {
    return TreeData(
      state: state ?? this.state,
      root: root ?? this.root,
      searchResults: searchResults ?? this.searchResults,
      searchQuery: searchQuery ?? this.searchQuery,
      error: error ?? this.error,
      loadingFilePath: loadingFilePath ?? this.loadingFilePath,
    );
  }
}

class TreeNotifier extends Notifier<TreeData> {
  @override
  TreeData build() {
    Future.microtask(_init);
    return const TreeData();
  }

  Future<void> _init() async {
    final rootPath = HiveBoxes.getRootFolder();
    if (rootPath == null) {
      state = state.copyWith(state: TreeState.noConfig);
      return;
    }

    state = state.copyWith(state: TreeState.loading);
    try {
      final cached = await FileTreeService.loadCachedTree();
      if (cached != null && cached.path == rootPath) {
        state = state.copyWith(state: TreeState.loaded, root: cached);
      } else {
        final fresh = await FileTreeService.scanDirectory(rootPath);
        state = state.copyWith(state: TreeState.loaded, root: fresh);
      }
    } catch (e) {
      state = state.copyWith(state: TreeState.error, error: e.toString());
    }
  }

  Future<void> toggleExpand(String path) async {
    final root = state.root;
    if (root == null) return;

    final node = _findNode(root, path);
    if (node == null || !node.isDirectory) return;

    if (!node.isExpanded && node.children.isEmpty) {
      final expanded = await FileTreeService.expandNode(node);
      state = state.copyWith(
        root: _replaceNode(root, path, expanded),
      );
    } else {
      final updated = FileNode(
        name: node.name,
        path: node.path,
        isDirectory: node.isDirectory,
        children: node.children,
        isExpanded: !node.isExpanded,
      );
      state = state.copyWith(
        root: _replaceNode(root, path, updated),
      );
    }
  }

  void search(String query) {
    final root = state.root;
    if (root == null) return;

    if (query.isEmpty) {
      state = state.copyWith(searchQuery: '', searchResults: []);
      return;
    }

    final results = root.search(query);
    state = state.copyWith(searchQuery: query, searchResults: results);
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '', searchResults: []);
  }

  void openFile(String path) {
    state = state.copyWith(loadingFilePath: path);
  }

  void clearLoadingFile() {
    state = state.copyWith(loadingFilePath: null);
  }

  Future<void> refresh() async {
    final rootPath = HiveBoxes.getRootFolder();
    if (rootPath == null) return;

    state = state.copyWith(state: TreeState.loading);
    try {
      final fresh = await FileTreeService.scanDirectory(rootPath);
      state = state.copyWith(state: TreeState.loaded, root: fresh);
    } catch (e) {
      state = state.copyWith(state: TreeState.error, error: e.toString());
    }
  }

  FileNode? _findNode(FileNode node, String path) {
    if (node.path == path) return node;
    for (final child in node.children) {
      final found = _findNode(child, path);
      if (found != null) return found;
    }
    return null;
  }

  FileNode _replaceNode(FileNode tree, String path, FileNode replacement) {
    if (tree.path == path) return replacement;
    return FileNode(
      name: tree.name,
      path: tree.path,
      isDirectory: tree.isDirectory,
      children: tree.children
          .map((c) => _replaceNode(c, path, replacement))
          .toList(),
      isExpanded: tree.isExpanded,
    );
  }
}

final treeNotifierProvider = NotifierProvider<TreeNotifier, TreeData>(
  TreeNotifier.new,
);
