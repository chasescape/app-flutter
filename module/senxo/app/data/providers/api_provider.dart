import 'dart:convert';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../repositories/base_repository.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/encrypt_service.dart';

/// API数据提供者
/// 封装所有API调用，提供统一的数据接口
class ApiProvider extends GetxService {
  late DioClient _dioClient;
  late EncryptService _encryptService;

  @override
  void onInit() {
    super.onInit();
    _dioClient = Get.find<DioClient>();
    _encryptService = Get.find<EncryptService>();
  }

  // ==================== 认证相关API ====================

  /// 登录（支持账号密码 或 oauthType+token 设备登录）
  Future<ApiResponse<Map<String, dynamic>>> login({
    String? username,
    String? password,
    String? oauthType,
    String? udid,
  }) async {
    try {
      final Map<String, dynamic> loginData;
      if (oauthType != null && oauthType.isNotEmpty) {
        // 设备登录：使用 oauthType 和 token（设备ID）
        loginData = {
          'oauthType': oauthType,
          'token': udid ?? '',  // 注意：字段名是 token，不是 udid
        };
      } else {
        // 账号密码登录
        loginData = {
          'username': username ?? '',
          'password': password ?? '',
        };
      }
      
      print('===============================================');
      print('Login request data: $loginData');
      print('===============================================');
      
      // 加密请求体：合并请求头和业务数据，加密后直接作为 body
      // 要求 encrypt_key 必须已初始化，否则直接返回错误，禁止明文兜底
      if (_encryptService.needRefreshConfig()) {
        return ApiResponse.error('encrypt_key is not initialized');
      }
      final requestBody = await _encryptService.encodeData(loginData);

      final response = await _dioClient.post(
        ApiConstants.login,
        data: requestBody,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          responseType: ResponseType.plain, // 响应是加密的 Base64 字符串
        ),
      );

      // 解密响应
      final responseData = _decryptResponse(response.data);
      print('----------------------------------------');
      print('Login response: $responseData');
      print('----------------------------------------');

      // 检查响应的 success 字段
      if (responseData['success'] == true) {
        return ApiResponse.success(responseData);
      } else {
        // 登录失败，返回错误
        final errorMsg = responseData['msg'] ?? 'Login failed';
        final errorCode = responseData['code'] ?? -1;
        print('Login failed: code=$errorCode, msg=$errorMsg');
        return ApiResponse.error('$errorMsg (code: $errorCode)');
      }
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// 解密响应数据
  Map<String, dynamic> _decryptResponse(dynamic responseData) {
    // 响应是加密的 Base64 字符串（responseType.plain）
    if (responseData is String) {
      if (responseData.isEmpty) {
        return <String, dynamic>{};
      }
      if (_encryptService.needRefreshConfig()) {
        // 没有加密 key，尝试直接解析 JSON
        try {
          return jsonDecode(responseData) as Map<String, dynamic>;
        } catch (_) {
          return <String, dynamic>{};
        }
      }
      // 有加密 key，先解密再解析
      try {
        return _encryptService.decodeData(responseData);
      } catch (e) {
        // 解密失败，尝试直接解析（降级）
        try {
          return jsonDecode(responseData) as Map<String, dynamic>;
        } catch (_) {
          print('响应解密和解析都失败: $e');
          return <String, dynamic>{};
        }
      }
    }
    // 如果已经是 Map（不应该发生，因为设置了 plain）
    if (responseData is Map) {
      return Map<String, dynamic>.from(responseData);
    }
    return <String, dynamic>{};
  }

  /// 登出（需要加密）
  Future<ApiResponse<void>> logout() async {
    try {
      print('ApiProvider.logout: 开始登出...');
      print(
          'ApiProvider.logout: encryptKey 是否存在: ${!_encryptService.needRefreshConfig()}');

      // 构建请求体（空 body 或基础字段）
      final logoutData = <String, dynamic>{};

      // 要求 encrypt_key 必须已初始化，否则直接返回错误，禁止明文兜底
      if (_encryptService.needRefreshConfig()) {
        print('ApiProvider.logout: encryptKey 不存在，中止登出请求');
        return ApiResponse.error('encrypt_key is not initialized');
      }

      print('ApiProvider.logout: encryptKey 存在，加密请求体');
      final requestBody = await _encryptService.encodeData(logoutData);
      print('ApiProvider.logout: 请求体已加密，长度: ${requestBody.length}');

      print('ApiProvider.logout: 发送请求到 ${ApiConstants.logout}');
      final response = await _dioClient.post(
        ApiConstants.logout,
        data: requestBody,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          responseType: ResponseType.plain,
        ),
      );

      print('ApiProvider.logout: 收到响应，状态码: ${response.statusCode}');

      // 解密响应（如果有）
      if (response.data != null && response.data.toString().isNotEmpty) {
        print('ApiProvider.logout: 解密响应...');
        _decryptResponse(response.data);
      }

      print('ApiProvider.logout: 登出成功');
      return ApiResponse.success(null);
    } catch (e) {
      print('ApiProvider.logout: 登出失败: $e');
      return ApiResponse.error(e.toString());
    }
  }

