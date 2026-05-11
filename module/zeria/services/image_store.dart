import 'dart:io';

import 'package:path_provider/path_provider.dart';

class ImageStore {
  ImageStore._();

  static final ImageStore instance = ImageStore._();

  Directory? _imagesDir;

  Future<void> init() async {
    if (_imagesDir != null) return;
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/zeria/images');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _imagesDir = dir;
  }

  Future<String> saveUploadedImage(File source) async {
    await init();
    final imagesDir = _imagesDir!;

    final ext = _safeExtension(source.path);
    final fileName =
        'spark_${DateTime.now().millisecondsSinceEpoch}_${source.hashCode}$ext';
    final dest = File('${imagesDir.path}/$fileName');
    await source.copy(dest.path);
    return dest.path;
  }

  Future<void> deleteIfManaged(String path) async {
    if (path.trim().isEmpty) return;
    await init();
    final imagesDir = _imagesDir!;

    final normalized = path.trim();
    if (!normalized.startsWith(imagesDir.path)) return;

    final file = File(normalized);
    if (await file.exists()) {
      await file.delete();
    }
  }

  String _safeExtension(String path) {
    final dot = path.lastIndexOf('.');
    if (dot <= 0 || dot >= path.length - 1) return '.jpg';
    final ext = path.substring(dot).toLowerCase();
    const allowed = {'.jpg', '.jpeg', '.png', '.webp'};
    return allowed.contains(ext) ? ext : '.jpg';
  }
}

