import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'nav_logic.dart';

class NavPage extends StatelessWidget {
  NavPage({super.key});

  final NavLogic logic = Get.put(NavLogic());

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
