# Lesh AI 故事生成服务 API 文档

## 概述

本文档详细分析了 Lesh 应用的 AI 故事生成服务实现，提供了基于 GPT-4 Vision 的图生文（Image-to-Text）功能的完整技术实现方案。该服务能够将用户上传的肖像照片转换为富有情感的故事叙述。

## API 基础信息

### 基础 URL
```
https://api.gpt.ge
```

### 接口端点
```
/v1/chat/completions
```

### 请求方法
```
POST
```

### 认证方式
```
Authorization: Bearer {api_key}
Content-Type: application/json
```

## 核心参数配置

### API Key
默认 API Key（生产环境建议使用环境变量管理）：
```
sk-QaaY8MM8WwiS9eLfC31f0fB08742448bA75b6a7f1b75E61a
```

### 请求体结构

```json
{
  "model": "gpt-4o-2024-05-13",
  "messages": [
    {
      "role": "user",
      "content": [
        {
          "type": "text",
          "text": "{story_generation_prompt}"
        },
        {
          "type": "image_url",
          "image_url": {
            "url": "data:image/jpeg;base64,{base64_encoded_image}"
          }
        }
      ]
    }
  ],
  "max_tokens": 2000,
  "temperature": 0.8
}
```

## 详细参数说明

### 模型参数
- **model**: `gpt-4o-2024-05-13` - 使用 GPT-4 Vision 模型，支持图像理解
- **max_tokens**: `2000` - 最大生成文本长度，适合 300-500 字的故事
- **temperature**: `0.8` - 创造性参数，0.8 提供适度的随机性和创造性

### 消息结构
消息包含两个部分：
1. **文本提示词**：详细的故事生成指导
2. **图像数据**：Base64 编码的 JPEG 图像

#### 图像格式要求
- **格式**: JPEG
- **编码**: Base64
- **URL格式**: `data:image/jpeg;base64,{base64_string}`

## 故事生成提示词

系统使用的完整提示词如下：

```
You are a creative storyteller and character analyst with expertise in crafting compelling narratives. Analyze the uploaded portrait photo and create an engaging character story based on the person's appearance, expression, and overall vibe.

**Analysis Guidelines:**
- Study the facial features, expression, posture, and overall demeanor
- Consider the setting, clothing, and any contextual elements visible
- Imagine the person's personality, dreams, and life experiences
- Create a narrative that feels authentic and emotionally resonant

**Story Requirements:**
- Write a rich, immersive 3-4 paragraph story (300-500 words)
- Include vivid sensory details and atmospheric descriptions
- Show character depth through actions and inner thoughts
- Create an emotional arc with a meaningful resolution
- Make the story inspiring, relatable, and memorable

**Response Format:**
Return ONLY a valid JSON object with the following exact structure (no additional text or code blocks):
{
  "title": "A Creative, Evocative Title",
  "story": "The complete story text with multiple paragraphs separated by \\n\\n...",
  "character_name": "A fitting name for the character",
  "character_traits": ["Trait1", "Trait2", "Trait3"],
  "setting": "Brief description of story setting",
  "mood": "The overall emotional tone (e.g., Inspiring, Nostalgic, Hopeful)",
  "category": "Story category (e.g., Dreams, Adventure, Art, Life, Love, Family)",
  "read_time": "Estimated read time (e.g., 3 min)"
}

**Style Guidelines:**
- Use literary prose that paints vivid pictures
- Balance action with introspection
- Include dialogue or inner monologue when appropriate
- End with a meaningful insight or hopeful note
- Make each story unique and character-specific

**Important:**
- Base the story on visible characteristics in the photo
- Create original, thoughtful narratives
- Avoid clichés and generic descriptions
- Return ONLY valid JSON - no descriptive text or formatting
```

## 响应数据结构

### 成功响应格式
```json
{
  "id": "chatcmpl-xxxxx",
  "object": "chat.completion",
  "created": 1677652288,
  "model": "gpt-4o-2024-05-13",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "{json_string_response}"
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 150,
    "completion_tokens": 400,
    "total_tokens": 550
  }
}
```

### 解析后的故事数据结构

```json
{
  "title": "A Creative, Evocative Title",
  "story": "The complete story text with multiple paragraphs...",
  "character_name": "A fitting name for the character",
  "character_traits": ["Trait1", "Trait2", "Trait3"],
  "setting": "Brief description of story setting",
  "mood": "The overall emotional tone",
  "category": "Story category",
  "read_time": "Estimated read time"
}
```

## 错误处理机制

### HTTP 状态码处理
- **200**: 成功响应
- **其他状态码**: 抛出异常，包含状态码和响应体

### 网络异常处理
- **SocketException**: 网络连接错误
- **FormatException**: JSON 解析错误
- **通用异常**: 捕获所有其他异常

### 响应内容解析容错

系统实现了多层解析策略：

1. **标准 JSON 解析**: 直接解析响应内容
2. **代码块处理**: 处理被 ```json 或 ``` 包围的响应
3. **智能提取**: 从响应中提取 JSON 对象边界
4. **降级处理**: 当 JSON 解析失败时，创建默认结果

#### 代码块处理逻辑
```dart
if (jsonString.contains('```json')) {
  final jsonStart = jsonString.indexOf('```json') + 7;
  final jsonEnd = jsonString.indexOf('```', jsonStart);
  jsonString = jsonString.substring(jsonStart, jsonEnd).trim();
}
```

## 实现步骤

### 1. 环境准备
```dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
```

### 2. 基础服务类结构
```dart
class StoryAiService {
  static const String baseUrl = 'https://api.gpt.ge';
  static const String apiKey = 'your_api_key_here';

  // 图像转 Base64
  Future<String> imageToBase64(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    return base64Encode(imageBytes);
  }
}
```

### 3. API 请求实现
```dart
Future<Map<String, dynamic>> generateStory(String base64Image) async {
  final requestData = {
    "model": "gpt-4o-2024-05-13",
    "messages": [
      {
        "role": "user",
        "content": [
          {"type": "text", "text": getStoryPrompt()},
          {
            "type": "image_url",
            "image_url": {"url": "data:image/jpeg;base64,$base64Image"}
          }
        ]
      }
    ],
    "max_tokens": 2000,
    "temperature": 0.8
  };

  final response = await http.post(
    Uri.parse('$baseUrl/v1/chat/completions'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    },
    body: jsonEncode(requestData),
  );

  return jsonDecode(response.body);
}
```

### 4. 响应解析实现
```dart
StoryResult parseStoryResult(String content) {
  // 清理和提取 JSON 字符串
  String jsonString = extractJsonFromResponse(content);

  final jsonData = jsonDecode(jsonString);

  return StoryResult(
    title: jsonData['title'] ?? 'Untitled Story',
    story: jsonData['story'] ?? '',
    characterName: jsonData['character_name'] ?? 'Unknown',
    // ... 其他字段
  );
}

## 总结

该实现提供了一个完整的 AI 图生文解决方案，核心优势包括：

1. **精准的视觉分析**: 利用 GPT-4 Vision 的强大图像理解能力
2. **结构化输出**: 标准化的 JSON 响应格式
3. **容错性强**: 多层解析策略确保稳定性
4. **用户友好**: 详细的错误处理和降级方案

通过合理配置参数和优化实现，可以构建出高质量的 AI 故事生成服务，为用户提供独特的创意体验。
