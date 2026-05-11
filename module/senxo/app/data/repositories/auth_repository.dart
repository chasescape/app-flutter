import 'package:get/get.dart';
import 'base_repository.dart';
import '../providers/api_provider.dart';
import '../models/user/login_response.dart';

/// 认证数据仓库
/// 处理认证相关的数据操作
class AuthRepository extends BaseRepository {
  late ApiProvider _apiProvider;

  AuthRepository() {
    _apiProvider = Get.find<ApiProvider>();
  }

  /// 登录（账号密码 或 oauthType+udid）
  Future<LoginResponse> login({
    String? oauthType,
    String? udid,
  }) async {
    try {
      final response = await _apiProvider.login(
        oauthType: oauthType,
        udid: udid,
      );

      print('AuthRepository.login: response.success=${response.success}, code=${response.code}, message=${response.message}');

      if (!response.success || response.data == null) {
        throw Exception(response.message ?? 'Login failed: code=${response.code}');
      }

      // response.data 的结构是：
      // {
      //   "code": 0,
      //   "data": {
      //     "token": "...",
      //     "userInfo": {...}
      //   }
      // }
      // 需要提取 data 字段
      final responseData = response.data!;
      final loginData = responseData['data'] as Map<String, dynamic>?;
      
      if (loginData == null) {
        throw Exception('Login response missing data field');
      }

      return handleResponse(ApiResponse.success(LoginResponse.fromJson(loginData)));
    } catch (e) {
      print('AuthRepository.login: error=$e');
      handleError(e);
      rethrow;
    }
  }

  /// 刷新token
  Future<LoginResponse> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final response = await _apiProvider.refreshToken(
        refreshToken: refreshToken,
      );
      
      return handleResponse(response.success 
        ? ApiResponse.success(LoginResponse.fromJson(response.data!))
        : ApiResponse.error(response.message ?? 'Refresh token failed'));
    } catch (e) {
      handleError(e);
      rethrow;
    }
  }

  /// 登出
  Future<void> logout() async {
    try {
      final response = await _apiProvider.logout();
      
      if (!response.success) {
        throw Exception(response.message ?? 'Logout failed');
      }
    } catch (e) {
      handleError(e);
      rethrow;
    }
  }

  /// 删除账户
  Future<void> deleteAccount() async {
    try {
      final response = await _apiProvider.deleteAccount();
      
      if (!response.success) {
        throw Exception(response.message ?? 'Delete account failed');
      }
    } catch (e) {
      handleError(e);
      rethrow;
    }
  }

}