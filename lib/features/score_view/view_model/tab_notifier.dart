import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/hive/hive_boxes.dart';
import '../model/song_model.dart';
import '../model/tab_api_service.dart';
import '../model/demo_song_factory.dart';

enum TabLoadState { initial, loading, loaded, error }
enum TabMode { api, demo }

class TabState {
  final TabLoadState state;
  final Song? song;
  final int selectedTrackIndex;
  final String? error;
  final String? filePath;

  const TabState({
    this.state = TabLoadState.initial,
    this.song,
    this.selectedTrackIndex = 0,
    this.error,
    this.filePath,
  });

  Track? get selectedTrack {
    if (song == null || song!.tracks.isEmpty) return null;
    final idx = selectedTrackIndex.clamp(0, song!.tracks.length - 1);
    return song!.tracks[idx];
  }

  TabState copyWith({
    TabLoadState? state,
    Song? song,
    int? selectedTrackIndex,
    String? error,
    String? filePath,
  }) {
    return TabState(
      state: state ?? this.state,
      song: song ?? this.song,
      selectedTrackIndex: selectedTrackIndex ?? this.selectedTrackIndex,
      error: error ?? this.error,
      filePath: filePath ?? this.filePath,
    );
  }
}

class TabNotifier extends Notifier<TabState> {
  TabMode mode = TabMode.api;
  TabApiService? _api;

  @override
  TabState build() {
    _api = ref.watch(apiServiceProvider);
    return const TabState();
  }

  void setMode(TabMode newMode) {
    mode = newMode;
    ref.read(tabModeProvider.notifier).setMode(newMode);
  }

  Future<void> loadFile(String filePath) async {
    if (mode == TabMode.demo) {
      _loadDemo(filePath);
      return;
    }

    state = state.copyWith(state: TabLoadState.loading, error: null, filePath: filePath);
    try {
      final song = await _api!.parseFile(filePath);
      state = state.copyWith(
        state: TabLoadState.loaded,
        song: song,
        selectedTrackIndex: 0,
        filePath: filePath,
      );
    } on TabApiException catch (e) {
      state = state.copyWith(
        state: TabLoadState.error,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        state: TabLoadState.error,
        error: e.toString(),
      );
    }
  }

  void _loadDemo(String filePath) {
    final lower = filePath.toLowerCase();
    final song = lower.contains('blues')
        ? DemoSongFactory.createBluesDemo()
        : DemoSongFactory.createRockDemo();

    state = state.copyWith(
      state: TabLoadState.loaded,
      song: song,
      selectedTrackIndex: 0,
      filePath: filePath,
    );
  }

  void selectTrack(int index) {
    state = state.copyWith(selectedTrackIndex: index);
  }

  void reset() {
    state = const TabState();
  }
}

final apiServiceProvider = Provider<TabApiService>(
  (ref) => TabApiService(baseUrl: 'http://10.0.2.2:8080'),
);

class TabModeNotifier extends Notifier<TabMode> {
  @override
  TabMode build() {
    final saved = HiveBoxes.getTabMode();
    if (saved == 'api') return TabMode.api;
    return TabMode.demo;
  }

  void setMode(TabMode mode) {
    state = mode;
    HiveBoxes.setTabMode(mode.name);
  }
}

final tabModeProvider = NotifierProvider<TabModeNotifier, TabMode>(
  TabModeNotifier.new,
);

final tabProvider = NotifierProvider<TabNotifier, TabState>(
  TabNotifier.new,
);
