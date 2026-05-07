import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/hive/hive_boxes.dart';
import 'features/settings/view_model/theme_mode_notifier.dart';
import 'features/library/view/library_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveBoxes.init();

  runApp(const ProviderScope(child: GuitarApp()));
}

class GuitarApp extends ConsumerWidget {
  const GuitarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.read(themeModeProvider.notifier).flutterThemeMode;

    return MaterialApp(
      title: 'Guitar TuxGuitar',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: mode,
      home: const LibraryPage(),
    );
  }
}
