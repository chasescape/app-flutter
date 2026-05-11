/// ---------------------------------------------------------------------------
/// File: chat_view.dart
/// Description: Kissmi chat page entry, wired with GetX routing.
/// ---------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'chat_logic.dart';

class ChatPage extends StatelessWidget {
  ChatPage({Key? key}) : super(key: key);

  final ChatLogic logic = Get.put(ChatLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Kissmi'),
      ),
      body: const Center(
        child: Text(
          'Chat page entry.\n\nThe detailed chat experience will be aligned with the web Chat implementation in the next steps.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