  /// 删除账户（需要加密）
  Future<ApiResponse<void>> deleteAccount() async {
    try {
      // 构建请求体
      final deleteData = <String, dynamic>{};

      // 要求 encrypt_key 必须已初始化，否则直接返回错误，禁止明文兜底
      if (_encryptService.needRefreshConfig()) {
        return ApiResponse.error('encrypt_key is not initialized');
      }
      final requestBody = await _encryptService.encodeData(deleteData);

      final response = await _dioClient.post(
        ApiConstants.deleteAccount,
        data: requestBody,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          responseType: ResponseType.plain,
        ),
      );

      // 解密响应（如果有）
      if (response.data != null && response.data.toString().isNotEmpty) {
        _decryptResponse(response.data);
      }

      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  /// 刷新token
  Future<ApiResponse<Map<String, dynamic>>> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final response = await _dioClient.post('/auth/refresh', data: {
        'refresh_token': refreshToken,
      });
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // ==================== 商品和购买相关API ====================

  /// 获取商品列表（需要加密）
  /// 根据文档，所有接口都需要加密，GET 请求的参数也需要放到 body 中加密
  Future<ApiResponse<List<Map<String, dynamic>>>> getGoodsList({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      print('ApiProvider.getGoodsList: 开始获取商品列表...');
      print(
          'ApiProvider.getGoodsList: encryptKey 是否存在: ${!_encryptService.needRefreshConfig()}');

      // 构建请求体（把 query 参数放到 body 中，用于加密）
      final goodsData = {
        'page': page,
        'pageSize': pageSize,
      };

      // 要求 encrypt_key 必须已初始化，否则直接返回错误，禁止明文兜底
      if (_encryptService.needRefreshConfig()) {
        print('ApiProvider.getGoodsList: encryptKey 不存在，中止请求');
        return ApiResponse.error('encrypt_key is not initialized');
      }

      print('ApiProvider.getGoodsList: encryptKey 存在，加密请求体');
      final requestBody = await _encryptService.encodeData(goodsData);
      print('ApiProvider.getGoodsList: 请求体已加密，长度: ${requestBody.length}');

      // 使用 POST 请求（因为需要加密 body）
      final response = await _dioClient.post(
        ApiConstants.goodsList,
        data: requestBody,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          responseType: ResponseType.plain,
        ),
      );

      print('ApiProvider.getGoodsList: 收到响应，状态码: ${response.statusCode}');

      // 解密响应
      final responseData = _decryptResponse(response.data);

      // 假设返回的数据结构是 {data: [...]}
      final List<dynamic> goods = responseData['data'] ?? [];
      print('ApiProvider.getGoodsList: 解析到 ${goods.length} 个商品');
      return ApiResponse.success(goods.cast<Map<String, dynamic>>());
    } catch (e) {
      print('ApiProvider.getGoodsList: 获取商品列表失败: $e');
      return ApiResponse.error(e.toString());
    }
  }

  /// 创建购买订单
  Future<ApiResponse<Map<String, dynamic>>> createOrder({
    required String goodsId,
    required int quantity,
  }) async {
    try {
      final orderData = {
        'goodsId': goodsId,
        'quantity': quantity,
      };

      // 要求 encrypt_key 必须已初始化，否则直接返回错误，禁止明文兜底
      if (_encryptService.needRefreshConfig()) {
        return ApiResponse.error('encrypt_key is not initialized');
      }
      final requestBody = await _encryptService.encodeData(orderData);

      final response = await _dioClient.post(
        ApiConstants.createOrder,
        data: requestBody,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          responseType: ResponseType.plain,
        ),
      );

      final responseData = _decryptResponse(response.data);
      return ApiResponse.success(responseData);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  // ==================== GPT 图像分析API ====================

  /// 使用 GPT Vision 分析图片
  Future<ApiResponse<Map<String, dynamic>>> analyzeImageWithGPT({
    required String imagePath,
    required String prompt,
  }) async {
    try {
      final response = await _dioClient.uploadImageForAnalysis(
        imagePath,
        prompt: prompt,
      );

      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

// ==================== 其他API可以在这里添加 ====================
}
