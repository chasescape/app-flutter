import 'package:get/get.dart';
import 'package:enkou/enkou/app/routes/app_routes.dart';

class DetailLogic extends GetxController {
  late final String title;
  late final String subtitle;
  late final String body;
  late final List<Map<String, String>> medias;
  String? entryId;
  DateTime? date;
  String locationTag = '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    title = args['title'] as String? ?? 'Journal Detail';
    subtitle = args['subtitle'] as String? ?? '';
    body = args['body'] as String? ?? 'No content';
    final raw = args['medias'] as List<dynamic>? ?? [];
    medias = raw
        .map((e) => {
              'type': '${e['type'] ?? ''}',
              'label': '${e['label'] ?? ''}',
              'source': '${e['source'] ?? ''}',
            })
        .toList();
    entryId = args['entryId'] as String?;
    final d = args['date'];
    date = d is DateTime ? d : null;
    locationTag = args['locationTag'] as String? ?? '';
  }

  void openEditJournal() {
    if (entryId == null || date == null) return;
    Get.toNamed(
      AppRoutes.dayJournal,
      arguments: {
        'entryId': entryId,
        'date': date,
        'locationTag': locationTag,
      },
    );
  }

  bool get canEdit => entryId != null && date != null;
}
