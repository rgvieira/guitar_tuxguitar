import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../view_model/tab_notifier.dart';
import '../model/song_model.dart';
import 'tablature_painter.dart';
import 'track_selector.dart';

class ScorePage extends ConsumerWidget {
  const ScorePage({super.key});

  Future<void> _pickAndLoadFile(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['gp3', 'gp4', 'gp5', 'gpx', 'gp', 'xml', 'midi', 'mid'],
    );

    if (result != null && result.files.single.path != null) {
      if (context.mounted) {
        await ref.read(tabProvider.notifier).loadFile(result.files.single.path!);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabState = ref.watch(tabProvider);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tablatura'),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            tooltip: 'Abrir arquivo',
            onPressed: () => _pickAndLoadFile(context, ref),
          ),
        ],
      ),
      body: switch (tabState.state) {
        TabLoadState.initial => _buildEmptyState(scheme),
        TabLoadState.loading => const Center(child: CircularProgressIndicator()),
        TabLoadState.error => _buildErrorState(tabState.error ?? 'Erro desconhecido'),
        TabLoadState.loaded => _buildLoadedState(context, tabState, ref),
      },
    );
  }

  Widget _buildEmptyState(ColorScheme scheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.music_note,
            size: 80,
            color: scheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum arquivo carregado',
            style: TextStyle(
              color: scheme.onSurface.withValues(alpha: 0.6),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque em + para abrir um arquivo GP3/GP4/GP5',
            style: TextStyle(
              color: scheme.onSurface.withValues(alpha: 0.4),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Erro ao carregar arquivo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(
    BuildContext context,
    TabState tabState,
    WidgetRef ref,
  ) {
    final song = tabState.song!;
    final track = tabState.selectedTrack;

    if (track == null) {
      return const Center(child: Text('Nenhuma track disponivel'));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                song.title,
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (song.artist != 'Unknown')
                Text(
                  song.artist,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 8),
              TrackSelector(
                song: song,
                selectedIndex: tabState.selectedTrackIndex,
                onTrackSelected: (idx) =>
                    ref.read(tabProvider.notifier).selectTrack(idx),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: SizedBox(
                width: _calculateTabWidth(track),
                height: _calculateTabHeight(track),
                child: CustomPaint(
                  painter: TablaturePainter(track),
                  size: Size(_calculateTabWidth(track), _calculateTabHeight(track)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _calculateTabHeight(Track track) {
    const margin = 40.0;
    const stringSpacing = 18.0;
    const bottomPadding = 40.0;
    return margin + (track.strings - 1) * stringSpacing + bottomPadding;
  }

  double _calculateTabWidth(Track track) {
    const margin = 40.0;
    const noteSpacing = 28.0;
    const measureBarSpacing = 30.0;

    double totalWidth = margin * 2;
    for (final measure in track.measures) {
      totalWidth += measure.beats.length * noteSpacing + measureBarSpacing;
    }
    return totalWidth;
  }
}
