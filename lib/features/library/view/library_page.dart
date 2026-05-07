import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/hive/hive_boxes.dart';
import '../model/file_node.dart';
import 'config_page.dart';
import '../view_model/tree_notifier.dart';
import '../view/file_tree_view.dart';
import '../../score_view/view/score_player_page.dart';
import '../../score_view/view_model/tab_notifier.dart';
import '../../score_view/model/demo_song_factory.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _hasRootFolder = false;

  @override
  void initState() {
    super.initState();
    _checkRootFolder();
  }

  Future<void> _checkRootFolder() async {
    final root = HiveBoxes.getRootFolder();
    setState(() {
      _hasRootFolder = root != null;
    });
    if (root != null) {
      _tabController = TabController(length: 2, vsync: this);
    }
  }

  @override
  void dispose() {
    if (_hasRootFolder) {
      _tabController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final treeData = ref.watch(treeNotifierProvider);

    ref.listen<TreeData>(treeNotifierProvider, (previous, next) {
      if (next.loadingFilePath != null && next.loadingFilePath != previous?.loadingFilePath) {
        _openFile(context, ref, next.loadingFilePath!);
      }
    });

    if (!_hasRootFolder) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Demos'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Configuracoes',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ConfigPage(),
                  ),
                ).then((_) => _checkRootFolder());
              },
            ),
          ],
        ),
        body: _buildDemoList(context, ref),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.folder), text: 'Pasta Raiz'),
            Tab(icon: Icon(Icons.music_note), text: 'Demos'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
            onPressed: () => ref.read(treeNotifierProvider.notifier).refresh(),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Configuracoes',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ConfigPage(),
                ),
              ).then((_) => _checkRootFolder());
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTreeBody(context, ref, treeData),
          _buildDemoList(context, ref),
        ],
      ),
    );
  }

  Widget _buildDemoList(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.music_off,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            title: const Text('Rock Demo'),
            subtitle: const Text('8 compassos - 120 BPM - 2 tracks'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ref.read(tabProvider.notifier).setMode(TabMode.demo);
              ref.read(tabProvider.notifier).loadFile('Rock Demo');
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ScorePlayerPage(
                    song: DemoSongFactory.createRockDemo(),
                    filePath: 'demo://rock_demo',
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.music_note,
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            title: const Text('Blues in E'),
            subtitle: const Text('7 compassos - 90 BPM - 1 track - Armadura: E'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ref.read(tabProvider.notifier).setMode(TabMode.demo);
              ref.read(tabProvider.notifier).loadFile('Blues in E');
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ScorePlayerPage(
                    song: DemoSongFactory.createBluesDemo(),
                    filePath: 'demo://blues_demo',
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        Text(
          'Recursos demonstrados:',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        _featureItem(context, 'Notas em multiplas cordas'),
        _featureItem(context, 'Acidentes (#)'),
        _featureItem(context, 'Pausas (seminima, minima)'),
        _featureItem(context, 'Bends (1 tom, 1.5 tons)'),
        _featureItem(context, 'Vibrato'),
        _featureItem(context, 'Notas harmonicas'),
        _featureItem(context, 'Notas mortas (X)'),
        _featureItem(context, 'Fermata'),
        _featureItem(context, 'Mudanca de tempo'),
        _featureItem(context, 'Tracks multiplas (guitarra + baixo)'),
        _featureItem(context, 'Playback com cursor animado'),
      ],
    );
  }

  Widget _featureItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(text, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildTreeBody(BuildContext context, WidgetRef ref, TreeData data) {
    return switch (data.state) {
      TreeState.noConfig => _buildNoConfig(context),
      TreeState.loading => const Center(child: CircularProgressIndicator()),
      TreeState.loaded => _buildTree(context, ref, data),
      TreeState.error => _buildError(context, data.error),
    };
  }

  Future<void> _openFile(BuildContext context, WidgetRef ref, String filePath) async {
    ref.read(treeNotifierProvider.notifier).clearLoadingFile();

    if (!context.mounted) return;

    final tabMode = ref.read(tabModeProvider);

    if (tabMode == TabMode.demo) {
      final lower = filePath.toLowerCase();
      final song = lower.contains('blues')
          ? DemoSongFactory.createBluesDemo()
          : DemoSongFactory.createRockDemo();

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ScorePlayerPage(
            song: song,
            filePath: filePath,
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _LoadingAndPlayerPage(filePath: filePath),
        ),
      );
    }
  }

  Widget _buildNoConfig(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.folder_off,
              size: 80,
              color: theme.colorScheme.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhuma pasta configurada',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Selecione uma pasta com suas tablaturas para comecar',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ConfigPage(),
                  ),
                );
              },
              icon: const Icon(Icons.folder_open),
              label: const Text('Configurar Pasta'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTree(BuildContext context, WidgetRef ref, TreeData data) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SearchBar(
            leading: const Icon(Icons.search),
            hintText: 'Buscar tablatura...',
            onChanged: (query) {
              ref.read(treeNotifierProvider.notifier).search(query);
            },
            trailing: [
              if (data.isSearching)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    ref.read(treeNotifierProvider.notifier).clearSearch();
                  },
                ),
            ],
          ),
        ),
        if (data.isSearching)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${data.searchResults.length} resultado(s)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        Expanded(
          child: data.isSearching
              ? _buildSearchResults(context, ref, data.searchResults)
              : _buildFullTree(context, ref, data),
        ),
      ],
    );
  }

  Widget _buildFullTree(BuildContext context, WidgetRef ref, TreeData data) {
    final root = data.root;
    if (root == null) return const SizedBox.shrink();

    return ListView.builder(
      itemCount: root.children.length,
      itemBuilder: (context, index) {
        return FileTreeView(node: root.children[index]);
      },
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    WidgetRef ref,
    List<FileNode> results,
  ) {
    if (results.isEmpty) {
      return const Center(
        child: Text('Nenhum resultado encontrado'),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final node = results[index];
        return ListTile(
          leading: Icon(
            Icons.music_note,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(node.name),
          subtitle: Text(
            node.path,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            if (node.isSupportedFile) {
              ref.read(treeNotifierProvider.notifier).openFile(node.path);
            }
          },
        );
      },
    );
  }

  Widget _buildError(BuildContext context, String? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Erro ao carregar biblioteca',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(error, textAlign: TextAlign.center),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ConfigPage(),
                  ),
                );
              },
              child: const Text('Reconfigurar Pasta'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingAndPlayerPage extends ConsumerWidget {
  final String filePath;

  const _LoadingAndPlayerPage({required this.filePath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabState = ref.watch(tabProvider);

    if (tabState.state == TabLoadState.loading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Carregando partitura...'),
            ],
          ),
        ),
      );
    }

    if (tabState.state == TabLoadState.error) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Erro'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text(tabState.error ?? 'Erro desconhecido'),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      );
    }

    if (tabState.state == TabLoadState.loaded && tabState.song != null) {
      return ScorePlayerPage(
        song: tabState.song!,
        filePath: tabState.filePath,
      );
    }

    return const SizedBox.shrink();
  }
}
