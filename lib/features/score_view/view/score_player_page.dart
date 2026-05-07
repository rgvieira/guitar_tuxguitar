import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/song_model.dart';
import '../view_model/playback_engine.dart';
import 'score_painter.dart';

class ScorePlayerPage extends ConsumerStatefulWidget {
  final Song song;
  final String? filePath;

  const ScorePlayerPage({
    super.key,
    required this.song,
    this.filePath,
  });

  @override
  ConsumerState<ScorePlayerPage> createState() => _ScorePlayerPageState();
}

class _ScorePlayerPageState extends ConsumerState<ScorePlayerPage> {
  late PlaybackEngine _engine;
  int _selectedTrackIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initEngine();
  }

  void _initEngine() {
    _engine = PlaybackEngine(
      track: widget.song.tracks[_selectedTrackIndex],
      bpm: widget.song.bpm,
    );
    _engine.addListener(_onPlaybackUpdate);
  }

  void _onPlaybackUpdate() {
    if (mounted) {
      _scrollToActiveMeasure();
    }
  }

  void _scrollToActiveMeasure() {
    final measureIndex = _engine.currentMeasureIndex;
    if (measureIndex >= 0 && _scrollController.hasClients) {
      final position = measureIndex * 150.0;
      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  void _changeTrack(int index) {
    _engine.removeListener(_onPlaybackUpdate);
    _engine.dispose();
    setState(() {
      _selectedTrackIndex = index;
    });
    _initEngine();
  }

  void _togglePlay() {
    if (_engine.isPlaying) {
      _engine.pause();
    } else {
      _engine.play();
    }
  }

  void _stop() {
    _engine.stop();
  }

  void _seek(double position) {
    _engine.seekTo(position);
  }

  @override
  void dispose() {
    _engine.removeListener(_onPlaybackUpdate);
    _engine.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _getFileNameWithoutExtension(String? path) {
    if (path == null) return 'Desconhecido';
    final fileName = path.split('/').last.split('\\').last;
    final lastDot = fileName.lastIndexOf('.');
    if (lastDot == -1) return fileName;
    return fileName.substring(0, lastDot);
  }

  String _getParentFolder(String? path) {
    if (path == null) return '';
    final parts = path.split('/').where((p) => p.isNotEmpty).toList();
    if (parts.length < 2) return '';
    return parts[parts.length - 2];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fileName = _getFileNameWithoutExtension(widget.filePath);
    final folderName = _getParentFolder(widget.filePath);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fileName,
              style: theme.textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (folderName.isNotEmpty)
              Text(
                folderName,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            else if (widget.song.artist != 'Unknown')
              Text(
                widget.song.artist,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        actions: [
          if (widget.filePath != null)
            IconButton(
              icon: const Icon(Icons.info_outline),
              tooltip: 'Info do arquivo',
              onPressed: () => _showFileInfo(context),
            ),
        ],
      ),
      body: Column(
        children: [
          if (widget.song.tracks.length > 1) _buildTrackSelector(context),
          _buildPlaybackControls(context),
          const Divider(height: 1),
          Expanded(
            child: _buildScoreView(),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackSelector(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: List.generate(widget.song.tracks.length, (index) {
            final track = widget.song.tracks[index];
            final isSelected = index == _selectedTrackIndex;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(track.name),
                selected: isSelected,
                onSelected: (_) => _changeTrack(index),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPlaybackControls(BuildContext context) {
    final progress = _engine.getProgress();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                _formatPosition(_engine.currentPositionInBeats),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Expanded(
                child: Slider(
                  value: progress,
                  onChanged: _seek,
                  min: 0,
                  max: 1,
                ),
              ),
              Text(
                _formatPosition(_engine.totalBeats),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: () => _seek(0),
              ),
              IconButton(
                icon: const Icon(Icons.fast_rewind),
                onPressed: () => _seek((progress - 0.1).clamp(0, 1)),
              ),
              FilledButton(
                onPressed: _togglePlay,
                child: Icon(
                  _engine.isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 32,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.fast_forward),
                onPressed: () => _seek((progress + 0.1).clamp(0, 1)),
              ),
              IconButton(
                icon: const Icon(Icons.stop),
                onPressed: _stop,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                _engine.volume == 0 ? Icons.volume_off : Icons.volume_up,
                size: 20,
              ),
              Expanded(
                child: Slider(
                  value: _engine.volume,
                  onChanged: (value) => _engine.setVolume(value),
                  min: 0,
                  max: 1,
                ),
              ),
              Text(
                '${(_engine.volume * 100).round()}%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          if (_engine.currentBeat != null && !_engine.currentBeat!.isRest)
            _buildActiveBeatInfo(context),
        ],
      ),
    );
  }

  Widget _buildActiveBeatInfo(BuildContext context) {
    final beat = _engine.currentBeat;
    if (beat == null || beat.isRest) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        alignment: WrapAlignment.center,
        children: [
          for (final note in beat.notes)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'C${note.stringNum}: ${note.fret}${note.accidental ?? ''}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScoreView() {
    final track = widget.song.tracks[_selectedTrackIndex];

    return ListenableBuilder(
      listenable: _engine,
      builder: (context, _) {
        return SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: SizedBox(
              width: _calculateScoreWidth(track),
              height: _calculateScoreHeight(track),
              child: CustomPaint(
                painter: ScorePainter(
                  track: track,
                  bpm: widget.song.bpm,
                  timeSignatureNumerator: widget.song.timeSignatureNumerator,
                  timeSignatureDenominator: widget.song.timeSignatureDenominator,
                  keySignature: widget.song.keySignature,
                  currentMeasureIndex: _engine.currentMeasureIndex,
                  currentBeatIndex: _engine.currentBeatIndex,
                  beatProgress: _engine.beatProgress,
                  isPlaying: _engine.isPlaying,
                ),
                size: Size(_calculateScoreWidth(track), _calculateScoreHeight(track)),
              ),
            ),
          ),
        );
      },
    );
  }

  double _calculateScoreWidth(Track track) {
    double width = 120;
    for (final measure in track.measures) {
      width += measure.beats.length * 32 + 40;
    }
    return width;
  }

  double _calculateScoreHeight(Track track) {
    const marginTop = 50.0;
    const marginBottom = 30.0;
    const staffHeight = 20.0;
    const stringSpacing = 16.0;
    const spacing = 30.0;

    return marginTop + staffHeight + (track.strings - 1) * stringSpacing + marginBottom + spacing;
  }

  String _formatPosition(double beats) {
    final minutes = (beats / 4).floor();
    final seconds = ((beats / 4 - minutes) * 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _showFileInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(widget.song.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Artista', widget.song.artist),
            if (widget.song.album.isNotEmpty)
              _infoRow('Album', widget.song.album),
            _infoRow('BPM', widget.song.bpm.toString()),
            _infoRow('Compasso', '${widget.song.timeSignatureNumerator}/${widget.song.timeSignatureDenominator}'),
            _infoRow('Tracks', widget.song.tracks.length.toString()),
            if (widget.filePath != null)
              _infoRow('Arquivo', widget.filePath!.split('/').last),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
