import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/ai_prompt.dart';
import '../../data/chat_store.dart';
import '../../data/coin_store.dart';
import '../../data/daily_tip_store.dart';
import '../../data/mood_store.dart';
import '../../network/ai_service.dart';
import '../../network/core_services.dart';
import '../coins/coins_logic.dart';
import '../date/date_logic.dart';

class HomeLogic extends GetxController {
  bool inChatMode = false;
  final List<ChatSession> sessions = <ChatSession>[];
  String? activeSessionId;
  late final AiService _aiService;
  final String _aiModel = 'gpt-4o-2024-05-13';
  late final Future<void> _sessionsReady;
  
  // 添加发送状态管理
  final RxBool isSending = false.obs;

  @override
  void onInit() {
    _aiService = CoreServices.instance.aiService;
    _sessionsReady = _loadSessions();
    super.onInit();
  }

  Future<void> _loadSessions() async {
    final loaded = await ChatStore.loadSessions();
    sessions
      ..clear()
      ..addAll(loaded);
    if (sessions.isNotEmpty) {
      activeSessionId ??= sessions.first.id;
    }
    update();
  }

  List<ChatMessage> get currentMessages {
    final session = _currentSession;
    return session?.messages ?? <ChatMessage>[];
  }

  ChatSession? get _currentSession {
    if (activeSessionId == null) return null;
    return sessions.firstWhereOrNull((s) => s.id == activeSessionId);
  }

  Future<void> enterChatMode() async {
    await _sessionsReady;
    if (!inChatMode) {
      inChatMode = true;
    }
    _ensureSession();
    _ensureStarterQuestion();
    update();
  }

  void startNewTopic() {
    final session = _createSession();
    sessions.insert(0, session);
    activeSessionId = session.id;
    inChatMode = true;
    _persistSessions();
    update();
  }

  void openSession(ChatSession session) {
    activeSessionId = session.id;
    inChatMode = true;
    update();
  }

  void renameSession(ChatSession session, String title) {
    session.title = title.trim().isEmpty ? session.title : title.trim();
    session.updatedAt = DateTime.now();
    _persistSessions();
    update();
  }

  void deleteSession(ChatSession session) {
    sessions.removeWhere((s) => s.id == session.id);
    if (activeSessionId == session.id) {
      activeSessionId = sessions.isNotEmpty ? sessions.first.id : null;
      inChatMode = sessions.isNotEmpty;
    }
    _persistSessions();
    update();
  }

  Future<void> sendTextMessage(String text) async {
    final String trimmed = text.trim();
    if (trimmed.isEmpty) return;
    
    // 防止重复发送
    if (isSending.value) return;
    isSending.value = true;
    
    try {
      await _sessionsReady;
      final bool canSpend = await CoinStore.canSpend(10);
      if (!canSpend) {
        Get.snackbar('Coins', 'Not enough coins.');
        isSending.value = false;
        return;
      }
      await CoinStore.spendCoins(10);
      _refreshCoinBalance();

      if (!inChatMode) {
        // From home landing -> always start a new topic.
        startNewTopic();
      } else {
        await enterChatMode();
      }
      final session = _ensureSession();
      session.messages.add(_userText(trimmed));
      session.updatedAt = DateTime.now();
      _persistSessions();
      update(); // 立即更新UI显示用户消息
      
      // 异步处理AI回复
      _addThinkingThenResponse(prompt: trimmed);
    } catch (e) {
      isSending.value = false;
      rethrow;
    }
  }

  Future<void> sendImageMessage(String imagePath) async {
    // 防止重复发送
    if (isSending.value) return;
    isSending.value = true;
    
    try {
      await _sessionsReady;
      final bool canSpend = await CoinStore.canSpend(10);
      if (!canSpend) {
        Get.snackbar('Coins', 'Not enough coins.');
        return;
      }
      await CoinStore.spendCoins(10);
      _refreshCoinBalance();

      if (!inChatMode) {
        // From home landing -> always start a new topic.
        startNewTopic();
      } else {
        await enterChatMode();
      }
      final session = _ensureSession();
      
      // 异步处理图片持久化和AI回复
      _persistPickedImage(imagePath).then((persistedPath) {
        session.messages.add(_userImage(persistedPath));
        session.updatedAt = DateTime.now();
        _persistSessions();
        update(); // 立即更新UI显示用户图片
        
        _addThinkingThenResponse(
          prompt: 'User shared an image for context.',
          imagePath: persistedPath,
        );
      }).catchError((_) {
        session.messages.add(_assistantText('Image is unavailable. Please try again.'));
        session.updatedAt = DateTime.now();
        _persistSessions();
        update();
        // 图片失败时也要重置发送状态
        isSending.value = false;
      });
    } catch (e) {
      isSending.value = false;
      rethrow;
    }
  }

