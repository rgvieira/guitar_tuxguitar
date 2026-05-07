import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class HiveBoxes {
  static const settings = 'settings_box';
  static const fileTree = 'file_tree_box';
  static const scoreCache = 'score_cache_box';

  static const keyRootFolder = 'root_folder';
  static const keyTabMode = 'tab_mode';

  static Future<void> init() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final appDir = await getApplicationDocumentsDirectory();
      Hive.init('${appDir.path}/guitar_tuxguitar');
    } else {
      await Hive.initFlutter();
    }
    await Hive.openBox(settings);
    await Hive.openBox(fileTree);
    await Hive.openBox(scoreCache);
  }

  static Future<void> setRootFolder(String path) async {
    await Hive.box(settings).put(keyRootFolder, path);
  }

  static String? getRootFolder() {
    return Hive.box(settings).get(keyRootFolder) as String?;
  }

  static Future<void> clearRootFolder() async {
    await Hive.box(settings).delete(keyRootFolder);
    await Hive.box(fileTree).clear();
  }

  static Future<void> setTabMode(String mode) async {
    await Hive.box(settings).put(keyTabMode, mode);
  }

  static String? getTabMode() {
    return Hive.box(settings).get(keyTabMode) as String?;
  }
}
