import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/diary_model.dart';

class DiaryStorageService {
  static const String _fileName = 'diaries.json';

  // 获取存储文件路径
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }

  // 读取所有日记
  Future<List<DiaryModel>> loadDiaries() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        return [];
      }

      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);
      return jsonList.map((json) => DiaryModel.fromJson(json)).toList();
    } catch (e) {
      print('Error loading diaries: $e');
      return [];
    }
  }

  // 保存所有日记
  Future<void> saveDiaries(List<DiaryModel> diaries) async {
    try {
      final file = await _localFile;
      final jsonList = diaries.map((diary) => diary.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      print('Error saving diaries: $e');
      rethrow;
    }
  }

  // 添加新日记
  Future<void> addDiary(DiaryModel diary) async {
    final diaries = await loadDiaries();
    diaries.insert(0, diary);
    await saveDiaries(diaries);
  }

  // 更新日记
  Future<void> updateDiary(DiaryModel diary) async {
    final diaries = await loadDiaries();
    final index = diaries.indexWhere((d) => d.id == diary.id);
    if (index != -1) {
      diaries[index] = diary;
      await saveDiaries(diaries);
    }
  }

  // 删除日记
  Future<void> deleteDiary(String id) async {
    final diaries = await loadDiaries();
    diaries.removeWhere((d) => d.id == id);
    await saveDiaries(diaries);
  }

  // 保存图片到本地
  Future<String> saveImage(File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/diary_images');
      
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await imageFile.copy('${imagesDir.path}/$fileName');
      return savedImage.path;
    } catch (e) {
      print('Error saving image: $e');
      rethrow;
    }
  }

  // 删除图片
  Future<void> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  /// 注销/删除账号时清空本地日记文件（diaries.json）
  static Future<void> clearAll() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_fileName');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error clearing diaries: $e');
    }
  }
}
