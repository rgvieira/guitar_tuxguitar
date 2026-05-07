import 'package:flutter/material.dart';
import '../model/song_model.dart';

class TrackSelector extends StatelessWidget {
  final Song song;
  final int selectedIndex;
  final void Function(int) onTrackSelected;

  const TrackSelector({
    super.key,
    required this.song,
    required this.selectedIndex,
    required this.onTrackSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(song.tracks.length, (index) {
          final track = song.tracks[index];
          final isSelected = index == selectedIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: FilterChip(
              label: Text(track.name),
              selected: isSelected,
              selectedColor: scheme.primaryContainer,
              onSelected: (_) => onTrackSelected(index),
            ),
          );
        }),
      ),
    );
  }
}
