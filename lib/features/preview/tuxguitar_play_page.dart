import 'dart:typed_data';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/tuxguitar/tuxguitar_api.dart';
import '../../core/audio/tuxguitar_audio_player.dart';

class TuxGuitarPlayPage extends StatefulWidget {
  const TuxGuitarPlayPage({super.key});

  @override
  State<TuxGuitarPlayPage> createState() => _TuxGuitarPlayPageState();
}

class _TuxGuitarPlayPageState extends State<TuxGuitarPlayPage> {
  late final TuxGuitarApi _api;
  late final TuxGuitarAudioPlayer _player;

  Uint8List? _currentAudio;
  bool _loading = false;
  String? _status;

  @override
  void initState() {
    super.initState();
    _api = TuxGuitarApi(baseUrl: 'http://10.0.2.2:8080');
    _player = TuxGuitarAudioPlayer();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _pickAndPlay() async {
    setState(() => _status = null);

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['gp3', 'gp4', 'gp5', 'gpx', 'gp', 'mid', 'midi'],
    );

    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);

    setState(() {
      _loading = true;
      _status = 'Enviando para backend...';
    });

    try {
      final audioBytes = await _api.renderAudio(file);

      setState(() {
        _currentAudio = audioBytes;
        _status = 'Áudio recebido, tocando...';
      });

      await _player.setBytes(audioBytes, extension: 'wav');
      await _player.play();
    } catch (e) {
      setState(() => _status = 'Erro: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TuxGuitar Play')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _loading ? null : _pickAndPlay,
              child: const Text('Escolher .gp e tocar'),
            ),
            const SizedBox(height: 16),
            if (_loading) const CircularProgressIndicator(),
            if (_status != null) ...[
              const SizedBox(height: 16),
              Text(_status!),
            ],
            const Spacer(),
            if (_currentAudio != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () => _player.play(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.pause),
                    onPressed: () => _player.raw.pause(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.stop),
                    onPressed: () => _player.raw.stop(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