  void _ensureStarterQuestion() {
    final session = _ensureSession();
    if (session.messages.isNotEmpty) return;
    session.messages.add(
      _assistantText(
        'How are you feeling today? You can share mood, energy, or what you did. '
        'If you want, upload a photo too. (Lifestyle tips only, for reference.)',
      ),
    );
    _persistSessions();
  }

  void _addThinkingThenResponse({required String prompt, String? imagePath}) {
    final session = _ensureSession();
    session.messages.add(_assistantThinking());
    _persistSessions();
    update();
    
    // 异步执行AI调用，不阻塞UI
    _runAi(prompt: prompt, imagePath: imagePath);
  }

  Future<void> _runAi({required String prompt, String? imagePath}) async {
    try {
      final String fullPrompt = _buildPromptWithHistory(prompt);
      String reply;
      if (imagePath != null) {
        final bytes = await File(imagePath).readAsBytes();
        final base64Image = base64Encode(bytes);
        reply = await _aiService.generateVisionStory(
          base64Image: base64Image,
          prompt: fullPrompt,
        );
      } else {
        reply = await _aiService.generateStory(
          prompt: fullPrompt,
          model: _aiModel,
          temperature: 0.6,
          maxTokens: 220,
        );
      }
      await _replaceThinkingWith(reply);
    } catch (e) {
      await _replaceThinkingWith(
        'AI is temporarily unavailable. '
        'Here are gentle lifestyle-only tips: hydrate, '
        'take short breaks, and keep meals steady.',
      );
    }
  }

  Future<void> _replaceThinkingWith(String reply) async {
    final session = _ensureSession();
    if (session.messages.isNotEmpty && session.messages.last.isThinking) {
      session.messages.removeLast();
    }
    session.messages.add(_assistantText(reply));
    session.updatedAt = DateTime.now();
    _persistSessions();
    await _syncTipFromReply(reply);
    
    // AI 回复完成，重置发送状态
    isSending.value = false;
    
    update();
  }

  String _buildPromptWithHistory(String latestUser) {
    final session = _ensureSession();
    final history = session.messages
        .where((m) => !m.isThinking)
        .take(8)
        .map((m) => m.isUser ? 'User: ${m.text ?? '[image]'}' : 'Assistant: ${m.text ?? ''}')
        .toList();
    history.add('User: $latestUser');
    return '${AiPrompts.dailyCheckInSystem}\n\nConversation:\n${history.join('\n')}';
  }

  ChatSession _ensureSession() {
    final existing = _currentSession;
    if (existing != null) return existing;
    final session = _createSession();
    sessions.insert(0, session);
    activeSessionId = session.id;
    _persistSessions();
    return session;
  }

  ChatSession _createSession() {
    final now = DateTime.now();
    final id = now.millisecondsSinceEpoch.toString();
    return ChatSession(
      id: id,
      title: 'Chat ${_formatDate(now)}',
      createdAt: now,
      updatedAt: now,
      messages: <ChatMessage>[],
    );
  }

  void _persistSessions() {
    ChatStore.saveSessions(sessions);
  }

  Future<String> _persistPickedImage(String originalPath) async {
    final File file = File(originalPath);
    if (!await file.exists()) return originalPath;

    final Directory root = await getApplicationDocumentsDirectory();
    final Directory dir = Directory('${root.path}/chat_images');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final int dot = originalPath.lastIndexOf('.');
    final String ext =
        (dot != -1 && dot > originalPath.lastIndexOf('/')) ? originalPath.substring(dot) : '.jpg';
    final String name = 'img_${DateTime.now().millisecondsSinceEpoch}$ext';
    final String targetPath = '${dir.path}/$name';
    await file.copy(targetPath);
    return targetPath;
  }

