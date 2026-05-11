import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'coins_logic.dart';

class CoinsPage extends StatelessWidget {
  CoinsPage({Key? key}) : super(key: key);

  final CoinsLogic logic = Get.put(CoinsLogic());

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
