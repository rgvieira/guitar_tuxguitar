import 'dart:typed_data';
import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class TuxGuitarAudioPlayer {
  final AudioPlayer _player;

  TuxGuitarAudioPlayer() : _player = AudioPlayer();

  AudioPlayer get raw => _player;

  Future<void> setBytes(Uint8List bytes, {String extension = 'wav'}) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/tuxguitar_audio.$extension');
    await file.writeAsBytes(bytes, flush: true);
    await _player.setFilePath(file.path);
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> stop() => _player.stop();
  Future<void> dispose() => _player.dispose();
}
