import 'package:get/get.dart';

class DetailsLogic extends GetxController {
  String? get imagePath {
    final args = Get.arguments;

    if (args is Map) {
      final value = args['imagePath'];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  String? get title {
    final args = Get.arguments;
    if (args is Map) {
      final value = args['title'];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  String? get description {
    final args = Get.arguments;
    if (args is Map) {
      final value = args['description'];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  List<Map<String, String>>? get tips {
    final args = Get.arguments;
    if (args is Map) {
      final value = args['tips'];
      if (value is List) {
        try {
          return value
              .map((e) {
                if (e is Map) {
                  return e.map((key, val) => MapEntry(key.toString(), val.toString()));
                }
                return null;
              })
              .whereType<Map<String, String>>()
              .toList();
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }
}
