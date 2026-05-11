import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ChatStore {
  ChatStore._();

  static const String _prefsKey = 'chat_sessions_v1';

  static Future<List<ChatSession>> loadSessions() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) return <ChatSession>[];
    try {
      final List<dynamic> data = jsonDecode(raw) as List<dynamic>;
      return data
          .whereType<Map<String, dynamic>>()
          .map(ChatSession.fromJson)
          .toList();
    } catch (_) {
      return <ChatSession>[];
    }
  }

  static Future<void> saveSessions(List<ChatSession> sessions) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> data =
        sessions.map((s) => s.toJson()).toList();
    await prefs.setString(_prefsKey, jsonEncode(data));
  }

  static Future<void> clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}

class ChatSession {
  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  final String id;
  String title;
  final DateTime createdAt;
  DateTime updatedAt;
  final List<ChatMessage> messages;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }

  static ChatSession fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawMessages = json['messages'] as List<dynamic>? ?? [];
    return ChatSession(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? 'Chat',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      messages: rawMessages
          .whereType<Map<String, dynamic>>()
          .map(ChatMessage.fromJson)
          .toList(),
    );
  }
}

class ChatMessage {
  ChatMessage({
    required this.isUser,
    required this.text,
    required this.imagePath,
    required this.isThinking,
    required this.createdAt,
  });

  final bool isUser;
  final String? text;
  final String? imagePath;
  final bool isThinking;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'isUser': isUser,
      'text': text,
      'imagePath': imagePath,
      'isThinking': isThinking,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static ChatMessage fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      isUser: json['isUser'] as bool? ?? false,
      text: json['text'] as String?,
      imagePath: json['imagePath'] as String?,
      isThinking: json['isThinking'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
