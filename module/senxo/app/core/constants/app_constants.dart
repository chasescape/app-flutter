/// 应用常量
class AppConstants {
  AppConstants._();

  // 应用信息
  static const String appName = 'Senxo';
  static const String appVersion = '1.0.0';
  
  // 页面常量
  static const int pageSize = 20;
  static const int maxRetryCount = 3;
  
  // 时间常量
  static const int requestTimeout = 30; // 秒
  static const int tokenExpireTime = 7 * 24 * 60 * 60; // 7天，秒
  
  // AI 相关常量
  static const String defaultAIPrompt = 'Please describe the content of this image in detail';
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> supportedImageTypes = ['jpg', 'jpeg', 'png'];

  /// 图生文：极限运动设备佩戴安全检查 - 用于 AI 分析图片中设备是否安全正确佩戴
  static const String equipmentSafetyCheckPrompt = '''
You are an expert in extreme sports equipment safety. Analyze the image and check whether any visible safety equipment (e.g. helmet, harness, bindings, protective gear) is worn correctly and safely.

**Analysis Guidelines:**
- Identify all visible safety/equipment items (helmet, goggles, harness, bindings, pads, etc.)
- Check if each item is worn/correctly fastened and in good condition
- Note any obvious misuse, looseness, damage, or missing parts that could cause risk
- Consider the activity context if visible (skiing, climbing, cycling, etc.)

**Output Requirements:**
Return ONLY a valid JSON object (no markdown, no code block wrapper) with this exact structure:
{
  "equipment_type": "Brief name of main equipment (e.g. Ski Helmet, Climbing Harness)",
  "is_worn_safely": true or false,
  "safety_score_percent": number 0-100,
  "wear_level": "Low" or "Medium" or "High",
  "condition_summary": "One short sentence on overall condition",
  "issues": ["issue1", "issue2"] or [],
  "recommendations": "One or two short sentences: what to fix or that equipment appears safe."
}

**Important:** Base your analysis only on what is clearly visible in the image. If no safety equipment is visible, set equipment_type to "Unknown", is_worn_safely to false, and explain in recommendations. Return ONLY the JSON object.
''';
}