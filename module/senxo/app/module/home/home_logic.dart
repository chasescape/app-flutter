import 'package:get/get.dart';
import '../../data/mock_data.dart';
import '../../data/models/equipment/equipment_model.dart';

class HomeLogic extends GetxController {
  final isLoading = true.obs;
  
  // Home 页面使用 MockData 的固定展示数据
  List<EquipmentModel> get allEquipment => MockData.equipmentList;
  
  // Featured equipment (first item)
  EquipmentModel get featuredEquipment => allEquipment.first;
  
  // Recent inspections (items 2-3)
  List<EquipmentModel> get recentInspections => allEquipment.skip(1).take(2).toList();
  
  // Safety overview (items 4-9)
  List<EquipmentModel> get safetyOverview => allEquipment.skip(3).take(6).toList();
  
  // All equipment grid (items 10-15)
  List<EquipmentModel> get equipmentGrid => allEquipment.skip(9).take(6).toList();

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(milliseconds: 800));
    isLoading.value = false;
  }
}
