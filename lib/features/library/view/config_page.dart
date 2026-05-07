import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/hive/hive_boxes.dart';
import '../../score_view/view_model/tab_notifier.dart';
import '../service/file_tree_service.dart';
import '../view/library_page.dart';

class ConfigPage extends ConsumerStatefulWidget {
  const ConfigPage({super.key});

  @override
  ConsumerState<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends ConsumerState<ConfigPage> {
  String? _currentRoot;
  bool _isScanning = false;
  String? _error;
  TabMode _tabMode = TabMode.demo;

  @override
  void initState() {
    super.initState();
    _currentRoot = HiveBoxes.getRootFolder();
    _tabMode = ref.read(tabModeProvider);
  }

  Future<void> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (status.isDenied) {
        setState(() {
          _error = 'Permission to access storage was denied';
        });
      }
    }
  }

  Future<void> _selectFolder() async {
    setState(() {
      _error = null;
      _isScanning = true;
    });

    try {
      await _requestStoragePermission();

      final selectedPath = await FilePicker.platform.getDirectoryPath();

      if (selectedPath != null) {
        await HiveBoxes.setRootFolder(selectedPath);
        await FileTreeService.scanDirectory(selectedPath);

        setState(() {
          _currentRoot = selectedPath;
        });

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const LibraryPage(),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _rescan() async {
    if (_currentRoot == null) return;
    setState(() {
      _error = null;
      _isScanning = true;
    });

    try {
      await FileTreeService.refreshTree(_currentRoot!);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const LibraryPage(),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Error rescanning: $e';
      });
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _clearConfig() async {
    await HiveBoxes.clearRootFolder();
    setState(() {
      _currentRoot = null;
    });
  }

  void _setMode(TabMode mode) {
    setState(() {
      _tabMode = mode;
    });
    ref.read(tabModeProvider.notifier).setMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuracoes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.settings,
              size: 60,
              color: scheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Modo de Operacao',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  RadioListTile<TabMode>(
                    title: const Text('Demo (sem servidor)'),
                    subtitle: const Text('Usa dados de exemplo para testar a UI'),
                    value: TabMode.demo,
                    groupValue: _tabMode,
                    onChanged: (mode) => mode != null ? _setMode(mode) : null,
                  ),
                  const Divider(height: 1),
                  RadioListTile<TabMode>(
                    title: const Text('API (backend Java)'),
                    subtitle: const Text('Conecta ao servidor para parsear arquivos reais'),
                    value: TabMode.api,
                    groupValue: _tabMode,
                    onChanged: (mode) => mode != null ? _setMode(mode) : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Pasta Raiz',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _currentRoot ?? 'Nenhuma pasta selecionada',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _isScanning ? null : _selectFolder,
              icon: _isScanning
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.folder),
              label: Text(_currentRoot == null ? 'Selecionar Pasta' : 'Trocar Pasta'),
            ),
            if (_currentRoot != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isScanning ? null : _rescan,
                icon: const Icon(Icons.refresh),
                label: const Text('Reescanear Pasta'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _clearConfig,
                icon: const Icon(Icons.delete_forever),
                label: const Text('Limpar Configuracao'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
            const Spacer(),
            Text(
              _tabMode == TabMode.demo
                  ? 'Modo demo: selecione demos ou configure uma pasta para ver arquivos'
                  : 'Modo API: backend Java necessario em http://10.0.2.2:8080',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