  Future<void> openCheckIn() async {
    await _sessionsReady;
    // Entering check-in from home -> start a fresh topic.
    startNewTopic();
  }

  String _formatDate(DateTime date) {
    final String m = date.month.toString().padLeft(2, '0');
    final String d = date.day.toString().padLeft(2, '0');
    return '${date.year}.$m.$d';
  }

  Future<void> _syncTipFromReply(String reply) async {
    final DateTime today = DateTime.now();
    final String tip = _extractTip(reply) ?? reply;
    await DailyTipStore.setTip(today, tip);
    final String? moodEmoji = _extractMoodEmoji(reply);
    if (moodEmoji != null) {
      await MoodStore.setEmoji(today, moodEmoji);
    }
    if (Get.isRegistered<DateLogic>()) {
      final DateLogic dateLogic = Get.find<DateLogic>();
      dateLogic.refreshTip(today, tip);
      if (moodEmoji != null) {
        dateLogic.refreshMood(today, moodEmoji);
      }
    }
  }

  void _refreshCoinBalance() {
    if (Get.isRegistered<CoinsLogic>()) {
      final CoinsLogic coinsLogic = Get.find<CoinsLogic>();
      CoinStore.loadBalance().then((value) => coinsLogic.balance.value = value);
    }
  }

  String? _extractTip(String reply) {
    return reply.trim().isEmpty ? null : reply.trim();
  }

  String? _extractMoodEmoji(String reply) {
    final RegExp emojiPattern = RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true);
    final RegExp moodLine = RegExp(r'mood\s*:\s*([^\n]+)', caseSensitive: false);
    final Match? match = moodLine.firstMatch(reply);
    if (match == null) return null;

    final String segment = match.group(1) ?? '';
    final Match? emojiMatch = emojiPattern.firstMatch(segment);
    if (emojiMatch != null) {
      return emojiMatch.group(0);
    }

    return _mapMoodKeyword(segment);
  }

  String? _mapMoodKeyword(String segment) {
    final String lower = segment.toLowerCase();
    if (lower.contains('sad') || lower.contains('upset') || lower.contains('down') ||
        segment.contains('伤心') || segment.contains('难过')) {
      return '😢';
    }
    if (lower.contains('happy') || lower.contains('joy') || lower.contains('excited') ||
        segment.contains('开心') || segment.contains('高兴')) {
      return '😊';
    }
    if (lower.contains('tired') || lower.contains('fatigue') || lower.contains('exhausted') ||
        segment.contains('疲惫') || segment.contains('累')) {
      return '😮‍💨';
    }
    if (lower.contains('anxious') || lower.contains('nervous') || lower.contains('stressed') ||
        segment.contains('焦虑') || segment.contains('紧张')) {
      return '😰';
    }
    if (lower.contains('calm') || lower.contains('relaxed') || segment.contains('平静')) {
      return '😌';
    }
    if (lower.contains('angry') || lower.contains('mad') || segment.contains('生气')) {
      return '😠';
    }
    if (lower.contains('okay') || lower.contains('neutral') || segment.contains('还好')) {
      return '🙂';
    }
    return null;
  }

  ChatMessage _userText(String text) => ChatMessage(
        isUser: true,
        text: text,
        imagePath: null,
        isThinking: false,
        createdAt: DateTime.now(),
      );

  ChatMessage _userImage(String path) => ChatMessage(
        isUser: true,
        text: null,
        imagePath: path,
        isThinking: false,
        createdAt: DateTime.now(),
      );

  ChatMessage _assistantText(String text) => ChatMessage(
        isUser: false,
        text: text,
        imagePath: null,
        isThinking: false,
        createdAt: DateTime.now(),
      );

  ChatMessage _assistantThinking() => ChatMessage(
        isUser: false,
        text: null,
        imagePath: null,
        isThinking: true,
        createdAt: DateTime.now(),
      );

  Widget _field(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

}
