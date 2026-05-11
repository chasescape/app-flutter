/// 统一的API响应格式
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? code;

  ApiResponse._({
    required this.success,
    this.data,
    this.message,
    this.code,
  });

  /// 成功响应
  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse._(
      success: true,
      data: data,
      message: message,
    );
  }

  /// 错误响应
  factory ApiResponse.error(String message, {int? code}) {
    return ApiResponse._(
      success: false,
      message: message,
      code: code,
    );
  }

  /// 是否成功
  bool get isSuccess => success;

  /// 是否失败
  bool get isError => !success;
}

/// 基础仓库类
/// 提供通用的数据处理方法
abstract class BaseRepository {
  /// 处理API响应
  T handleResponse<T>(ApiResponse<T> response) {
    if (response.isSuccess && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? 'Unknown error');
    }
  }

  /// 处理异常
  void handleError(dynamic error) {
    // 统一的错误处理逻辑
    print('Repository Error: $error');
    // 可以在这里添加错误上报、日志记录等
  }
}