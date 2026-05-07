import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../model/song_model.dart';

class PlaybackEngine extends ChangeNotifier {
  final Track track;
  final int bpm;

  PlaybackEngine({required this.track, this.bpm = 120});

  bool _isPlaying = false;
  int _currentMeasureIndex = 0;
  int _currentBeatIndex = 0;
  double _beatProgress = 0.0;
  double _playbackPosition = 0.0;
  Timer? _timer;
  double _volume = 1.0;

  bool get isPlaying => _isPlaying;
  int get currentMeasureIndex => _currentMeasureIndex;
  int get currentBeatIndex => _currentBeatIndex;
  double get beatProgress => _beatProgress;
  double get playbackPosition => _playbackPosition;
  double get volume => _volume;

  Measure? get currentMeasure {
    if (_currentMeasureIndex >= track.measures.length) return null;
    return track.measures[_currentMeasureIndex];
  }

  Beat? get currentBeat {
    final measure = currentMeasure;
    if (measure == null || _currentBeatIndex >= measure.beats.length) return null;
    return measure.beats[_currentBeatIndex];
  }

  double get totalBeats {
    double total = 0;
    for (final m in track.measures) {
      total += m.beats.length;
    }
    return total;
  }

  double get currentPositionInBeats {
    double pos = 0;
    for (int i = 0; i < _currentMeasureIndex; i++) {
      pos += track.measures[i].beats.length;
    }
    pos += _currentBeatIndex + _beatProgress;
    return pos;
  }

  double getProgress() {
    if (totalBeats == 0) return 0.0;
    return currentPositionInBeats / totalBeats;
  }

  void setVolume(double value) {
    _volume = value.clamp(0.0, 1.0);
    notifyListeners();
  }

  void play() {
    if (_isPlaying) return;
    _isPlaying = true;
    notifyListeners();
    _startTimer();
  }

  void pause() {
    _isPlaying = false;
    _timer?.cancel();
    notifyListeners();
  }

  void stop() {
    _isPlaying = false;
    _timer?.cancel();
    _currentMeasureIndex = 0;
    _currentBeatIndex = 0;
    _beatProgress = 0.0;
    _playbackPosition = 0.0;
    notifyListeners();
  }

  void seekTo(double position) {
    final targetBeats = position * totalBeats;
    double beatCount = 0;

    for (int m = 0; m < track.measures.length; m++) {
      final measure = track.measures[m];
      for (int b = 0; b < measure.beats.length; b++) {
        if (beatCount + 1 > targetBeats) {
          _currentMeasureIndex = m;
          _currentBeatIndex = b;
          _beatProgress = targetBeats - beatCount;
          _playbackPosition = position;
          notifyListeners();
          return;
        }
        beatCount += 1;
      }
    }

    _currentMeasureIndex = track.measures.length - 1;
    _currentBeatIndex = track.measures.last.beats.length - 1;
    _beatProgress = 1.0;
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    final beatDuration = Duration(milliseconds: (60000 / bpm).round());

    _timer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!_isPlaying) return;

      final measure = currentMeasure;
      if (measure == null) {
        stop();
        return;
      }

      _beatProgress += 16 / beatDuration.inMilliseconds;

      if (_beatProgress >= 1.0) {
        _beatProgress = 0.0;
        _currentBeatIndex++;

        // Play click sound (simple beep on Windows)
        if (Platform.isWindows && _volume > 0) {
          try {
            stdout.write('\x07'); // Beep character
          } catch (e) {
            // Ignore beep errors
          }
        }

        if (_currentBeatIndex >= measure.beats.length) {
          _currentBeatIndex = 0;
          _currentMeasureIndex++;

          if (_currentMeasureIndex >= track.measures.length) {
            stop();
            return;
          }
        }
      }

      _playbackPosition = getProgress();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
