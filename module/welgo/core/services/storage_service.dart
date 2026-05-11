import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class StorageService {
  static StorageService? _instance;

  static StorageService get instance {
    _instance ??= LocalStorageService._();
    return _instance!;
  }

  static void setInstance(StorageService service) {
    _instance = service;
  }

  Future<void> saveString(String key, String value);
  Future<String?> loadString(String key);
  Future<void> remove(String key);
  Future<void> clear();
  Future<void> saveFile(String filename, File file);
  Future<File?> loadFile(String filename);
  Future<void> deleteFile(String filename);
}

class LocalStorageService implements StorageService {
  SharedPreferences? _prefs;
  Directory? _appDocDir;
  Future<void>? _initFuture;

  LocalStorageService._();

  Future<void> init() async {
    _initFuture ??= _initialize();
    await _initFuture;
  }

  Future<void> _initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _appDocDir = await getApplicationDocumentsDirectory();
  }

  @override
  Future<void> saveString(String key, String value) async {
    await init();
    await _prefs!.setString(key, value);
  }

  @override
  Future<String?> loadString(String key) async {
    await init();
    return _prefs!.getString(key);
  }

  @override
  Future<void> remove(String key) async {
    await init();
    await _prefs!.remove(key);
  }

  @override
  Future<void> clear() async {
    await init();
    await _prefs!.clear();
  }

  @override
  Future<void> saveFile(String filename, File file) async {
    await init();
    final newPath = '${_appDocDir!.path}/$filename';
    await file.copy(newPath);
  }

  @override
  Future<File?> loadFile(String filename) async {
    await init();
    final path = '${_appDocDir!.path}/$filename';
    final file = File(path);
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  @override
  Future<void> deleteFile(String filename) async {
    await init();
    final path = '${_appDocDir!.path}/$filename';
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
