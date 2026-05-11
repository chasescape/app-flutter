import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'feedback_logic.dart';

class FeedbackPage extends StatelessWidget {
  FeedbackPage({Key? key}) : super(key: key);

  final FeedbackLogic logic = Get.put(FeedbackLogic());

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
