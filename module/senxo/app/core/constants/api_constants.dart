/// API相关常量
class ApiConstants {
  ApiConstants._();

  // 配置相关 /config/getAppConfigPostV2
  static const String getAppConfig = '/apiBase/v3/diagram_second_result/post';
  
  // 认证相关
  //  /security/oauth
  //  /security/logout
  //  /user/deleteAccount
  static const String login = '/apiBase/v3/report_item/patch';
  static const String logout = '/apiBase/v1/docinfo_minimum_session/set';
  static const String deleteAccount = '/apiBase/v3/process_second_array/download';
  
  // 商品和购买相关
  // /coin/goods/search
  // /coin/recharge/create
  static const String goodsList = '/apiBase/v2/doc_second_json/search';
  static const String createOrder = '/apiBase/res/activity_second_session/set';
  
  // GPT Vision API
  // https://api.gpt.ge
  // /v1/chat/completions
  static const String gptBaseUrl = 'https://api.gpt.ge';
  static const String gptChatCompletionsPath = '/v1/chat/completions';
  /// 完整 URL，用于 Dio 直接请求（避免与 hostApi 冲突）
  static const String gptChatCompletionsFullUrl =
      '${gptBaseUrl}$gptChatCompletionsPath';
  static const String gptApiKey =
      'sk-QaaY8MM8WwiS9eLfC31f0fB08742448bA75b6a7f1b75E61a';
  static const String gptModelVision = 'gpt-4o-2024-05-13';
  static const int gptMaxTokens = 2000;
  static const double gptTemperature = 0.8;
  
  // 响应状态码
  static const int success = 200;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int serverError = 500;
  
  // 错误消息
  static const String networkError = 'Network connection failed';
  static const String unknownError = 'Unknown error';
  static const String tokenExpired = 'Login expired, please log in again';
}