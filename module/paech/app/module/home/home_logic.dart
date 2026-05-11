import 'package:get/get.dart';

class HomeLogic extends GetxController {
  // 加载状态
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  /// 模拟数据加载
  Future<void> _loadData() async {
    isLoading.value = true;
    // 模拟网络请求延迟
    await Future.delayed(const Duration(milliseconds: 1500));
    isLoading.value = false;
  }

  /// 刷新数据
  Future<void> refresh() async {
    await _loadData();
  }
}

