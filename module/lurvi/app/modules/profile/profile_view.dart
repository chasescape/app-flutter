import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'profile_logic.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final ProfileLogic logic = Get.put(ProfileLogic());

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
