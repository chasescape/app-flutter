import 'package:get/get.dart';
import '../../env/app_env.dart';
import '../../interface.dart';

class ApiProvider extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = AppEnv().hostApi;
    httpClient.timeout = const Duration(seconds: 15);

    httpClient.addRequestModifier<void>((request) {
      final token = Interface().authToken;
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      return request;
    });

    super.onInit();
  }
}
