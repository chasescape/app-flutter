import 'package:get/get.dart';
import '../../controllers/collection_controller.dart';
import '../../data/models/perfume_record.dart';

String? resolvePerfumeImage(PerfumeRecord record) {
  if (record.imageUrl?.isNotEmpty == true) {
    return record.imageUrl;
  }

  if (!Get.isRegistered<CollectionController>()) {
    return null;
  }

  final controller = Get.find<CollectionController>();
  final matchedPerfume = controller.perfumes.firstWhereOrNull(
    (perfume) =>
        perfume.name.trim().toLowerCase() ==
            record.perfumeName.trim().toLowerCase() &&
        perfume.brand.trim().toLowerCase() ==
            record.brand.trim().toLowerCase() &&
        perfume.imageUrl?.isNotEmpty == true,
  );

  return matchedPerfume?.imageUrl;
}
