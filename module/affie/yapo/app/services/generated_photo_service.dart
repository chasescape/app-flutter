import 'dart:io';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// 生成照片本地存储服务
class GeneratedPhotoService extends GetxService {
  static const String _storageKey = 'generated_photos';

  final generatedPhotos = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromLocal();
  }

  /// 从本地加载生成的照片（自动过滤不存在的文件）
  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = json.decode(jsonString);
        final List<Map<String, dynamic>> allPhotos =
            decoded.cast<Map<String, dynamic>>();

        // ✅ 过滤掉文件不存在的照片
        final List<Map<String, dynamic>> validPhotos = [];
        bool hasInvalidPhotos = false;

        for (final photo in allPhotos) {
          final image = photo['image'] as String?;
          final isGenerated = photo['isGenerated'] == true;

          // 检查文件是否存在（仅对生成的照片且非 http 链接）
          if (isGenerated && image != null && !image.startsWith('http')) {
            final file = File(image);
            if (file.existsSync()) {
              validPhotos.add(photo);
            } else {
              hasInvalidPhotos = true;
              print('⚠️ 文件不存在，已自动移除: $image');
            }
          } else {
            validPhotos.add(photo);
          }
        }

        generatedPhotos.value = validPhotos;

        // 如果有无效照片被移除，更新本地存储
        if (hasInvalidPhotos) {
          await _saveToLocal();
          print('✅ 已自动清理 ${allPhotos.length - validPhotos.length} 个无效照片');
        }
      }
    } catch (e) {
      print('加载生成照片失败: $e');
    }
  }

  /// 保存生成的照片到本地
  Future<void> saveGeneratedPhoto({
    required String id,
    required String imagePath,
    required String title,
    required String location,
    required String date,
    required String description,
    String? time,
    String? weather,
    List<String>? tags,
    List<String>? highlights,
  }) async {
    try {
      final photoData = {
        'id': id,
        'image': imagePath,
        'title': title,
        'location': location,
        'date': date,
        'story': description,
        'time': time,
        'weather': weather,
        'tags': tags ?? [],
        'highlights':
            highlights ?? ['AI Generated', 'Travel Album', 'Personalized'],
        'isGenerated': true,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // 添加到列表开头（最新的在前面）
      generatedPhotos.insert(0, photoData);

      // 保存到本地
      await _saveToLocal();

      print('✅ 生成照片已保存到本地');
    } catch (e) {
      print('❌ 保存生成照片失败: $e');
    }
  }

  /// 保存到本地存储
  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(generatedPhotos);
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      print('保存到本地失败: $e');
    }
  }

  /// 删除生成的照片
  Future<void> deleteGeneratedPhoto(String id) async {
    try {
      generatedPhotos.removeWhere((photo) => photo['id'] == id);
      await _saveToLocal();
      print('✅ 照片已删除');
    } catch (e) {
      print('❌ 删除照片失败: $e');
    }
  }

  /// 清空所有生成的照片
  Future<void> clearAll() async {
    try {
      generatedPhotos.clear();
      await _saveToLocal();
      print('✅ 已清空所有生成照片');
    } catch (e) {
      print('❌ 清空失败: $e');
    }
  }

  /// 根据 ID 获取照片
  Map<String, dynamic>? getPhotoById(String id) {
    try {
      return generatedPhotos.firstWhere((photo) => photo['id'] == id);
    } catch (e) {
      return null;
    }
  }
}
